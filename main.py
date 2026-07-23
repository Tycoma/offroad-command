import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QFontDatabase, QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWebEngineQuick import QtWebEngineQuick

from backend.console_log_model import ConsoleLogModel
from backend.gps_backend import GPSBackend
from backend.log_bridge import LogBridge
from backend.map_bridge import MapBridge
from backend.media_backend import MediaBackend
from backend.navigation_backend import NavigationBackend
from backend.vehicle_manager import VehicleManager
from backend.waypoint_manager import WaypointManager


def main() -> int:
    os.environ.setdefault(
        "QT_IM_MODULE",
        "qtvirtualkeyboard",
    )

    QtWebEngineQuick.initialize()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("Off-Road Command")

    project_root = Path(__file__).resolve().parent

    font_path = (
        project_root
        / "assets"
        / "fonts"
        / "MaterialSymbolsRounded.ttf"
    )

    font_id = QFontDatabase.addApplicationFont(
        str(font_path)
    )

    if font_id == -1:
        print(
            "ERROR: Failed to load Material Symbols font.",
            flush=True,
        )
        print(
            f"Expected at: {font_path}",
            flush=True,
        )
    else:
        print(
            "Loaded font:",
            QFontDatabase.applicationFontFamilies(
                font_id
            ),
            flush=True,
        )

    engine = QQmlApplicationEngine()

    console_log_model = ConsoleLogModel(
        maximum_entries=1500
    )

    log_bridge = LogBridge(
        console_log_model
    )

    navigation_backend = NavigationBackend()
    media_backend = MediaBackend()
    gps_backend = GPSBackend()
    waypoint_manager = WaypointManager()
    map_bridge = MapBridge()

    vehicle_manager = VehicleManager(
        gps_backend,
        media_backend,
        navigation_backend,
    )

    context = engine.rootContext()

    context.setContextProperty(
        "consoleLogModel",
        console_log_model,
    )

    context.setContextProperty(
        "logBridge",
        log_bridge,
    )

    context.setContextProperty(
        "navigationBackend",
        navigation_backend,
    )

    context.setContextProperty(
        "mediaBackend",
        media_backend,
    )

    context.setContextProperty(
        "gpsBackend",
        gps_backend,
    )

    context.setContextProperty(
        "vehicleManager",
        vehicle_manager,
    )

    context.setContextProperty(
        "waypointManager",
        waypoint_manager,
    )

    context.setContextProperty(
        "mapBridge",
        map_bridge,
    )

    map_bridge.waypointSelected.connect(
        waypoint_manager.setSelectedWaypoint
    )

    map_bridge.mapReady.connect(
        lambda: log_bridge.info(
            "MAP",
            "Leaflet map and WebChannel are ready",
        )
    )

    map_bridge.mapClicked.connect(
        lambda: log_bridge.debug(
            "MAP",
            "Map background clicked",
        )
    )

    map_bridge.waypointSelected.connect(
        lambda waypoint_id: log_bridge.info(
            "WAYPOINT",
            f"Waypoint selected: {waypoint_id}",
        )
    )

    map_bridge.gotoRequested.connect(
        lambda waypoint_id: log_bridge.info(
            "WAYPOINT",
            f"Go To requested: {waypoint_id}",
        )
    )

    log_bridge.info(
        "SYSTEM",
        "Developer logging backend started",
    )

    qml_file = project_root / "main.qml"

    log_bridge.info(
        "SYSTEM",
        f"Loading QML: {qml_file}",
    )

    engine.load(
        QUrl.fromLocalFile(
            str(qml_file)
        )
    )

    if not engine.rootObjects():
        log_bridge.error(
            "SYSTEM",
            f"Failed to load QML: {qml_file}",
        )
        return 1

    log_bridge.info(
        "SYSTEM",
        "Off-Road Command started",
    )

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
