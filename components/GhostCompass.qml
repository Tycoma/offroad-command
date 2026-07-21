import QtQuick

Rectangle {
    id: root

    property real heading: 0
    property color textColor: "#FFFFFF"
    property color borderColor: "#4A535C"

    width: 52
    height: 30
    radius: 5

    color: "#88000000"

    border.width: 1
    border.color: borderColor

    function cardinalDirection(value) {
        var normalized = ((value % 360) + 360) % 360

        if (normalized >= 337.5 || normalized < 22.5)
            return "N"
        if (normalized < 67.5)
            return "NE"
        if (normalized < 112.5)
            return "E"
        if (normalized < 157.5)
            return "SE"
        if (normalized < 202.5)
            return "S"
        if (normalized < 247.5)
            return "SW"
        if (normalized < 292.5)
            return "W"

        return "NW"
    }

    Text {
        anchors.centerIn: parent

        text: root.cardinalDirection(root.heading)
        color: root.textColor

        font.pixelSize: 17
        font.bold: true
    }
}
