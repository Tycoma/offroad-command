import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: header

    property color panelColor: "#0c1117"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"

    property int radioChannel: 4
    property int gpsSatellites: 12

    property bool bluetoothConnected: false
    property string mediaTitle: ""
    property string mediaArtist: ""

    implicitHeight: 62
    color: panelColor

    border.width: 1
    border.color: borderColor

    function nowPlayingText() {
        if (
            bluetoothConnected
            && mediaTitle !== ""
            && mediaTitle !== "No media playing"
            && mediaTitle !== "Bluetooth Audio"
        ) {
            var value = mediaTitle

            if (
                mediaArtist !== ""
                && mediaArtist !== "Connected phone"
            ) {
                value += " - " + mediaArtist
            }

            return "NOW PLAYING  " + value
        }

        if (bluetoothConnected)
            return "BLUETOOTH AUDIO READY"

        return "NO PHONE CONNECTED"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18

        spacing: 18

        Label {
            text: "RADIO  CH " + header.radioChannel
            color: header.textColor

            font.pixelSize: 16
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 2
            Layout.preferredHeight: 28
            color: header.borderColor
        }

        Label {
            text: "GPS  " + header.gpsSatellites + " SAT"
            color: header.textColor

            font.pixelSize: 16
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 2
            Layout.preferredHeight: 28
            color: header.borderColor
        }

        Label {
            text: header.bluetoothConnected
                  ? "BT CONNECTED"
                  : "BT OFFLINE"

            color: header.bluetoothConnected
                   ? header.accentColor
                   : header.secondaryTextColor

            font.pixelSize: 16
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 2
            Layout.preferredHeight: 28
            color: header.borderColor
        }

        Label {
            Layout.fillWidth: true

            text: header.nowPlayingText()

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: header.accentColor

            font.pixelSize: 16
            font.bold: true

            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Rectangle {
            Layout.preferredWidth: 2
            Layout.preferredHeight: 28
            color: header.borderColor
        }

        Label {
            id: clockLabel

            text: Qt.formatTime(new Date(), "h:mm AP")
            color: header.textColor

            font.pixelSize: 18
            font.bold: true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            clockLabel.text =
                    Qt.formatTime(new Date(), "h:mm AP")
        }
    }
}
