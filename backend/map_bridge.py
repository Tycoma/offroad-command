from PySide6.QtCore import QObject, Signal, Slot


class MapBridge(QObject):
    """
    Communication bridge between the Leaflet map,
    QML, and the Python backend.
    """

    mapReady = Signal()
    mapClicked = Signal()
    mapPressed = Signal(float, float)
    waypointSelected = Signal(str)
    gotoRequested = Signal(str)

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setObjectName("mapBridge")

    @Slot()
    def pageLoaded(self):
        print("Map bridge: page ready", flush=True)
        self.mapReady.emit()

    @Slot()
    def notifyMapClicked(self):
        print("Map bridge: map clicked", flush=True)
        self.mapClicked.emit()

    @Slot(float, float)
    def mapPressedSlot(
        self,
        latitude,
        longitude,
    ):
        print(
            f"Map pressed: {latitude:.6f}, {longitude:.6f}",
            flush=True,
        )

        self.mapPressed.emit(
            latitude,
            longitude,
        )

    @Slot(str)
    def selectWaypoint(self, waypoint_id):
        cleaned_id = waypoint_id.strip()

        if not cleaned_id:
            print("Map bridge: ignored empty waypoint ID", flush=True)
            return

        print(
            f"Map bridge: waypoint selected: {cleaned_id}",
            flush=True,
        )

        self.waypointSelected.emit(cleaned_id)

    @Slot(str)
    def requestGoto(self, waypoint_id):
        cleaned_id = waypoint_id.strip()

        if not cleaned_id:
            print("Map bridge: ignored empty Go To ID", flush=True)
            return

        print(
            f"Map bridge: Go To requested: {cleaned_id}",
            flush=True,
        )

        self.gotoRequested.emit(cleaned_id)
