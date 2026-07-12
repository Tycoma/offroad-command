import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string pageTitle: "HOME"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"

    signal openPage(int pageNumber)

    GridLayout {
        anchors.fill: parent
        anchors.margins: 18

        columns: 3
        rows: 2

        rowSpacing: 16
        columnSpacing: 16

        Repeater {
            model: [
                {
                    title: "MAPS",
                    subtitle: "Offline maps, routes, tracks and waypoints",
                    page: 1
                },
                {
                    title: "RADIO",
                    subtitle: "VHF radio and intercom controls",
                    page: 2
                },
                {
                    title: "ENGINE",
                    subtitle: "MEFI-4 gauges and diagnostics",
                    page: 3
                },
                {
                    title: "CAMERAS",
                    subtitle: "Front, rear and auxiliary cameras",
                    page: 4
                },
                {
                    title: "VEHICLE",
                    subtitle: "Lights, compressor and PDM controls",
                    page: 5
                },
                {
                    title: "SETTINGS",
                    subtitle: "Display, GPS, CAN and Bluetooth",
                    page: 6
                }
            ]

            delegate: Button {
                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true

                onClicked: page.openPage(modelData.page)

                background: Rectangle {
                    radius: 14
                    color: parent.down ? "#1b2530" : page.panelColor

                    border.width: parent.hovered ? 2 : 1
                    border.color: parent.hovered
                                  ? page.accentColor
                                  : page.borderColor
                }

                contentItem: ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20

                    Item {
                        Layout.fillHeight: true
                    }

                    Label {
                        text: modelData.title
                        color: page.textColor

                        font.pixelSize: 23
                        font.bold: true
                    }

                    Label {
                        Layout.fillWidth: true

                        text: modelData.subtitle
                        wrapMode: Text.WordWrap

                        color: page.secondaryTextColor
                        font.pixelSize: 14
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
