import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: navigation

    property int currentPage: 0

    property color panelColor: "#0c1117"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"

    signal pageSelected(int pageNumber)

    implicitHeight: 78
    color: panelColor

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 1
        color: navigation.borderColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 7
        anchors.bottomMargin: 7

        spacing: 7

        Repeater {
            model: [
                { label: "MAPS", page: 0 },
                { label: "MEDIA", page: 1 },
                { label: "RADIO", page: 2 },
                { label: "ENGINE", page: 3 },
                { label: "CAMERAS", page: 4 },
                { label: "VEHICLE", page: 5 },
                { label: "SETTINGS", page: 6 }
            ]

            delegate: Rectangle {
                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true

                property bool selected:
                    navigation.currentPage === modelData.page

                radius: 10

                color: selected
                       ? "#12304a"
                       : buttonArea.pressed
                         ? "#17222d"
                         : "transparent"

                border.width: selected ? 1 : 0
                border.color: selected
                              ? navigation.accentColor
                              : "transparent"

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    height: 3
                    radius: 1.5

                    visible: parent.selected
                    color: navigation.accentColor
                }

                Text {
                    anchors.centerIn: parent

                    text: modelData.label

                    color: parent.selected
                           ? navigation.accentColor
                           : navigation.textColor

                    font.pixelSize: modelData.label.length > 6 ? 12 : 14
                    font.bold: true
                }

                MouseArea {
                    id: buttonArea

                    anchors.fill: parent

                    onClicked: {
                        navigation.pageSelected(modelData.page)
                    }
                }
            }
        }
    }
}
