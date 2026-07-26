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
    property color accentColor: "#2da8ff"
    property color warningColor: "#ffb347"

    property string sortMode: "name"

    signal addWaypointRequested()
    signal waypointOpenRequested()

    width: Math.min(560, parent ? parent.width * 0.94 : 560)
    height: Math.min(640, parent ? parent.height * 0.92 : 640)

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

    function distanceMiles(latitude, longitude) {
        if (gpsBackend.fixMode < 2)
            return -1

        var earthRadiusMeters = 6371000

        var lat1 = gpsBackend.latitude * Math.PI / 180
        var lat2 = latitude * Math.PI / 180

        var deltaLat = (latitude - gpsBackend.latitude) * Math.PI / 180
        var deltaLon = (longitude - gpsBackend.longitude) * Math.PI / 180

        var a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
                Math.cos(lat1) * Math.cos(lat2) *
                Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2)

        var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

        return popup.metersToMiles(earthRadiusMeters * c)
    }

    function refresh() {
        var parsed = []

        try {
            parsed = JSON.parse(
                waypointManager.getWaypointsJson()
            )
        } catch (error) {
            parsed = []
        }

        var query = searchField.text.trim().toLowerCase()
        var filtered = []

        for (var i = 0; i < parsed.length; i++) {
            var waypoint = parsed[i]

            if (
                query === "" ||
                (waypoint.name || "")
                    .toLowerCase()
                    .indexOf(query) !== -1
            ) {
                filtered.push(waypoint)
            }
        }

        for (var j = 0; j < filtered.length; j++) {
            filtered[j]._distanceMiles = popup.distanceMiles(
                filtered[j].latitude,
                filtered[j].longitude
            )
        }

        if (popup.sortMode === "distance") {
            filtered.sort(function(a, b) {
                var distanceA =
                    a._distanceMiles < 0
                    ? Infinity
                    : a._distanceMiles

                var distanceB =
                    b._distanceMiles < 0
                    ? Infinity
                    : b._distanceMiles

                return distanceA - distanceB
            })
        } else {
            filtered.sort(function(a, b) {
                return (a.name || "").localeCompare(
                    b.name || ""
                )
            })
        }

        waypointsModel.clear()

        for (var k = 0; k < filtered.length; k++) {
            var item = filtered[k]

            waypointsModel.append({
                waypointId: item.id,
                name: item.name,
                category: item.category || "WAYPOINT",
                latitude: item.latitude,
                longitude: item.longitude,
                distanceMiles: item._distanceMiles
            })
        }
    }

    onOpened: {
        searchField.text = ""
        popup.refresh()
    }

    ListModel {
        id: waypointsModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "WAYPOINTS"
                color: popup.textColor

                font.pixelSize: 20
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 38

                text: "+ ADD"

                onClicked: {
                    popup.close()
                    popup.addWaypointRequested()
                }
            }

            Button {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 38

                text: "✕"

                onClicked: popup.close()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            TextField {
                id: searchField

                Layout.fillWidth: true
                Layout.preferredHeight: 44

                placeholderText: "Search waypoints"

                inputMethodHints:
                    Qt.ImhNoPredictiveText

                onTextChanged: popup.refresh()
            }

            Button {
                Layout.preferredWidth: 68
                Layout.preferredHeight: 44

                text: "NAME"
                font.pixelSize: 12

                highlighted:
                    popup.sortMode === "name"

                onClicked: {
                    popup.sortMode = "name"
                    popup.refresh()
                }
            }

            Button {
                Layout.preferredWidth: 68
                Layout.preferredHeight: 44

                text: "DIST"
                font.pixelSize: 12

                highlighted:
                    popup.sortMode === "distance"

                onClicked: {
                    popup.sortMode = "distance"
                    popup.refresh()
                }
            }
        }

        Label {
            visible: waypointsModel.count === 0

            Layout.fillWidth: true

            text: "No waypoints match. Long-press the map to add one."
            color: popup.secondaryTextColor
            wrapMode: Text.WordWrap
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: waypointsModel.count > 0
            clip: true
            spacing: 5

            model: waypointsModel

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 52

                radius: 8
                color: rowMouse.pressed ? "#232d38" : "#1b222b"

                border.width: 1
                border.color: popup.borderColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Label {
                            Layout.fillWidth: true

                            text: name
                            color: popup.textColor
                            elide: Text.ElideRight

                            font.pixelSize: 14
                            font.bold: true
                        }

                        Label {
                            text: category
                            color: popup.warningColor

                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.6
                        }
                    }

                    Label {
                        text:
                            distanceMiles >= 0
                            ? distanceMiles.toFixed(1) + " mi"
                            : "--"

                        color: popup.secondaryTextColor
                        font.pixelSize: 13
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent

                    onClicked: {
                        waypointManager.setSelectedWaypoint(
                            waypointId
                        )

                        popup.close()
                        popup.waypointOpenRequested()
                    }
                }
            }
        }
    }

    Connections {
        target: waypointManager

        function onWaypointsChanged() {
            if (popup.opened)
                popup.refresh()
        }
    }
}
