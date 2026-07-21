import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property int speed: 0

    property color textColor: "white"
    property color secondaryTextColor: "#7590a8"

    // Added so main.qml can set this property
    property color accentColor: "#2DA8FF"

    width: 92
    height: 82
    radius: 12

    color: "#e6080d12"
    border.width: 0

    Column {
        anchors.centerIn: parent
        spacing: -3

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.speed
            color: root.textColor
            font.pixelSize: 44
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "(GPS)"
            color: root.secondaryTextColor
            font.pixelSize: 13
            font.bold: true
        }
    }
}
