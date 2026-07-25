import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property real waypointLatitude: 0
    property real waypointLongitude: 0
    property string waypointName: ""
    property string waypointNotes: ""
    property string waypointCategory: "Waypoint"
    property bool editorVisible: false

    signal saveRequested(
        string name,
        string category,
        string notes,
        real latitude,
        real longitude
    )

    signal cancelRequested()

    width: parent ? parent.width : 800
    height: parent ? parent.height : 500

    anchors.left: parent.left
    anchors.right: parent.right

    radius: 24
    color: "#171B20"
    border.color: "#343A40"
    border.width: 1

    visible: y < (parent ? parent.height : 0)

    y: editorVisible
       ? 0
       : (parent ? parent.height : height)

    Behavior on y {
        NumberAnimation {
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    function openEditor(latitude, longitude) {
        waypointLatitude = latitude
        waypointLongitude = longitude
        waypointName = ""
        waypointNotes = ""
        waypointCategory = "Waypoint"

        nameField.text = ""
        notesField.text = ""
        categoryCombo.currentIndex = 0

        editorVisible = true
        nameField.forceActiveFocus()
    }

    function closeEditor() {
        editorVisible = false
        nameField.focus = false
        notesField.focus = false
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true

        ColumnLayout {
            width: parent.width
            spacing: 10

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 6
                radius: 3
                color: "#687078"
            }

            Label {
                text: "NEW WAYPOINT"
                color: "#FFFFFF"
                font.pixelSize: 24
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text: waypointLatitude.toFixed(6)
                      + ", "
                      + waypointLongitude.toFixed(6)
                color: "#9FA8B2"
                font.pixelSize: 15
                Layout.fillWidth: true
            }

            TextField {
                id: nameField

                Layout.fillWidth: true
                Layout.preferredHeight: 54

                placeholderText: "Waypoint name"
                color: "#FFFFFF"
                placeholderTextColor: "#7E8790"
                font.pixelSize: 18

                background: Rectangle {
                    radius: 10
                    color: "#252A30"
                    border.color: nameField.activeFocus ? "#4EA3FF" : "#3C434B"
                    border.width: 1
                }
            }

            ComboBox {
                id: categoryCombo

                Layout.fillWidth: true
                Layout.preferredHeight: 54

                model: [
                    "Waypoint",
                    "Fuel",
                    "Camp",
                    "Pit",
                    "Hazard",
                    "Obstacle",
                    "Favorite"
                ]

                font.pixelSize: 17

                background: Rectangle {
                    radius: 10
                    color: "#252A30"
                    border.color: categoryCombo.activeFocus
                                  ? "#4EA3FF"
                                  : "#3C434B"
                    border.width: 1
                }

                contentItem: Text {
                    text: categoryCombo.displayText
                    color: "#FFFFFF"
                    font: categoryCombo.font
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 14
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 70

                TextArea {
                    id: notesField

                    placeholderText: "Optional notes"
                    color: "#FFFFFF"
                    placeholderTextColor: "#7E8790"
                    font.pixelSize: 17
                    wrapMode: TextArea.Wrap

                    background: Rectangle {
                        radius: 10
                        color: "#252A30"
                        border.color: notesField.activeFocus
                                      ? "#4EA3FF"
                                      : "#3C434B"
                        border.width: 1
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58

                    text: "Cancel"
                    font.pixelSize: 18
                    font.bold: true

                    onClicked: {
                        root.closeEditor()
                        root.cancelRequested()
                    }

                    background: Rectangle {
                        radius: 12
                        color: parent.down ? "#3C434B" : "#2B3036"
                        border.color: "#555E67"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#FFFFFF"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58

                    text: "Save"
                    enabled: nameField.text.trim().length > 0
                    font.pixelSize: 18
                    font.bold: true

                    onClicked: {
                        root.waypointName = nameField.text.trim()
                        root.waypointCategory = categoryCombo.currentText
                        root.waypointNotes = notesField.text.trim()

                        root.saveRequested(
                            root.waypointName,
                            root.waypointCategory,
                            root.waypointNotes,
                            root.waypointLatitude,
                            root.waypointLongitude
                        )

                        root.closeEditor()
                    }

                    background: Rectangle {
                        radius: 12

                        color: !parent.enabled
                               ? "#39424B"
                               : parent.down
                                 ? "#2676BD"
                                 : "#2F91E8"
                    }

                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#FFFFFF" : "#808A94"
                        font: parent.font
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
