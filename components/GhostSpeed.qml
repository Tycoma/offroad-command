import QtQuick
import QtQuick.Controls

Item {
    id: speedDisplay

    property int speed: 0
    property color textColor: "white"

    width: 180
    height: 110

    opacity: 0.42

    Column {
        anchors.centerIn: parent
        spacing: -6

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: speedDisplay.speed
            color: speedDisplay.textColor

            font.pixelSize: 76
            font.bold: true
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            text: "MPH"
            color: speedDisplay.textColor

            font.pixelSize: 19
            font.bold: true
        }
    }
}
