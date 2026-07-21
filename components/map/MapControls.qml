import QtQuick
import QtQuick.Controls

Column {
    id: controls

    property bool toolsVisible: false
    property color accentColor: "#168fe8"
    property color textColor: "#ffffff"
    property color borderColor: "#66717a"

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

    component MapControlButton: Rectangle {
        id: controlButton

        property string symbol: ""
        signal clicked()

        width: 62
        height: 58
        radius: 7

        color: mouseArea.pressed
               ? "#ff182028"
               : "#ed000000"

        border.width: 1
        border.color: controls.borderColor

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2

            text: controlButton.symbol
            color: controls.textColor

            font.pixelSize: 34
            font.weight: Font.Light
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: controlButton.clicked()
        }
    }

    MapControlButton {
        symbol: "+"

        onClicked: controls.zoomInRequested()
    }

    MapControlButton {
        symbol: "\u2212"

        onClicked: controls.zoomOutRequested()
    }
}
