import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "pages"
import "components"

ApplicationWindow {
    id: root

    visible: true
    visibility: Window.FullScreen

    width: 1280
    height: 800

    title: "Off-Road Command"
    color: "#090d12"

    property int currentPage: 0

    readonly property color backgroundColor: "#090d12"
    readonly property color panelColor: "#141b23"
    readonly property color borderColor: "#2a3947"
    readonly property color accentColor: "#2da8ff"
    readonly property color textColor: "#f4f7fa"
    readonly property color secondaryTextColor: "#8fa1b2"
    readonly property color warningColor: "#ffb347"
    readonly property color dangerColor: "#ff5d5d"
    readonly property color successColor: "#55d889"

    function changePage(pageNumber) {
        currentPage = pageNumber
        pageStack.currentIndex = pageNumber
    }

    function nowPlayingText() {
        if (
            mediaBackend.connected
            && mediaBackend.title !== ""
            && mediaBackend.title !== "No media playing"
            && mediaBackend.title !== "Bluetooth Audio"
        ) {
            var songText = mediaBackend.title

            if (
                mediaBackend.artist !== ""
                && mediaBackend.artist !== "Connected phone"
            ) {
                songText += " - " + mediaBackend.artist
            }

            return "NOW PLAYING  " + songText
        }

        if (mediaBackend.connected)
            return "BLUETOOTH AUDIO READY"

        return "NO PHONE CONNECTED"
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.close()
    }

    Shortcut {
        sequence: "F11"

        onActivated: {
            if (root.visibility === Window.FullScreen)
                root.visibility = Window.Windowed
            else
                root.visibility = Window.FullScreen
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62

            color: "#0c1117"

            border.width: 1
            border.color: root.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18

                spacing: 18

                Label {
                    text: "RADIO  CH 4"
                    color: root.textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 28
                    color: root.borderColor
                }

                Label {
                    text: "GPS  12 SAT"
                    color: root.textColor
                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 28
                    color: root.borderColor
                }

                Label {
                    text: mediaBackend.connected
                          ? "BT CONNECTED"
                          : "BT OFFLINE"

                    color: mediaBackend.connected
                           ? root.accentColor
                           : root.secondaryTextColor

                    font.pixelSize: 16
                    font.bold: true
                }

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 28
                    color: root.borderColor
                }

                Label {
                    Layout.fillWidth: true

                    text: root.nowPlayingText()

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    color: root.accentColor

                    font.pixelSize: 16
                    font.bold: true

                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Rectangle {
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 28
                    color: root.borderColor
                }

                Label {
                    id: clockLabel

                    text: Qt.formatTime(new Date(), "h:mm AP")
                    color: root.textColor

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

        StackLayout {
            id: pageStack

            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: root.currentPage

            MapsPage {
                panelColor: root.panelColor
                borderColor: root.borderColor
                accentColor: root.accentColor
                textColor: root.textColor
                secondaryTextColor: root.secondaryTextColor
                warningColor: root.warningColor
                dangerColor: root.dangerColor
                successColor: root.successColor
            }

            RadioPage {
                panelColor: root.panelColor
                borderColor: root.borderColor
                accentColor: root.accentColor
                textColor: root.textColor
                secondaryTextColor: root.secondaryTextColor
                warningColor: root.warningColor
                dangerColor: root.dangerColor
                successColor: root.successColor
            }

            PlaceholderPage {
                pageTitle: "ENGINE"
                description: "MEFI-4 engine gauges and diagnostics"
            }

            PlaceholderPage {
                pageTitle: "CAMERAS"
                description: "Vehicle camera system"
            }

            PlaceholderPage {
                pageTitle: "VEHICLE"
                description: "Lights, compressor and PDM controls"
            }

            PlaceholderPage {
                pageTitle: "SETTINGS"
                description: "Display and connection settings"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70

            color: "#0c1117"

            border.width: 1
            border.color: root.borderColor

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                spacing: 8

                NavButton {
                    text: "MAPS"
                    selected: root.currentPage === 0
                    onClicked: root.changePage(0)
                }

                NavButton {
                    text: "MEDIA"
                    selected: root.currentPage === 1
                    onClicked: root.changePage(1)
                }

                NavButton {
                    text: "ENGINE"
                    selected: root.currentPage === 2
                    onClicked: root.changePage(2)
                }

                NavButton {
                    text: "CAMERAS"
                    selected: root.currentPage === 3
                    onClicked: root.changePage(3)
                }

                NavButton {
                    text: "VEHICLE"
                    selected: root.currentPage === 4
                    onClicked: root.changePage(4)
                }

                NavButton {
                    text: "SETTINGS"
                    selected: root.currentPage === 5
                    onClicked: root.changePage(5)
                }
            }
        }
    }
}
