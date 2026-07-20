import QtQuick
import QtQuick.Controls

Rectangle {
    id: compass

    property int heading: 0
    property color accentColor: "#2da8ff"
    property color textColor: "white"

    width: 72
    height: 72
    radius: 12

    color: "#b30b1016"
    opacity: 0.92

    border.width: 0

    function normalizedHeading(value) {
        var normalized = value % 360

        if (normalized < 0)
            normalized += 360

        return normalized
    }

    function headingName(value) {
        var headingValue = normalizedHeading(value)

        if (headingValue >= 337.5 || headingValue < 22.5)
            return "N"

        if (headingValue < 67.5)
            return "NE"

        if (headingValue < 112.5)
            return "E"

        if (headingValue < 157.5)
            return "SE"

        if (headingValue < 202.5)
            return "S"

        if (headingValue < 247.5)
            return "SW"

        if (headingValue < 292.5)
            return "W"

        return "NW"
    }

    Label {
        anchors.centerIn: parent

        text: compass.headingName(compass.heading)
        color: compass.textColor

        font.pixelSize: 31
        font.bold: true
    }
}
