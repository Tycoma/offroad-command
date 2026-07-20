import os
import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWebEngineQuick import QtWebEngineQuick

from backend.media_backend import MediaBackend
from backend.navigation_backend import NavigationBackend


def main() -> int:
    os.environ.setdefault(
	"QT_IM_MODULE",
	"qtvirtualkeyboard"
    )

    QtWebEngineQuick.initialize()

    app = QGuiApplication(sys.argv)
    app.setApplicationName("Off-Road Command")

    engine = QQmlApplicationEngine()

    navigation_backend = NavigationBackend()
    media_backend = MediaBackend()

    engine.rootContext().setContextProperty(
        "navigationBackend",
        navigation_backend,
    )

    engine.rootContext().setContextProperty(
        "mediaBackend",
        media_backend,
    )

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print(f"Failed to load QML: {qml_file}")
        return 1

    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
