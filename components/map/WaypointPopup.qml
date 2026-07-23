import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property var mapViewRef

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color accentColor: "#2da8ff"

    property int keyboardHeight:
        Qt.inputMethod.visible
        ? Qt.inputMethod.keyboardRectangle.height
        : 0

    width: parent ? parent.width : 1280
    height: Qt.inputMethod.visible ? 300 : 360

    x: 0

    y: parent
       ? parent.height - height - keyboardHeight
       : 0

    modal: true
    focus: true

    closePolicy: Popup.CloseOnEscape

    function prepare() {
        waypointStatus.text = ""
        waypointName.clear()
        waypointNotes.clear()
        waypointCategory.currentIndex = 0

        Qt.callLater(function() {
            waypointName.forceActiveFocus()
        })
    }

    function saveWaypoint() {
        const cleanedName = waypointName.text.trim()

        if (cleanedName === "") {
            waypointStatus.text =
                "Enter a waypoint name."

            waypointName.forceActiveFocus()
            return
        }

        if (!popup.mapViewRef) {
            waypointStatus.text =
                "Map is not available."

            return
        }

        waypointStatus.text =
            "Saving waypoint..."

        popup.mapViewRef.runJavaScript(
            "getVehiclePositionJson();",
            function(result) {
                try {
                    const position =
                        JSON.parse(result)

                    const savedWaypoint =
                        waypointManager.createWaypoint(
                            cleanedName,
                            waypointCategory.currentText,
                            waypointNotes.text,
                            Number(position.latitude),
                            Number(position.longitude)
                        )

                    if (savedWaypoint !== "") {
                        /*
                         * Do not add a marker manually here.
                         *
                         * WaypointManager emits
                         * waypointsChanged, and MapsPage
                         * reloads all saved markers.
                         */
                        Qt.inputMethod.hide()
                        popup.close()
                    } else {
                        waypointStatus.text =
                            "Could not save waypoint."
                    }
                } catch (error) {
                    console.log(
                        "Waypoint save error:",
                        error
                    )

                    waypointStatus.text =
                        "Invalid map position."
                }
            }
        )
    }

    background: Rectangle {
        color: popup.panelColor

        border.width: 1
        border.color: popup.borderColor

        radius: 18

        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter:
                parent.horizontalCenter
            anchors.topMargin: 9

            width: 70
            height: 5
            radius: 3

            color: popup.secondaryTextColor
        }
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 24
            anchors.bottomMargin: 18

            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "ADD WAYPOINT"
                    color: popup.textColor

                    font.pixelSize: 23
                    font.bold: true
                }

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 48

                    text: "CANCEL"

                    onClicked: {
                        Qt.inputMethod.hide()
                        popup.close()
                    }
                }

                Button {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 48

                    text: "SAVE"

                    onClicked: {
                        popup.saveWaypoint()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                TextField {
                    id: waypointName

                    Layout.fillWidth: true
                    Layout.preferredHeight: 54

                    placeholderText:
                        "Waypoint name"

                    inputMethodHints:
                        Qt.ImhNoPredictiveText

                    onAccepted: {
                        waypointNotes.forceActiveFocus()
                    }
                }

                ComboBox {
                    id: waypointCategory

                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 54

                    model: [
                        "Camp",
                        "Hazard",
                        "Fuel",
                        "Repair",
                        "Meeting Point",
                        "Custom"
                    ]
                }
            }

            TextArea {
                id: waypointNotes

                Layout.fillWidth: true
                Layout.fillHeight: true

                placeholderText: "Notes"
                wrapMode: TextArea.Wrap

                inputMethodHints:
                    Qt.ImhMultiLine
                    | Qt.ImhNoPredictiveText

                background: Rectangle {
                    radius: 8
                    color: "#1b2530"

                    border.width: 1

                    border.color:
                        waypointNotes.activeFocus
                        ? popup.accentColor
                        : popup.borderColor
                }
            }

            Label {
                id: waypointStatus

                Layout.fillWidth: true

                text: ""
                visible: text.length > 0

                color: popup.warningColor
                wrapMode: Text.WordWrap

                font.pixelSize: 13
            }
        }
    }

    onOpened: {
        prepare()
    }

    onClosed: {
        Qt.inputMethod.hide()
    }
}
