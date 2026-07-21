import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: header

    property color panelColor: Theme.background
    property color borderColor: Theme.border
    property color accentColor: Theme.accent
    property color textColor: Theme.text
    property color secondaryTextColor: Theme.secondaryText
    property color successColor: Theme.success
    property color warningColor: Theme.warning

    property int radioChannel: 4
    property string radioChannelName: ""
    property string radioFrequency: ""
    property int gpsSatellites: 0

    property bool bluetoothConnected: false
    property bool radioConnected: true
    property bool transmitting: false

    property string mediaTitle: ""
    property string mediaArtist: ""
    property string clockText: ""

    implicitHeight: Theme.headerHeight
    color: panelColor

    function updateClock() {
        clockText = Qt.formatTime(new Date(), "h:mm")
    }

    function radioText() {
        if (radioChannelName.trim() !== "")
            return radioChannelName.toUpperCase()

        if (radioFrequency.trim() !== "")
            return radioFrequency.replace(/MHz/ig, "").trim()

        return "CH " + radioChannel
    }

    function validMediaTitle() {
        var value = mediaTitle.trim()

        return value !== ""
            && value !== "No media playing"
            && value !== "Bluetooth Audio"
            && value !== "PHONE CONNECTED"
            && value !== "Phone Connected"
    }

    function validMediaArtist() {
        var value = mediaArtist.trim()

        return value !== ""
            && value !== "Unknown Artist"
            && value !== "Connected phone"
            && value !== "Connect phone and start Spotify"
    }

    function displayTitle() {
        if (validMediaTitle())
            return mediaTitle.trim()

        if (bluetoothConnected)
            return "BT Connected"

        return "Bluetooth Disconnected"
    }

    function displaySubtitle() {
        if (validMediaTitle() && validMediaArtist())
            return mediaArtist.trim()

        if (validMediaTitle())
            return ""

        if (bluetoothConnected)
            return "Waiting for Media"

        return "Open Settings to Pair"
    }

    Component.onCompleted: updateClock()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: header.updateClock()
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 1
        color: header.borderColor
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 7
        anchors.bottomMargin: 7

        spacing: 16

        /*
         * GPS status
         */
        Item {
            Layout.preferredWidth: 58
            Layout.fillHeight: true

            Row {
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter

                    width: 10
                    height: 10
                    radius: 5

                    color: header.gpsSatellites > 0
                        ? header.successColor
                        : "#596168"
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter

                    text: header.gpsSatellites.toString()
                    color: header.textColor

                    font.pixelSize: Theme.gpsSize
                    font.bold: true
                }
            }
        }

        /*
         * Radio channel
         */
        Item {
            Layout.preferredWidth: 118
            Layout.fillHeight: true

            Text {
                anchors.fill: parent

                text: header.radioText()

                color: !header.radioConnected
                    ? "#596168"
                    : header.transmitting
                      ? header.warningColor
                      : header.textColor

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                elide: Text.ElideRight

                font.pixelSize: Theme.channelSize
                font.bold: true

                SequentialAnimation on opacity {
                    running: header.transmitting
                    loops: Animation.Infinite

                    NumberAnimation {
                        from: 1.0
                        to: 0.55
                        duration: 450
                    }

                    NumberAnimation {
                        from: 0.55
                        to: 1.0
                        duration: 450
                    }
                }
            }
        }

        /*
         * Media area
         */
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Row {
                anchors.fill: parent
                spacing: 10

                Icon {
                    anchors.verticalCenter: parent.verticalCenter

                    symbol: "music_note"
                    size: 23

                    iconColor: header.validMediaTitle()
                        ? header.textColor
                        : header.secondaryTextColor

                    filled: true
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter

                    width: parent.width - 33
                    spacing: 1

                    Text {
                        width: parent.width

                        text: header.displayTitle()
                        color: header.textColor

                        elide: Text.ElideRight

                        font.pixelSize: Theme.titleSize
                        font.bold: true
                    }

                    Text {
                        width: parent.width

                        text: header.displaySubtitle()
                        visible: text !== ""

                        color: header.secondaryTextColor
                        elide: Text.ElideRight

                        font.pixelSize: Theme.subtitleSize
                        font.bold: false
                    }
                }
            }
        }

        /*
         * Bluetooth status beside clock
         */
        Item {
            Layout.preferredWidth: 38
            Layout.fillHeight: true

            Icon {
                anchors.centerIn: parent

                symbol: header.bluetoothConnected
                    ? "bluetooth_connected"
                    : "bluetooth_disabled"

                size: 24

                iconColor: header.bluetoothConnected
                    ? header.accentColor
                    : "#596168"

                filled: header.bluetoothConnected
            }
        }

        /*
         * Clock
         */
        Item {
            Layout.preferredWidth: 68
            Layout.fillHeight: true

            Text {
                anchors.fill: parent

                text: header.clockText
                color: header.textColor

                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter

                font.pixelSize: Theme.clockSize
                font.bold: true
            }
        }
    }
}
