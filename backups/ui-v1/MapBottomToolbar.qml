import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: toolbar

    property bool toolsVisible: false
    property bool recording: false

    property color panelColor: "#ed0a0f15"
    property color borderColor: "#2a3947"

    signal waypointRequested()
    signal recordingRequested()
    signal routesRequested()
    signal tracksRequested()
    signal layersRequested()
    signal gotoRequested()

    height: 72
    radius: 12

    visible: opacity > 0
    opacity: toolsVisible ? 1 : 0

    color: panelColor

    border.width: 1
    border.color: borderColor

    Behavior on opacity {
        NumberAnimation {
            duration: 160
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: "WAYPOINT"

            onClicked: toolbar.waypointRequested()
        }

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: toolbar.recording ? "STOP" : "RECORD"

            onClicked: toolbar.recordingRequested()
        }

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: "ROUTES"

            onClicked: toolbar.routesRequested()
        }

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: "TRACKS"

            onClicked: toolbar.tracksRequested()
        }

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: "LAYERS"

            onClicked: toolbar.layersRequested()
        }

        Button {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: "GO TO"

            onClicked: toolbar.gotoRequested()
        }
    }
}
