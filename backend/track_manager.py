import json
import math
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path

from PySide6.QtCore import QObject, Property, QTimer, Signal, Slot


class TrackManager(QObject):
    """
    Automatically records the vehicle's GPS path as a "trip" whenever
    it is moving, and stops/saves the trip after it has been
    stationary for a while. There is no manual start/stop control.
    """

    tracksChanged = Signal()
    recordingChanged = Signal()
    pointCountChanged = Signal()

    errorOccurred = Signal(str)

    MIN_POINT_DISTANCE_METERS = 8.0

    START_SPEED_MPH = 3.0
    STOP_TIMEOUT_SECONDS = 300

    STATIONARY_CHECK_INTERVAL_MS = 15000

    def __init__(self, parent=None):
        super().__init__(parent)

        project_root = Path(__file__).resolve().parent.parent

        self._data_directory = project_root / "data"
        self._data_file = self._data_directory / "tracks.json"
        self._checkpoint_file = (
            self._data_directory / "current_trip.json"
        )

        self._tracks = []
        self._recording = False
        self._current_points = []
        self._started_at = None
        self._last_movement_monotonic = None

        self._data_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

        self._load_tracks()
        self._recover_checkpoint()

        self._stationary_timer = QTimer(self)
        self._stationary_timer.setInterval(
            self.STATIONARY_CHECK_INTERVAL_MS
        )
        self._stationary_timer.timeout.connect(
            self._check_stationary_timeout
        )
        self._stationary_timer.start()

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

    def _save_checkpoint(self):
        try:
            with self._checkpoint_file.open(
                "w",
                encoding="utf-8",
            ) as file:
                json.dump(
                    {
                        "started": self._started_at.isoformat()
                        if self._started_at
                        else None,
                        "points": self._current_points,
                    },
                    file,
                )

        except OSError:
            pass

    def _clear_checkpoint(self):
        try:
            self._checkpoint_file.unlink(missing_ok=True)
        except OSError:
            pass

    def _recover_checkpoint(self):
        if not self._checkpoint_file.exists():
            return

        try:
            with self._checkpoint_file.open(
                "r",
                encoding="utf-8",
            ) as file:
                data = json.load(file)

            points = data.get("points") or []
            started = data.get("started")

            if len(points) >= 2:
                started_at = (
                    datetime.fromisoformat(started)
                    if started
                    else datetime.now(timezone.utc)
                )

                self._finish_trip(
                    points,
                    started_at,
                    recovered=True,
                )

                print(
                    "Recovered an in-progress trip from an "
                    "unclean shutdown",
                    flush=True,
                )

        except (OSError, json.JSONDecodeError, ValueError):
            pass

        finally:
            self._clear_checkpoint()

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

    @Slot(float, float, float)
    def updatePosition(self, latitude, longitude, speed_mph):
        now = time.monotonic()

        if speed_mph >= self.START_SPEED_MPH:
            self._last_movement_monotonic = now

            if not self._recording:
                self._start_trip()

        if self._recording:
            self._add_point(latitude, longitude)

    def _start_trip(self):
        self._current_points = []
        self._started_at = datetime.now(timezone.utc)
        self._recording = True

        self.recordingChanged.emit()
        self.pointCountChanged.emit()

        print("Trip started", flush=True)

    def _add_point(self, latitude, longitude):
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
        self._save_checkpoint()

    def _check_stationary_timeout(self):
        if (
            not self._recording
            or self._last_movement_monotonic is None
        ):
            return

        idle_seconds = (
            time.monotonic() - self._last_movement_monotonic
        )

        if idle_seconds >= self.STOP_TIMEOUT_SECONDS:
            self._end_trip()

    def _end_trip(self):
        self._recording = False
        self.recordingChanged.emit()

        points = self._current_points
        started_at = self._started_at

        self._current_points = []
        self._started_at = None
        self.pointCountChanged.emit()

        self._clear_checkpoint()

        if len(points) < 2:
            print(
                "Trip ended: not enough movement, discarded",
                flush=True,
            )
            return

        self._finish_trip(points, started_at)

    def _finish_trip(self, points, started_at, recovered=False):
        distance_meters = 0.0

        for index in range(1, len(points)):
            previous_lat, previous_lon = points[index - 1]
            lat, lon = points[index]

            distance_meters += self._distance_meters(
                previous_lat,
                previous_lon,
                lat,
                lon,
            )

        ended_at = datetime.now(timezone.utc)

        duration_seconds = max(
            0.0,
            (ended_at - started_at).total_seconds(),
        )

        name = "Trip " + started_at.astimezone().strftime(
            "%Y-%m-%d %H:%M"
        )

        trip = {
            "id": str(uuid.uuid4()),
            "name": name,
            "points": points,
            "distanceMeters": distance_meters,
            "durationSeconds": duration_seconds,
            "started": started_at.isoformat(),
            "ended": ended_at.isoformat(),
            "recovered": recovered,
        }

        self._tracks.append(trip)

        if not self._save_tracks():
            self._tracks.pop()
            return

        self.tracksChanged.emit()

        print(
            "Trip saved:",
            trip["name"],
            f"{distance_meters / 1609.34:.1f} mi",
            flush=True,
        )

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

        print("Trip deleted:", track_id, flush=True)

        return True
