import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

Item {
    id: page

    property string pageTitle: "MEDIA"

    property color panelColor: "#0d1319"
    property color borderColor: "#3a4b58"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff5d5d"
    property color successColor: "#55d889"

    readonly property color backgroundColor: "#07090c"

    // Data-field style corner tag that straddles a panel's top border,
    // matching Garmin aviation-unit instrument boxes.
    component CornerTag: Item {
        property string tagText: ""
        property color bgColor: "#000000"
        property color tagColor: "#8fa1b2"

        x: 14
        y: -9

        width: tagLabel.implicitWidth + 10
        height: tagLabel.implicitHeight + 2

        Rectangle {
            anchors.fill: parent
            color: parent.bgColor
        }

        Label {
            id: tagLabel
            anchors.centerIn: parent

            text: parent.tagText
            color: parent.tagColor

            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 1
            font.capitalization: Font.AllUppercase
        }
    }

    Rectangle {
        anchors.fill: parent
        color: page.backgroundColor

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 22

            Rectangle {
                id: sourcePanel

                Layout.preferredWidth: Math.min(
                    page.width * 0.36,
                    page.height * 0.72
                )

                Layout.fillHeight: true

                radius: 4
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                CornerTag {
                    tagText: "Audio Source"
                    bgColor: page.backgroundColor
                    tagColor: page.secondaryTextColor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: width

                        radius: 4
                        color: "#12181f"

                        border.width: 1
                        border.color: page.borderColor

                        Column {
                            anchors.centerIn: parent
                            spacing: 12

                            Icon {
                                anchors.horizontalCenter: parent.horizontalCenter

                                symbol: "graphic_eq"
                                size: 76
                                iconColor: page.accentColor
                                filled: true
                            }

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter

                                text: "BLUETOOTH AUDIO"
                                color: page.secondaryTextColor
                                font.pixelSize: 14
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        radius: 3

                        color: mediaBackend.connected
                               ? "#102117"
                               : "#231a0c"

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
                                radius: 2

                                color: mediaBackend.connected
                                       ? page.successColor
                                       : page.warningColor
                            }

                            Label {
                                text: mediaBackend.connected
                                      ? "PHONE LINK — CONNECTED"
                                      : "PHONE LINK — WAITING"

                                color: page.textColor
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 0.5
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                Layout.preferredWidth: 96
                                Layout.preferredHeight: 36

                                onClicked: mediaBackend.refresh()

                                background: Rectangle {
                                    radius: 3
                                    color: parent.down ? "#232b33" : "#1a2129"
                                    border.width: 1
                                    border.color: page.borderColor
                                }

                                contentItem: RowLayout {
                                    spacing: 4

                                    Icon {
                                        symbol: "refresh"
                                        size: 16
                                        iconColor: page.textColor
                                    }

                                    Label {
                                        text: "REFRESH"
                                        color: page.textColor
                                        font.pixelSize: 11
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: nowPlayingPanel

                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 4
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    width: 4
                    radius: 2
                    color: page.accentColor
                }

                CornerTag {
                    tagText: "Now Playing"
                    bgColor: page.backgroundColor
                    tagColor: page.secondaryTextColor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 34
                    anchors.topMargin: 28
                    anchors.rightMargin: 28
                    anchors.bottomMargin: 28
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true

                            text: mediaBackend.title

                            color: page.textColor
                            elide: Text.ElideRight

                            font.pixelSize: 34
                            font.bold: true
                        }

                        Rectangle {
                            Layout.preferredWidth: statusLabel.implicitWidth + 20
                            Layout.preferredHeight: 30

                            radius: 3
                            color: mediaBackend.playbackStatus === "Playing"
                                   ? "#102117"
                                   : "#20242b"

                            border.width: 1
                            border.color: mediaBackend.playbackStatus === "Playing"
                                          ? page.successColor
                                          : page.secondaryTextColor

                            Label {
                                id: statusLabel
                                anchors.centerIn: parent

                                text: mediaBackend.playbackStatus.toUpperCase()

                                color: mediaBackend.playbackStatus === "Playing"
                                       ? page.successColor
                                       : page.secondaryTextColor

                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 1
                            }
                        }
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

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108

                        spacing: 16

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            Layout.preferredWidth: 96
                            Layout.fillHeight: true

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.previous()

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? "#232b33" : "#171d24"
                                border.width: 1
                                border.color: page.borderColor
                            }

                            contentItem: ColumnLayout {
                                spacing: 4

                                Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    symbol: "skip_previous"
                                    size: 34
                                    iconColor: mediaBackend.connected
                                               ? page.textColor
                                               : page.secondaryTextColor
                                    filled: true
                                }

                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "PREV"
                                    color: page.secondaryTextColor
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        Button {
                            Layout.preferredWidth: 132
                            Layout.fillHeight: true

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.playPause()

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? "#1f6cb8" : page.accentColor
                                opacity: parent.enabled ? 1.0 : 0.4
                                border.width: 1
                                border.color: "#1f6cb8"
                            }

                            contentItem: ColumnLayout {
                                spacing: 4

                                Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    symbol: mediaBackend.playbackStatus === "Playing"
                                            ? "pause"
                                            : "play_arrow"
                                    size: 40
                                    iconColor: "#07090c"
                                    filled: true
                                }

                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: mediaBackend.playbackStatus === "Playing"
                                          ? "PAUSE"
                                          : "PLAY"
                                    color: "#07090c"
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        Button {
                            Layout.preferredWidth: 96
                            Layout.fillHeight: true

                            enabled: mediaBackend.connected

                            onClicked: mediaBackend.next()

                            background: Rectangle {
                                radius: 4
                                color: parent.down ? "#232b33" : "#171d24"
                                border.width: 1
                                border.color: page.borderColor
                            }

                            contentItem: ColumnLayout {
                                spacing: 4

                                Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    symbol: "skip_next"
                                    size: 34
                                    iconColor: mediaBackend.connected
                                               ? page.textColor
                                               : page.secondaryTextColor
                                    filled: true
                                }

                                Label {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "NEXT"
                                    color: page.secondaryTextColor
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: "OUTPUT VOLUME"
                            color: page.secondaryTextColor
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 1
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 26

                            radius: 3
                            color: "#12181f"
                            border.width: 1
                            border.color: page.borderColor

                            Label {
                                anchors.centerIn: parent

                                text: volumeSlider.value.toFixed(0) + "%"
                                color: page.textColor

                                font.pixelSize: 14
                                font.bold: true
                                font.family: "monospace"
                            }
                        }
                    }

                    Slider {
                        id: volumeSlider

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34

                        from: 0
                        to: 100
                        stepSize: 1

                        value: mediaBackend.volume

                        onMoved: {
                            mediaBackend.setVolume(
                                Math.round(value)
                            )
                        }

                        background: Rectangle {
                            x: volumeSlider.leftPadding
                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: volumeSlider.availableWidth
                            height: 10

                            radius: 2
                            color: "#12181f"
                            border.width: 1
                            border.color: page.borderColor

                            Rectangle {
                                width: volumeSlider.visualPosition * parent.width
                                height: parent.height

                                radius: 2
                                color: page.accentColor
                            }

                            Repeater {
                                model: 11

                                delegate: Rectangle {
                                    property real fraction: index / 10

                                    x: fraction * parent.width - width / 2
                                    y: -7

                                    width: 1
                                    height: index % 5 === 0 ? 7 : 4
                                    color: page.secondaryTextColor
                                }
                            }
                        }

                        handle: Rectangle {
                            x: volumeSlider.leftPadding
                                + volumeSlider.visualPosition
                                    * (volumeSlider.availableWidth - width)

                            y: volumeSlider.topPadding
                                + volumeSlider.availableHeight / 2
                                - height / 2

                            width: 6
                            height: 28

                            radius: 1
                            color: page.textColor
                            border.width: 1
                            border.color: page.accentColor
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
