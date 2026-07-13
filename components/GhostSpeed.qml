import QtQuick
import QtQuick.Controls

Rectangle {
    id: speedDisplay

    property int speed: 0
    property color textColor: "white"
    property color accentColor: "#2da8ff"

    width: 170
    height: 112
    radius: 18

    color: "#990b1016"
    opacity: 0.82

    border.width: 1
    border.color: "#88ffffff"

    Column {
        anchors.centerIn: parent
        spacing: -5

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: speedDisplay.speed
            color: speedDisplay.textColor

            font.pixelSize: 70
            font.bold: true
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "MPH"
            color: speedDisplay.accentColor

            font.pixelSize: 18
            font.bold: true
        }
    }
}
