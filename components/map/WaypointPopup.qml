import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property var mapViewRef

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color warningColor: "#ffb347"

    width: Math.min(460, parent ? parent.width * 0.8 : 460)
    height: 400

    modal: true
    focus: true

    closePolicy: Popup.CloseOnEscape |
                 Popup.CloseOnPressOutside

    function prepare() {
        waypointStatus.text = ""
        waypointName.clear()
        waypointNotes.clear()
        waypointCategory.currentIndex = 0
    }

    background: Rectangle {
        radius: 14
        color: popup.panelColor

        border.width: 1
        border.color: popup.borderColor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            text: "ADD WAYPOINT"
            color: popup.textColor

            font.pixelSize: 22
            font.bold: true
        }

        TextField {
    id: waypointName

    Layout.fillWidth: true
    placeholderText: "Waypoint name"

    inputMethodHints:
        Qt.ImhNoPredictiveText

    onAccepted: waypointNotes.forceActiveFocus()
}

        ComboBox {
            id: waypointCategory

            Layout.fillWidth: true

            model: [
                "Camp",
                "Hazard",
                "Fuel",
                "Repair",
                "Meeting Point",
                "Custom"
            ]
        }

        TextArea {
    id: waypointNotes

    Layout.fillWidth: true
    Layout.preferredHeight: 90

    placeholderText: "Notes"
    wrapMode: TextArea.Wrap

    inputMethodHints:
        Qt.ImhMultiLine |
        Qt.ImhNoPredictiveText
}

        Label {
            id: waypointStatus

            Layout.fillWidth: true

            text: ""
            color: popup.warningColor
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.fillWidth: true

            Button {
                Layout.fillWidth: true

                text: "CANCEL"

                onClicked: popup.close()
            }

            Button {
                Layout.fillWidth: true

                text: "SAVE"

                onClicked: {
                    if (waypointName.text.trim() === "") {
                        waypointStatus.text =
                                "Enter a waypoint name."
                        return
                    }

                    if (!popup.mapViewRef) {
                        waypointStatus.text =
                                "Map is not available."
                        return
                    }

                    popup.mapViewRef.runJavaScript(
                        "getVehiclePositionJson();",
                        function(result) {
                            try {
                                var position = JSON.parse(result)

                                var saved =
                                        navigationBackend.saveWaypoint(
                                            waypointName.text,
                                            waypointCategory.currentText,
                                            waypointNotes.text,
                                            position.latitude,
                                            position.longitude
                                        )

                                if (saved) {
                                    popup.mapViewRef.runJavaScript(
                                        "addWaypointMarker(" +
                                        position.latitude + "," +
                                        position.longitude + "," +
                                        JSON.stringify(
                                            waypointName.text
                                        ) + "," +
                                        JSON.stringify(
                                            waypointCategory.currentText
                                        ) +
                                        ");"
                                    )

                                    popup.close()
                                } else {
                                    waypointStatus.text =
                                            "Could not save waypoint."
                                }
                            } catch (error) {
                                waypointStatus.text =
                                        "Invalid map position."
                            }
                        }
                    )
                }
            }
        }
    }
}
