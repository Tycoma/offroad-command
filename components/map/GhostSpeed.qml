import QtQuick

Rectangle {
    id: root

    property real speed: 0
    property color textColor: "#FFFFFF"
    property color borderColor: "#5A6772"

    width: 62
    height: 36

    radius: 6

    color: "#A6000000"

    border.width: 1
    border.color: borderColor

    Text {
        anchors.centerIn: parent

        text: Math.round(root.speed).toString()

        color: root.textColor

        font.pixelSize: 20
        font.bold: true

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
