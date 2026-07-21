import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: header

    property color panelColor: "#000000"
    property color borderColor: "#1d242b"
    property color accentColor: "#009cff"
    property color textColor: "#f7f7f7"
    property color secondaryTextColor: "#78a7d1"
    property color successColor: "#62e600"
    property color warningColor: "#ff9400"

    property int radioChannel: 4
    property string radioChannelName: ""
    property string radioFrequency: ""
    property int gpsSatellites: 0

    property bool bluetoothConnected: false
    property bool radioConnected: true
    property bool canConnected: false
    property bool transmitting: false
    property bool warningActive: false

    property string mediaTitle: ""
    property string mediaArtist: ""
    property string clockText: ""

    implicitHeight: 82
    color: panelColor

    function updateClock() {
        clockText = Qt.formatTime(new Date(), "HH:mm")
    }

    function radioText() {
        if (radioChannelName.trim() !== "")
            return radioChannelName.toUpperCase()

        if (radioFrequency.trim() !== "")
            return radioFrequency.replace(/MHz/ig, "").trim()

        return "CH " + radioChannel
    }

    function cleanTitle() {
        var value = mediaTitle.trim()

        if (value === ""
                || value === "No media playing"
                || value === "Bluetooth Audio") {
            return bluetoothConnected ? "PHONE CONNECTED" : "NO MEDIA"
        }

        return value
    }

    function cleanArtist() {
        var value = mediaArtist.trim()

        if (value === ""
                || value === "Connect phone and start Spotify"
                || value === "Connected phone"
                || value === "Unknown Artist") {
            return ""
        }

        return value
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
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        spacing: 18

        Row {
            Layout.preferredWidth: 110
            Layout.fillHeight: true
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "GPS"
                color: header.textColor
                font.pixelSize: 25
                font.bold: true
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 15
                height: 15
                radius: 8
                color: header.gpsSatellites > 0
                       ? header.successColor
                       : "#666666"
            }
        }

        Text {
            Layout.preferredWidth: 48
            Layout.fillHeight: true

            text: "ᛒ"
            color: header.bluetoothConnected
                   ? header.accentColor
                   : "#6c747b"

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: 38
            font.bold: true
        }

        Text {
            Layout.preferredWidth: 150
            Layout.fillHeight: true

            text: header.radioText()
            color: header.textColor

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            elide: Text.ElideRight

            font.pixelSize: 29
            font.bold: true
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 48
            color: "#5a5a5a"
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Row {
                anchors.fill: parent
                anchors.leftMargin: 18
                spacing: 16

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "♫"
                    color: header.textColor
                    font.pixelSize: 42
                    font.bold: true
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 72
                    spacing: 0

                    Text {
                        width: parent.width
                        text: header.cleanTitle()
                        color: header.textColor
                        elide: Text.ElideRight
                        font.pixelSize: 24
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        text: header.cleanArtist()
                        visible: text !== ""
                        color: header.secondaryTextColor
                        elide: Text.ElideRight
                        font.pixelSize: 18
                        font.bold: true
                    }
                }
            }
        }

        Row {
            Layout.preferredWidth: 120
            Layout.fillHeight: true
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "◉"
                color: header.radioConnected
                       ? header.successColor
                       : "#666666"
                font.pixelSize: 35
                font.bold: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "TX"
                color: header.transmitting
                       ? header.warningColor
                       : "#7a7f84"
                font.pixelSize: 21
                font.bold: true
            }
        }

        Item {
            Layout.preferredWidth: 78
            Layout.fillHeight: true

            Canvas {
                anchors.centerIn: parent
                width: 54
                height: 46

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    ctx.strokeStyle = header.textColor
                    ctx.lineWidth = 2.5

                    ctx.strokeRect(20, 3, 14, 10)
                    ctx.strokeRect(3, 30, 14, 10)
                    ctx.strokeRect(37, 30, 14, 10)

                    ctx.beginPath()
                    ctx.moveTo(27, 13)
                    ctx.lineTo(27, 22)
                    ctx.lineTo(10, 22)
                    ctx.lineTo(10, 30)

                    ctx.moveTo(27, 22)
                    ctx.lineTo(44, 22)
                    ctx.lineTo(44, 30)
                    ctx.stroke()
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 8
                anchors.bottomMargin: 13

                width: 14
                height: 14
                radius: 7

                color: header.canConnected
                       ? header.successColor
                       : "#666666"
            }
        }

        Text {
            Layout.preferredWidth: 105
            Layout.fillHeight: true

            text: header.clockText
            color: header.textColor

            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter

            font.pixelSize: 27
            font.bold: true
        }
    }
}
