import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property var mapViewRef
    property var waypointData: ({})

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color accentColor: "#2da8ff"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff5d5d"

    width: Math.min(
        parent ? parent.width - 40 : 720,
        720
    )

    height: 430

    x: parent
       ? (parent.width - width) / 2
       : 0

    y: parent
       ? (parent.height - height) / 2
       : 0

    modal: true
    focus: true

    closePolicy:
        Popup.CloseOnEscape |
        Popup.CloseOnPressOutside

    function refreshWaypoint() {
        const json =
            waypointManager
                .getSelectedWaypointJson()

        if (!json) {
            waypointData = ({})
            return false
        }

        try {
            waypointData =
                JSON.parse(json)

            waypointName.text =
                waypointData.name || ""

            waypointNotes.text =
                waypointData.notes || ""

            statusLabel.text = ""

            return true
        } catch (error) {
            console.log(
                "Waypoint popup parse error:",
                error
            )

            waypointData = ({})
            return false
        }
    }

    function waypointId() {
        return waypointData.id || ""
    }

    function formattedCoordinates() {
        if (
            waypointData.latitude === undefined ||
            waypointData.longitude === undefined
        ) {
            return ""
        }

        return (
            Number(
                waypointData.latitude
            ).toFixed(5) +
            ", " +
            Number(
                waypointData.longitude
            ).toFixed(5)
        )
    }

    background: Rectangle {
        color: popup.panelColor
        radius: 18

        border.width: 2
        border.color: popup.borderColor
    }

    contentItem: ColumnLayout {
        anchors.fill: parent

        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 22
        anchors.bottomMargin: 20

        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Label {
                    text:
                        waypointData.category ||
                        "WAYPOINT"

                    color: popup.warningColor

                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 1.1
                }

                Label {
                    text:
                        waypointData.name ||
                        "Waypoint"

                    color: popup.textColor

                    font.pixelSize: 28
                    font.bold: true

                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            Button {
                text: "CLOSE"

                Layout.preferredWidth: 110
                Layout.preferredHeight: 48

                onClicked: {
                    popup.close()
                }
            }
        }

        Label {
            text: popup.formattedCoordinates()

            color: popup.secondaryTextColor
            font.pixelSize: 15
        }

        TextField {
            id: waypointName

            Layout.fillWidth: true
            Layout.preferredHeight: 52

            placeholderText: "Waypoint name"

            inputMethodHints:
                Qt.ImhNoPredictiveText
        }

        TextArea {
            id: waypointNotes

            Layout.fillWidth: true
            Layout.fillHeight: true

            placeholderText: "Waypoint notes"

            wrapMode: TextArea.Wrap

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
            id: statusLabel

            Layout.fillWidth: true

            text: ""
            visible: text.length > 0

            color: popup.warningColor
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: "GO TO"

                Layout.fillWidth: true
                Layout.preferredHeight: 54

                onClicked: {
                    const id =
                        popup.waypointId()

                    if (!id)
                        return

                    if (popup.mapViewRef) {
                        popup.mapViewRef
                            .runJavaScript(
                                "centerOnWaypoint(" +
                                JSON.stringify(id) +
                                ");"
                            )
                    }

                    mapBridge.requestGoto(id)
                    popup.close()
                }
            }

            Button {
                text: "SAVE EDITS"

                Layout.fillWidth: true
                Layout.preferredHeight: 54

                onClicked: {
                    const id =
                        popup.waypointId()

                    const cleanedName =
                        waypointName.text.trim()

                    if (!id)
                        return

                    if (!cleanedName) {
                        statusLabel.text =
                            "Enter a waypoint name."
                        return
                    }

                    const nameSaved =
                        waypointManager
                            .renameWaypoint(
                                id,
                                cleanedName
                            )

                    const notesSaved =
                        waypointManager
                            .updateWaypointNotes(
                                id,
                                waypointNotes.text
                            )

                    if (
                        nameSaved &&
                        notesSaved
                    ) {
                        statusLabel.text =
                            "Waypoint updated."

                        popup.refreshWaypoint()
                    } else {
                        statusLabel.text =
                            "Could not update waypoint."
                    }
                }
            }

            Button {
                text: "DELETE"

                Layout.fillWidth: true
                Layout.preferredHeight: 54

                onClicked: {
                    deleteConfirmation.open()
                }
            }
        }
    }

    Dialog {
        id: deleteConfirmation

        anchors.centerIn: parent

        modal: true
        focus: true

        title: "Delete waypoint?"

        standardButtons:
            Dialog.Yes |
            Dialog.No

        Label {
            width: 380

            text:
                "This waypoint will be removed permanently."

            color: popup.textColor
            wrapMode: Text.WordWrap
        }

        onAccepted: {
            const id =
                popup.waypointId()

            if (
                id &&
                waypointManager
                    .deleteWaypoint(id)
            ) {
                if (popup.mapViewRef) {
                    popup.mapViewRef
                        .runJavaScript(
                            "clearWaypointSelection();"
                        )
                }

                popup.close()
            } else {
                statusLabel.text =
                    "Could not delete waypoint."
            }
        }
    }

    Connections {
        target: waypointManager

        function onSelectedWaypointChanged() {
            if (popup.opened)
                popup.refreshWaypoint()
        }
    }

    onOpened: {
        refreshWaypoint()
    }

    onClosed: {
        Qt.inputMethod.hide()
    }
}
