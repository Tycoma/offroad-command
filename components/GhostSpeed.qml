import QtQuick

Rectangle {
    id: root

    property real speed: 0
    property color textColor: "#FFFFFF"
    property color borderColor: "#4A535C"

    width: 52
    height: 30
    radius: 5

    color: "#88000000"

    border.width: 1
    border.color: borderColor

    Text {
        anchors.centerIn: parent

        text: Math.round(root.speed).toString()
        color: root.textColor

        font.pixelSize: 17
        font.bold: true
    }
}
