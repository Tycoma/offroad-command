import QtQuick
import QtQuick.Controls

Rectangle {
    id: compass

    property int heading: 0
    property color accentColor: "#2da8ff"
    property color textColor: "white"

    width: 132
    height: 132
    radius: 66

    opacity: 0.46
    color: "#80101820"

    border.width: 2
    border.color: textColor

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

    Item {
        anchors.centerIn: parent

        width: 90
        height: 90

        rotation: compass.heading

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            width: 4
            height: 42
            radius: 2

            color: compass.accentColor
        }
    }

    Rectangle {
        anchors.centerIn: parent

        width: 12
        height: 12
        radius: 6

        color: compass.textColor
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8

        text: "N"
        color: compass.textColor

        font.pixelSize: 16
        font.bold: true
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14

        text: compass.headingName(compass.heading)
              + "  "
              + compass.heading
              + " DEG"

        color: compass.textColor

        font.pixelSize: 13
        font.bold: true
    }
}
