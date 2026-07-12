from __future__ import annotations

import mimetypes
import sqlite3
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


class MBTilesServer:
    """Small local HTTP server that reads raster tiles from an MBTiles file."""

    def __init__(
        self,
        mbtiles_path: Path,
        web_directory: Path,
        host: str = "127.0.0.1",
        port: int = 8765,
    ) -> None:
        self.mbtiles_path = Path(mbtiles_path)
        self.web_directory = Path(web_directory)
        self.host = host
        self.port = port

        self._server: ThreadingHTTPServer | None = None
        self._thread: threading.Thread | None = None

    def start(self) -> None:
        parent = self

        class RequestHandler(BaseHTTPRequestHandler):
            def do_GET(self) -> None:
                parsed = urlparse(self.path)
                request_path = parsed.path

                if request_path.startswith("/tiles/"):
                    self.serve_tile(request_path)
                    return

                self.serve_web_file(request_path)

            def serve_tile(self, request_path: str) -> None:
                try:
                    parts = request_path.strip("/").split("/")

                    if len(parts) != 4:
                        self.send_error(400, "Invalid tile address")
                        return

                    _, zoom_text, column_text, row_filename = parts

                    zoom = int(zoom_text)
                    column = int(column_text)
                    row = int(Path(row_filename).stem)

                    # Leaflet requests XYZ rows. MBTiles stores TMS rows.
                    tms_row = (1 << zoom) - 1 - row

                    tile_data = parent.read_tile(
                        zoom=zoom,
                        column=column,
                        row=tms_row,
                    )

                    if tile_data is None:
                        self.send_error(404, "Tile not found")
                        return

                    content_type = self.detect_tile_type(tile_data)

                    self.send_response(200)
                    self.send_header("Content-Type", content_type)
                    self.send_header("Cache-Control", "public, max-age=86400")
                    self.send_header("Content-Length", str(len(tile_data)))
                    self.end_headers()
                    self.wfile.write(tile_data)

                except (ValueError, sqlite3.Error) as error:
                    self.send_error(500, str(error))

            def serve_web_file(self, request_path: str) -> None:
                relative_path = request_path.lstrip("/") or "map.html"
                requested_file = (parent.web_directory / relative_path).resolve()

                try:
                    requested_file.relative_to(parent.web_directory.resolve())
                except ValueError:
                    self.send_error(403, "Forbidden")
                    return

                if not requested_file.exists() or not requested_file.is_file():
                    self.send_error(404, "File not found")
                    return

                data = requested_file.read_bytes()
                content_type, _ = mimetypes.guess_type(requested_file.name)

                self.send_response(200)
                self.send_header(
                    "Content-Type",
                    content_type or "application/octet-stream",
                )
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)

            @staticmethod
            def detect_tile_type(tile_data: bytes) -> str:
                if tile_data.startswith(b"\x89PNG"):
                    return "image/png"

                if tile_data.startswith(b"\xff\xd8"):
                    return "image/jpeg"

                if tile_data.startswith(b"RIFF") and b"WEBP" in tile_data[:16]:
                    return "image/webp"

                return "application/octet-stream"

            def log_message(self, format_string: str, *args) -> None:
                # Silence routine web-server messages.
                return

        self._server = ThreadingHTTPServer(
            (self.host, self.port),
            RequestHandler,
        )

        self._thread = threading.Thread(
            target=self._server.serve_forever,
            name="mbtiles-server",
            daemon=True,
        )
        self._thread.start()

    def stop(self) -> None:
        if self._server is not None:
            self._server.shutdown()
            self._server.server_close()
            self._server = None

        if self._thread is not None:
            self._thread.join(timeout=2)
            self._thread = None

    def read_tile(
        self,
        zoom: int,
        column: int,
        row: int,
    ) -> bytes | None:
        if not self.mbtiles_path.exists():
            return None

        connection = sqlite3.connect(
            f"file:{self.mbtiles_path}?mode=ro",
            uri=True,
            timeout=5,
        )

        try:
            result = connection.execute(
                """
                SELECT tile_data
                FROM tiles
                WHERE zoom_level = ?
                  AND tile_column = ?
                  AND tile_row = ?
                LIMIT 1
                """,
                (zoom, column, row),
            ).fetchone()

            return result[0] if result else None

        finally:
            connection.close()
