import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property var mapViewRef
    property var trackVisibility: ({})

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color accentColor: "#2da8ff"
    property color dangerColor: "#ff5d5d"

    width: Math.min(460, parent ? parent.width * 0.85 : 460)
    height: Math.min(520, parent ? parent.height * 0.85 : 520)

    modal: true
    focus: true

    closePolicy: Popup.CloseOnEscape |
                 Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 14
        color: popup.panelColor

        border.width: 1
        border.color: popup.borderColor
    }

    function metersToMiles(meters) {
        return meters / 1609.34
    }

    function formatDuration(seconds) {
        var totalMinutes = Math.round(seconds / 60)
        var hours = Math.floor(totalMinutes / 60)
        var minutes = totalMinutes % 60

        return hours > 0
               ? (hours + "h " + minutes + "m")
               : (minutes + "m")
    }

    function refresh() {
        var parsed = []

        try {
            parsed = JSON.parse(
                trackManager.getTracksJson()
            )
        } catch (error) {
            parsed = []
        }

        tripsModel.clear()

        for (var i = parsed.length - 1; i >= 0; i--) {
            var trip = parsed[i]

            tripsModel.append({
                tripId: trip.id,
                name: trip.name,
                distanceMeters: trip.distanceMeters || 0,
                durationSeconds: trip.durationSeconds || 0
            })
        }
    }

    onOpened: popup.refresh()

    ListModel {
        id: tripsModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Label {
            text: "TRIPS"
            color: popup.textColor

            font.pixelSize: 22
            font.bold: true
        }

        Label {
            visible: tripsModel.count === 0

            Layout.fillWidth: true

            text: "No recorded trips yet. Trips record automatically once the vehicle starts moving."
            color: popup.secondaryTextColor
            wrapMode: Text.WordWrap
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: tripsModel.count > 0
            clip: true
            spacing: 8

            model: tripsModel

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 76

                radius: 10
                color: "#1b222b"

                border.width: 1
                border.color: popup.borderColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true

                            text: name
                            color: popup.textColor
                            elide: Text.ElideRight

                            font.pixelSize: 15
                            font.bold: true
                        }

                        Label {
                            text: popup.metersToMiles(distanceMeters).toFixed(1)
                                  + " mi · "
                                  + popup.formatDuration(durationSeconds)

                            color: popup.secondaryTextColor
                            font.pixelSize: 12
                        }
                    }

                    Switch {
                        checked: !!popup.trackVisibility[tripId]

                        onToggled: {
                            popup.trackVisibility[tripId] = checked

                            if (popup.mapViewRef) {
                                popup.mapViewRef.runJavaScript(
                                    "setTrackVisible('" +
                                    tripId +
                                    "', " +
                                    checked +
                                    ");"
                                )
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40

                        onClicked: {
                            delete popup.trackVisibility[tripId]
                            trackManager.deleteTrack(tripId)
                        }

                        background: Rectangle {
                            radius: 8
                            color: parent.down ? "#3a1518" : "#241417"
                            border.width: 1
                            border.color: popup.dangerColor
                        }

                        contentItem: Label {
                            text: "✕"
                            color: popup.dangerColor

                            font.pixelSize: 16
                            font.bold: true

                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true

            text: "CLOSE"

            onClicked: popup.close()
        }
    }

    Connections {
        target: trackManager

        function onTracksChanged() {
            if (popup.opened)
                popup.refresh()
        }
    }
}
