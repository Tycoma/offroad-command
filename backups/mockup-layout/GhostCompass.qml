import QtQuick
import QtQuick.Controls

Rectangle {
    id: compass

    property int heading: 0
    property color accentColor: "#2da8ff"
    property color textColor: "white"

    width: 150
    height: 150
    radius: 75

    opacity: 0.94
    color: "#b30b1016"

    border.width: 2
    border.color: "#99ffffff"

    function headingName(value) {
        if (value >= 337.5 || value < 22.5)
            return "N"

        if (value < 67.5)
            return "NE"

        if (value < 112.5)
            return "E"

        if (value < 157.5)
            return "SE"

        if (value < 202.5)
            return "S"

        if (value < 247.5)
            return "SW"

        if (value < 292.5)
            return "W"

        return "NW"
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 9

        text: "N"
        color: compass.accentColor

        font.pixelSize: 18
        font.bold: true
    }

    Item {
        anchors.centerIn: parent

        width: 96
        height: 96

        rotation: compass.heading

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            width: 7
            height: 44
            radius: 3

            color: compass.accentColor
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            width: 5
            height: 28
            radius: 2

            color: "#88ffffff"
        }
    }

    Rectangle {
        anchors.centerIn: parent

        width: 14
        height: 14
        radius: 7

        color: compass.textColor
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18

        text: compass.headingName(compass.heading)
              + "  "
              + compass.heading
              + " DEG"

        color: compass.textColor

        font.pixelSize: 14
        font.bold: true
    }
}
