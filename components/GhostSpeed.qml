import QtQuick
import QtQuick.Controls

Rectangle {
    id: speedDisplay

    property int speed: 0
    property color textColor: "white"
    property color accentColor: "#2da8ff"

    width: 190
    height: 118
    radius: 18

    color: "#b30b1016"
    opacity: 0.92

    border.width: 2
    border.color: "#99ffffff"

    Column {
        anchors.centerIn: parent
        spacing: -4

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: speedDisplay.speed
            color: speedDisplay.textColor

            font.pixelSize: 72
            font.bold: true
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "MPH"
            color: speedDisplay.accentColor

            font.pixelSize: 20
            font.bold: true
        }
    }
}
