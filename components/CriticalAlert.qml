import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: alert

    property string warningText: ""
    property color dangerColor: "#ff3b3b"

    signal acknowledged()

    visible: warningText !== ""

    height: 105
    color: dangerColor

    border.width: 4
    border.color: "white"

    SequentialAnimation on opacity {
        running: alert.visible
        loops: Animation.Infinite

        NumberAnimation {
            from: 1.0
            to: 0.35
            duration: 420
        }

        NumberAnimation {
            from: 0.35
            to: 1.0
            duration: 420
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 28
        anchors.rightMargin: 28

        spacing: 24

        Label {
            text: "WARNING"
            color: "white"

            font.pixelSize: 29
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 3
            Layout.fillHeight: true
            Layout.topMargin: 16
            Layout.bottomMargin: 16

            color: "white"
        }

        Label {
            Layout.fillWidth: true

            text: alert.warningText
            color: "white"

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: 27
            font.bold: true
        }

        Button {
            Layout.preferredWidth: 125
            Layout.preferredHeight: 60

            text: "ACKNOWLEDGE"

            onClicked: alert.acknowledged()
        }
    }
}
