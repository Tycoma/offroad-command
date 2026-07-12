import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string pageTitle: "MEDIA"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff5d5d"
    property color successColor: "#55d889"

    Rectangle {
        anchors.fill: parent
        color: "#090d12"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 22

            Rectangle {
                Layout.preferredWidth: Math.min(
                    page.width * 0.36,
                    page.height * 0.72
                )

                Layout.fillHeight: true

                radius: 18
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: width

                        radius: 16
                        color: "#1d2935"

                        border.width: 1
                        border.color: page.borderColor

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: "♪"
                                color: page.accentColor
                                font.pixelSize: 88
                                font.bold: true
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: "BLUETOOTH AUDIO"
                                color: page.secondaryTextColor
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        radius: 10

                        color: mediaBackend.connected
                               ? "#153c2b"
                               : "#3b2c15"

                        border.width: 1

                        border.color: mediaBackend.connected
                                      ? page.successColor
                                      : page.warningColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6

                                color: mediaBackend.connected
                                       ? page.successColor
                                       : page.warningColor
                            }

                            Label {
                                text: mediaBackend.connected
                                      ? "PHONE CONNECTED"
                                      : "WAITING FOR PHONE"

                                color: page.textColor
                                font.pixelSize: 13
                                font.bold: true
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                text: "REFRESH"
                                onClicked: mediaBackend.refresh()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 18
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 28
                    spacing: 12

                    Label {
                        Layout.fillWidth: true

                        text: mediaBackend.title

                        color: page.textColor
                        elide: Text.ElideRight

                        font.pixelSize: 34
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true

                        text: mediaBackend.artist

                        color: page.accentColor
                        elide: Text.ElideRight

                        font.pixelSize: 23
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true

                        text: mediaBackend.album

                        visible: text.length > 0
                        color: page.secondaryTextColor
                        elide: Text.ElideRight

                        font.pixelSize: 17
                    }

                    Label {
                        text: mediaBackend.playbackStatus.toUpperCase()

                        color: mediaBackend.playbackStatus === "Playing"
                               ? page.successColor
                               : page.warningColor

                        font.pixelSize: 14
                        font.bold: true
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100

                        spacing: 20

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            Layout.preferredWidth: 96
                            Layout.fillHeight: true

                            text: "◀◀"
                            font.pixelSize: 30

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.previous()
                        }

                        Button {
                            Layout.preferredWidth: 126
                            Layout.fillHeight: true

                            text: mediaBackend.playbackStatus === "Playing"
                                  ? "❚❚"
                                  : "▶"

                            font.pixelSize: 40

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.playPause()
                        }

                        Button {
                            Layout.preferredWidth: 96
                            Layout.fillHeight: true

                            text: "▶▶"
                            font.pixelSize: 30

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.next()
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Label {
                        text: "OUTPUT VOLUME  " + volumeSlider.value.toFixed(0) + "%"

                        color: page.secondaryTextColor

                        font.pixelSize: 14
                        font.bold: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 66

                        spacing: 14

                        Label {
                            text: "−"
                            color: page.textColor
                            font.pixelSize: 30
                        }

                        Slider {
                            id: volumeSlider

                            Layout.fillWidth: true

                            from: 0
                            to: 100
                            stepSize: 1

                            value: mediaBackend.volume

                            onMoved: {
                                mediaBackend.setVolume(
                                    Math.round(value)
                                )
                            }
                        }

                        Label {
                            text: "+"
                            color: page.textColor
                            font.pixelSize: 30
                        }
                    }

                    Label {
                        Layout.fillWidth: true

                        visible: mediaBackend.error.length > 0
                        text: mediaBackend.error

                        color: page.dangerColor
                        wrapMode: Text.WordWrap

                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    Connections {
        target: mediaBackend

        function onVolumeChanged() {
            if (!volumeSlider.pressed)
                volumeSlider.value = mediaBackend.volume
        }
    }
}

