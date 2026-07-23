import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from PySide6.QtCore import QObject, Property, Signal, Slot


class WaypointManager(QObject):
    waypointsChanged = Signal()
    selectedWaypointChanged = Signal()

    errorOccurred = Signal(str)
    waypointAdded = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)

        project_root = Path(__file__).resolve().parent.parent

        self._data_directory = project_root / "data"
        self._data_file = self._data_directory / "waypoints.json"

        self._waypoints = []
        self._selected_waypoint_id = ""

        self._data_directory.mkdir(
            parents=True,
            exist_ok=True,
        )

        self._load_waypoints()

    def _load_waypoints(self):
        if not self._data_file.exists():
            self._waypoints = []
            self._save_waypoints()
            return

        try:
            with self._data_file.open(
                "r",
                encoding="utf-8",
            ) as file:
                data = json.load(file)

            if isinstance(data, list):
                self._waypoints = data
            else:
                self._waypoints = []

                self.errorOccurred.emit(
                    "Waypoint file did not contain a valid list."
                )

        except (OSError, json.JSONDecodeError) as error:
            self._waypoints = []

            self.errorOccurred.emit(
                f"Could not load waypoints: {error}"
            )

        if (
            self._selected_waypoint_id
            and self._find_waypoint(
                self._selected_waypoint_id
            ) is None
        ):
            self._selected_waypoint_id = ""
            self.selectedWaypointChanged.emit()

    def _save_waypoints(self):
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
                    self._waypoints,
                    file,
                    indent=4,
                )

            temporary_file.replace(
                self._data_file
            )

            return True

        except OSError as error:
            self.errorOccurred.emit(
                f"Could not save waypoints: {error}"
            )

            return False

    def _find_waypoint(self, waypoint_id):
        for waypoint in self._waypoints:
            if waypoint.get("id") == waypoint_id:
                return waypoint

        return None

    def _waypoints_json(self):
        return json.dumps(self._waypoints)

    def _selected_waypoint_json(self):
        if not self._selected_waypoint_id:
            return ""

        waypoint = self._find_waypoint(
            self._selected_waypoint_id
        )

        if waypoint is None:
            return ""

        return json.dumps(waypoint)

    waypointsJson = Property(
        str,
        _waypoints_json,
        notify=waypointsChanged,
    )

    selectedWaypointJson = Property(
        str,
        _selected_waypoint_json,
        notify=selectedWaypointChanged,
    )

    @Slot(result=str)
    def getWaypointsJson(self):
        return json.dumps(self._waypoints)

    @Slot(str, result=str)
    def getWaypointJson(self, waypoint_id):
        waypoint = self._find_waypoint(
            waypoint_id
        )

        if waypoint is None:
            return ""

        return json.dumps(waypoint)

    @Slot(result=str)
    def getSelectedWaypointJson(self):
        return self._selected_waypoint_json()

    @Slot(float, float, result=str)
    def addWaypoint(
        self,
        latitude,
        longitude,
    ):
        waypoint_number = len(self._waypoints) + 1

        return self.createWaypoint(
            f"Waypoint {waypoint_number}",
            "WAYPOINT",
            "",
            latitude,
            longitude,
        )

    @Slot(
        str,
        str,
        str,
        float,
        float,
        result=str,
    )
    def createWaypoint(
        self,
        name,
        category,
        notes,
        latitude,
        longitude,
    ):
        cleaned_name = name.strip()
        cleaned_category = category.strip()
        cleaned_notes = notes.strip()

        if not cleaned_name:
            self.errorOccurred.emit(
                "Waypoint name cannot be empty."
            )
            return ""

        try:
            waypoint_latitude = float(latitude)
            waypoint_longitude = float(longitude)
        except (TypeError, ValueError):
            self.errorOccurred.emit(
                "Waypoint coordinates are invalid."
            )
            return ""

        waypoint = {
            "id": str(uuid.uuid4()),
            "name": cleaned_name,
            "latitude": waypoint_latitude,
            "longitude": waypoint_longitude,
            "category": (
                cleaned_category
                if cleaned_category
                else "WAYPOINT"
            ),
            "icon": "pin",
            "color": "#ffb347",
            "notes": cleaned_notes,
            "created": datetime.now(
                timezone.utc
            ).isoformat(),
        }

        self._waypoints.append(waypoint)

        if not self._save_waypoints():
            self._waypoints.pop()
            return ""

        waypoint_json = json.dumps(waypoint)

        self.waypointsChanged.emit()
        self.waypointAdded.emit(
            waypoint_json
        )

        print(
            "Waypoint created:",
            waypoint["name"],
            waypoint["latitude"],
            waypoint["longitude"],
        )

        return waypoint_json

    @Slot(str, result=bool)
    def setSelectedWaypoint(
        self,
        waypoint_id,
    ):
        cleaned_id = waypoint_id.strip()

        if not cleaned_id:
            return self.clearSelectedWaypoint()

        waypoint = self._find_waypoint(
            cleaned_id
        )

        if waypoint is None:
            self.errorOccurred.emit(
                "Selected waypoint was not found."
            )
            return False

        if (
            self._selected_waypoint_id
            == cleaned_id
        ):
            return True

        self._selected_waypoint_id = cleaned_id
        self.selectedWaypointChanged.emit()

        print(
            "Waypoint selected:",
            waypoint.get("name", cleaned_id),
        )

        return True

    @Slot(result=bool)
    def clearSelectedWaypoint(self):
        if not self._selected_waypoint_id:
            return True

        self._selected_waypoint_id = ""
        self.selectedWaypointChanged.emit()

        return True

    @Slot(str, result=bool)
    def deleteWaypoint(
        self,
        waypoint_id,
    ):
        waypoint = self._find_waypoint(
            waypoint_id
        )

        if waypoint is None:
            return False

        original_waypoints = list(
            self._waypoints
        )

        self._waypoints = [
            item
            for item in self._waypoints
            if item.get("id") != waypoint_id
        ]

        if not self._save_waypoints():
            self._waypoints = original_waypoints
            return False

        was_selected = (
            self._selected_waypoint_id
            == waypoint_id
        )

        if was_selected:
            self._selected_waypoint_id = ""

        self.waypointsChanged.emit()

        if was_selected:
            self.selectedWaypointChanged.emit()

        print(
            "Waypoint deleted:",
            waypoint_id,
        )

        return True

    @Slot(str, str, result=bool)
    def renameWaypoint(
        self,
        waypoint_id,
        new_name,
    ):
        cleaned_name = new_name.strip()

        if not cleaned_name:
            self.errorOccurred.emit(
                "Waypoint name cannot be empty."
            )
            return False

        waypoint = self._find_waypoint(
            waypoint_id
        )

        if waypoint is None:
            return False

        previous_name = waypoint.get(
            "name",
            "",
        )

        waypoint["name"] = cleaned_name

        if not self._save_waypoints():
            waypoint["name"] = previous_name
            return False

        self.waypointsChanged.emit()

        if (
            self._selected_waypoint_id
            == waypoint_id
        ):
            self.selectedWaypointChanged.emit()

        print(
            "Waypoint renamed:",
            waypoint_id,
            cleaned_name,
        )

        return True

    @Slot(str, str, result=bool)
    def updateWaypointNotes(
        self,
        waypoint_id,
        notes,
    ):
        waypoint = self._find_waypoint(
            waypoint_id
        )

        if waypoint is None:
            return False

        previous_notes = waypoint.get(
            "notes",
            "",
        )

        waypoint["notes"] = notes.strip()

        if not self._save_waypoints():
            waypoint["notes"] = previous_notes
            return False

        self.waypointsChanged.emit()

        if (
            self._selected_waypoint_id
            == waypoint_id
        ):
            self.selectedWaypointChanged.emit()

        return True

    @Slot(str, str, result=bool)
    def updateWaypointCategory(
        self,
        waypoint_id,
        category,
    ):
        cleaned_category = category.strip()

        if not cleaned_category:
            cleaned_category = "WAYPOINT"

        waypoint = self._find_waypoint(
            waypoint_id
        )

        if waypoint is None:
            return False

        previous_category = waypoint.get(
            "category",
            "WAYPOINT",
        )

        waypoint["category"] = cleaned_category

        if not self._save_waypoints():
            waypoint["category"] = (
                previous_category
            )
            return False

        self.waypointsChanged.emit()

        if (
            self._selected_waypoint_id
            == waypoint_id
        ):
            self.selectedWaypointChanged.emit()

        return True

    @Slot()
    def reloadWaypoints(self):
        self._load_waypoints()
        self.waypointsChanged.emit()

        if self._selected_waypoint_id:
            self.selectedWaypointChanged.emit()
