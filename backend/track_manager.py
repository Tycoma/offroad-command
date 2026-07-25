import json
import math
import uuid
from datetime import datetime, timezone
from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal, Slot


class TrackManager(QObject):
    tracksChanged = Signal()
    recordingChanged = Signal()
    pointCountChanged = Signal()

    errorOccurred = Signal(str)

    MIN_POINT_DISTANCE_METERS = 8.0

    def __init__(self, parent=None):
        super().__init__(parent)

        project_root = Path(__file__).resolve().parent.parent

        self._data_directory = project_root / "data"
        self._data_file = self._data_directory / "tracks.json"

        self._tracks = []
        self._recording = False
        self._current_points = []

        self._data_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

        self._load_tracks()

    def _load_tracks(self):
        if not self._data_file.exists():
            self._tracks = []
            self._save_tracks()
            return

        try:
            with self._data_file.open(
                "r",
                encoding="utf-8",
            ) as file:
                data = json.load(file)

            self._tracks = data if isinstance(data, list) else []

        except (OSError, json.JSONDecodeError) as error:
            self._tracks = []

            self.errorOccurred.emit(
                f"Could not load tracks: {error}"
            )

    def _save_tracks(self):
        try:
            self._data_directory.mkdir(
                parents=True,
                exist_ok=True,
            )

            temporary_file = self._data_file.with_suffix(
                ".tmp"
            )

            with temporary_file.open(
                "w",
                encoding="utf-8",
            ) as file:
                json.dump(
                    self._tracks,
                    file,
                    indent=4,
                )

            temporary_file.replace(
                self._data_file
            )

            return True

        except OSError as error:
            self.errorOccurred.emit(
                f"Could not save tracks: {error}"
            )

            return False

    @staticmethod
    def _distance_meters(lat1, lon1, lat2, lon2):
        radius = 6371000.0

        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = (
            math.sin(delta_phi / 2) ** 2
            + math.cos(phi1)
            * math.cos(phi2)
            * math.sin(delta_lambda / 2) ** 2
        )

        return radius * 2 * math.atan2(
            math.sqrt(a),
            math.sqrt(1 - a),
        )

    def _tracks_json(self):
        return json.dumps(self._tracks)

    tracksJson = Property(
        str,
        _tracks_json,
        notify=tracksChanged,
    )

    @Property(bool, notify=recordingChanged)
    def recording(self):
        return self._recording

    @Property(int, notify=pointCountChanged)
    def pointCount(self):
        return len(self._current_points)

    @Slot(result=str)
    def getTracksJson(self):
        return json.dumps(self._tracks)

    @Slot()
    def startRecording(self):
        if self._recording:
            return

        self._current_points = []
        self._recording = True

        self.recordingChanged.emit()
        self.pointCountChanged.emit()

        print("Track recording started", flush=True)

    @Slot(float, float)
    def addPoint(self, latitude, longitude):
        if not self._recording:
            return

        if self._current_points:
            last_lat, last_lon = self._current_points[-1]

            if (
                self._distance_meters(
                    last_lat,
                    last_lon,
                    latitude,
                    longitude,
                )
                < self.MIN_POINT_DISTANCE_METERS
            ):
                return

        self._current_points.append(
            [latitude, longitude]
        )

        self.pointCountChanged.emit()

    @Slot(result=str)
    def stopRecording(self):
        if not self._recording:
            return ""

        self._recording = False
        self.recordingChanged.emit()

        if len(self._current_points) < 2:
            self._current_points = []
            self.pointCountChanged.emit()

            print(
                "Track recording stopped: not enough points, discarded",
                flush=True,
            )

            return ""

        track = {
            "id": str(uuid.uuid4()),
            "name": "Track "
            + datetime.now().strftime("%Y-%m-%d %H:%M"),
            "points": self._current_points,
            "created": datetime.now(
                timezone.utc
            ).isoformat(),
        }

        self._tracks.append(track)

        if not self._save_tracks():
            self._tracks.pop()
            self._current_points = []
            self.pointCountChanged.emit()

            return ""

        self._current_points = []
        self.pointCountChanged.emit()
        self.tracksChanged.emit()

        print(
            "Track saved:",
            track["name"],
            len(track["points"]),
            "points",
            flush=True,
        )

        return json.dumps(track)

    @Slot(str, result=bool)
    def deleteTrack(self, track_id):
        original_tracks = list(self._tracks)

        self._tracks = [
            track
            for track in self._tracks
            if track.get("id") != track_id
        ]

        if len(self._tracks) == len(original_tracks):
            return False

        if not self._save_tracks():
            self._tracks = original_tracks
            return False

        self.tracksChanged.emit()

        print("Track deleted:", track_id, flush=True)

        return True
