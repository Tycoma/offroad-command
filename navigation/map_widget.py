from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtWidgets import QApplication, QMainWindow
from PySide6.QtWebEngineWidgets import QWebEngineView

from map_server import MBTilesServer


PROJECT_DIRECTORY = Path.home() / "passenger-display"
MAP_FILE = PROJECT_DIRECTORY / "maps" / "active.mbtiles"
WEB_DIRECTORY = PROJECT_DIRECTORY / "navigation" / "web"


class OfflineMapWindow(QMainWindow):
    def __init__(self) -> None:
        super().__init__()

        self.setWindowTitle("Off-Road Offline Map")
        self.setMinimumSize(800, 480)

        self.map_server = MBTilesServer(
            mbtiles_path=MAP_FILE,
            web_directory=WEB_DIRECTORY,
        )
        self.map_server.start()

        self.web_view = QWebEngineView()
        self.web_view.setUrl(
            QUrl("http://127.0.0.1:8765/map.html")
        )

        self.setCentralWidget(self.web_view)

    def closeEvent(self, event) -> None:
        self.map_server.stop()
        event.accept()


def main() -> int:
    app = QApplication(sys.argv)

    window = OfflineMapWindow()
    window.showFullScreen()

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
