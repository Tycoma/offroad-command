import QtQuick
import QtQuick.Controls

Column {
    id: controls

    property bool toolsVisible: false

    signal zoomInRequested()
    signal zoomOutRequested()

    spacing: 8
    visible: toolsVisible
    opacity: toolsVisible ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 160
        }
    }

    Button {
        width: 64
        height: 58

        text: "+"
        font.pixelSize: 26

        onClicked: controls.zoomInRequested()
    }

    Button {
        width: 64
        height: 58

        text: "-"
        font.pixelSize: 26

        onClicked: controls.zoomOutRequested()
    }
}
