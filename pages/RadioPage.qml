import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string pageTitle: "RADIO"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff5d5d"
    property color successColor: "#55d889"

    // Supplied by main.qml.
    property int currentChannel: 4

    property string channelName: "CHASE"
    property string frequency: "151.6250"
    property int volume: 65
    property int squelch: 4
    property bool scanning: false
    property bool transmitting: false
    property bool receiving: false

    signal channelSelected(int channel)

    function selectPreviousChannel() {
        if (page.currentChannel > 1) {
            page.currentChannel--
            page.channelSelected(page.currentChannel)
        }
    }

    function selectNextChannel() {
        page.currentChannel++
        page.channelSelected(page.currentChannel)
    }

    Rectangle {
        anchors.fill: parent
        color: "#090d12"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 18

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1.7

                radius: 18
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 26
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "VHF RADIO"
                            color: page.textColor
                            font.pixelSize: 25
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            width: 88
                            height: 34
                            radius: 17

                            color: page.transmitting
                                   ? "#5a1717"
                                   : page.receiving
                                     ? "#153c2b"
                                     : "#1b2530"

                            border.width: 1

                            border.color: page.transmitting
                                          ? page.dangerColor
                                          : page.receiving
                                            ? page.successColor
                                            : page.borderColor

                            Label {
                                anchors.centerIn: parent

                                text: page.transmitting
                                      ? "TX"
                                      : page.receiving
                                        ? "RX"
                                        : "READY"

                                color: page.transmitting
                                       ? page.dangerColor
                                       : page.receiving
                                         ? page.successColor
                                         : page.secondaryTextColor

                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: "CHANNEL " + page.currentChannel
                        color: page.secondaryTextColor

                        font.pixelSize: 18
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: page.channelName
                        color: page.accentColor

                        font.pixelSize: 28
                        font.bold: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter

                        text: page.frequency + " MHz"
                        color: page.textColor

                        font.pixelSize: 52
                        font.bold: true
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 74
                        spacing: 12

                        Button {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            text: "CHANNEL -"

                            onClicked: page.selectPreviousChannel()
                        }

                        Button {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            text: "CHANNEL +"

                            onClicked: page.selectNextChannel()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1

                radius: 18
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 10

                    Label {
                        text: "RADIO CONTROLS"
                        color: page.textColor

                        font.pixelSize: 21
                        font.bold: true
                    }

                    Label {
                        text: "VOLUME  " + volumeSlider.value.toFixed(0) + "%"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Slider {
                        id: volumeSlider

                        Layout.fillWidth: true

                        from: 0
                        to: 100
                        value: page.volume

                        onMoved: page.volume = Math.round(value)
                    }

                    Label {
                        text: "SQUELCH  " + squelchSlider.value.toFixed(0)
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Slider {
                        id: squelchSlider

                        Layout.fillWidth: true

                        from: 0
                        to: 10
                        stepSize: 1
                        value: page.squelch

                        onMoved: page.squelch = Math.round(value)
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70

                        text: page.scanning ? "STOP SCAN" : "SCAN"

                        onClicked: page.scanning = !page.scanning
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: page.transmitting
                              ? "TRANSMITTING"
                              : "PUSH TO TALK"

                        onPressed: page.transmitting = true
                        onReleased: page.transmitting = false
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 58

                        text: "MONITOR"
                    }
                }
            }
        }
    }
}
