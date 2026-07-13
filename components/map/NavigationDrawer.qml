import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Drawer {
    id: drawer

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"

    edge: Qt.LeftEdge
    modal: true
    interactive: true

    background: Rectangle {
        color: drawer.panelColor

        border.width: 1
        border.color: drawer.borderColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 10

        Label {
            text: "NAVIGATION"
            color: drawer.textColor

            font.pixelSize: 25
            font.bold: true
        }

        Label {
            text: "Routes, tracks, and saved locations"
            color: drawer.secondaryTextColor
            font.pixelSize: 13
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: drawer.borderColor
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 58

            text: "ROUTES"
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 58

            text: "WAYPOINTS"
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 58

            text: "RECORDED TRACKS"
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 58

            text: "FAVORITES"
        }

        Item {
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 54

            text: "CLOSE"

            onClicked: drawer.close()
        }
    }
}
