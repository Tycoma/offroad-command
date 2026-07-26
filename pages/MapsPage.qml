import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine
import QtWebChannel

import "../components/map"

Item {
    id: page

    property string pageTitle: "MAPS"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff5d5d"
    property color successColor: "#55d889"

    property bool mapLoaded: false
    property bool followVehicle: true
    property bool toolsVisible: false
    property var tripVisibility: ({})

    signal waypointEditRequested(
        real latitude,
        real longitude
    )

    function showTools() {
        toolsVisible = true
        hideToolsTimer.restart()
    }

    function hideTools() {
        toolsVisible = false
        hideToolsTimer.stop()
    }

    function anyPopupOpen() {
        return (
            navigationDrawer.opened ||
            waypointsListPopup.opened ||
            waypointPopup.opened ||
            waypointInfoPopup.opened ||
            layersPopup.opened ||
            gotoPopup.opened ||
            tripsPopup.opened
        )
    }

    function loadSavedWaypoints() {
        if (!page.mapLoaded)
            return

        const json =
            waypointManager.getWaypointsJson()

        mapView.runJavaScript(
            "loadWaypoints(" +
            JSON.stringify(json) +
            ");"
        )
    }

    function removeTemporaryMarker() {
        if (!page.mapLoaded)
            return

        mapView.runJavaScript(
            "removeTemporaryWaypoint();"
        )
    }

    function loadSavedTracks() {
        if (!page.mapLoaded)
            return

        const json =
            trackManager.getTracksJson()

        mapView.runJavaScript(
            "loadTracks(" +
            JSON.stringify(json) +
            ");"
        )
    }

    function pushVehiclePosition() {
        if (!page.mapLoaded)
            return

        if (gpsBackend.fixMode < 2)
            return

        mapView.runJavaScript(
            "updateVehiclePosition(" +
            gpsBackend.latitude +
            ", " +
            gpsBackend.longitude +
            ");"
        )

        trackManager.updatePosition(
            gpsBackend.latitude,
            gpsBackend.longitude,
            gpsBackend.speedMph
        )
    }

    WebChannel {
        id: mapWebChannel

        Component.onCompleted: {
            registerObject(
                "mapBridge",
                mapBridge
            )

            console.log(
                "Registered mapBridge with WebChannel"
            )
        }
    }

    Connections {
        target: waypointManager

        function onWaypointsChanged() {
            page.loadSavedWaypoints()
        }
    }

    Connections {
        target: trackManager

        function onTracksChanged() {
            page.loadSavedTracks()
        }

        function onRecordingChanged() {
            if (trackManager.recording) {
                mapView.runJavaScript(
                    "startTrackRecording();"
                )
            } else {
                mapView.runJavaScript(
                    "stopTrackRecording();"
                )
            }
        }
    }

    Connections {
        target: gpsBackend

        function onLatitudeChanged() {
            page.pushVehiclePosition()
        }

        function onLongitudeChanged() {
            page.pushVehiclePosition()
        }
    }

    Connections {
        target: mapBridge

        function onWaypointSelected(
            waypointId
        ) {
            waypointManager
                .setSelectedWaypoint(
                    waypointId
                )

            Qt.callLater(function() {
                waypointInfoPopup.open()
            })
        }

        function onMapClicked() {
            if (page.anyPopupOpen())
                return

            if (page.toolsVisible)
                page.hideTools()
            else
                page.showTools()
        }

        function onMapPressed(
            latitude,
            longitude
        ) {
            if (page.anyPopupOpen())
                return

            page.waypointEditRequested(
                latitude,
                longitude
            )
        }

    }

    Rectangle {
        anchors.fill: parent
        color: "#101820"

        WebEngineView {
            id: mapView

            anchors.fill: parent

            webChannel: mapWebChannel

            url: Qt.resolvedUrl(
                "../navigation/web/map.html"
            )

            settings.localContentCanAccessRemoteUrls:
                true

            settings.localContentCanAccessFileUrls:
                true

            settings.javascriptEnabled:
                true

            onLoadingChanged:
                function(loadRequest) {
                    if (
                        loadRequest.status ===
                        WebEngineView
                            .LoadSucceededStatus
                    ) {
                        page.mapLoaded = true

                        mapView.runJavaScript(
                            "setFollowVehicle(" +
                            page.followVehicle +
                            ");"
                        )

                        Qt.callLater(
                            page.loadSavedWaypoints
                        )

                        Qt.callLater(
                            page.loadSavedTracks
                        )
                    }

                    if (
                        loadRequest.status ===
                        WebEngineView
                            .LoadFailedStatus
                    ) {
                        console.log(
                            "Map load failed:",
                            loadRequest.errorString
                        )
                    }
                }
        }

        Column {
            id: leftControls

            z: 30

            anchors.left: parent.left
            anchors.verticalCenter:
                parent.verticalCenter

            anchors.leftMargin: 18

            anchors.verticalCenterOffset:
                -85

            spacing: 6

            visible: page.toolsVisible
            opacity:
                page.toolsVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            MapControls {
                id: mapControls

                accentColor:
                    page.accentColor

                textColor:
                    page.textColor

                borderColor:
                    "#66717a"

                toolsVisible: true

                onZoomInRequested: {
                    page.showTools()

                    mapView.runJavaScript(
                        "zoomIn();"
                    )
                }

                onZoomOutRequested: {
                    page.showTools()

                    mapView.runJavaScript(
                        "zoomOut();"
                    )
                }
            }

            Rectangle {
                id: followButton

                width: 82
                height: 52
                radius: 7

                color:
                    followMouse.pressed
                    ? "#ff182028"
                    : "#ed000000"

                border.width:
                    page.followVehicle
                    ? 2
                    : 1

                border.color:
                    page.followVehicle
                    ? page.accentColor
                    : "#66717a"

                Column {
                    anchors.centerIn: parent
                    spacing: 0

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            page.followVehicle
                            ? "\u25C9"
                            : "\u25CB"

                        color:
                            page.followVehicle
                            ? page.accentColor
                            : page.textColor

                        font.pixelSize: 20
                        font.bold: true
                    }

                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            page.followVehicle
                            ? "FOLLOW"
                            : "FREE"

                        color:
                            page.followVehicle
                            ? page.accentColor
                            : page.textColor

                        font.pixelSize: 10
                        font.bold: true

                        font.letterSpacing:
                            0.7
                    }
                }

                MouseArea {
                    id: followMouse
                    anchors.fill: parent

                    onClicked: {
                        page.showTools()

                        page.followVehicle =
                            !page.followVehicle

                        mapView.runJavaScript(
                            "setFollowVehicle(" +
                            page.followVehicle +
                            ");"
                        )

                        if (
                            page.followVehicle
                        ) {
                            mapView
                                .runJavaScript(
                                    "recenterVehicle();"
                                )
                        }
                    }
                }
            }
        }

        MapBottomToolbar {
            id: bottomToolbar

            z: 20

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin: 12
            anchors.rightMargin: 12

            anchors.bottomMargin:
                page.toolsVisible
                ? 12
                : -90

            toolsVisible:
                page.toolsVisible

            borderColor:
                page.borderColor

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type:
                        Easing.OutCubic
                }
            }

            onWaypointRequested: {
                page.hideTools()
                waypointsListPopup.open()
            }

            onRoutesRequested: {
                page.showTools()
                navigationDrawer.open()
            }

            onTracksRequested: {
                page.showTools()
                tripsPopup.open()
            }

            onLayersRequested: {
                page.showTools()
                layersPopup.open()
            }

            onGotoRequested: {
                page.showTools()
                gotoPopup.open()
            }
        }

        Rectangle {
            id: mapStatus

            z: 25

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.rightMargin: 18

            anchors.bottomMargin:
                page.toolsVisible
                ? bottomToolbar.height + 28
                : 18

            width:
                statusLabel.implicitWidth + 22

            height: 32
            radius: 6

            color: "#ef000000"

            border.width: 1

            border.color:
                trackManager.recording
                ? page.dangerColor
                : page.mapLoaded
                  ? page.successColor
                  : page.warningColor

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type:
                        Easing.OutCubic
                }
            }

            Row {
                anchors.centerIn: parent
                spacing: 9

                Rectangle {
                    anchors.verticalCenter:
                        parent.verticalCenter

                    width: 8
                    height: 8
                    radius: 4

                    color:
                        trackManager.recording
                        ? page.dangerColor
                        : page.mapLoaded
                          ? page.successColor
                          : page.warningColor
                }

                Label {
                    id: statusLabel

                    text:
                        trackManager.recording
                        ? "REC"
                        : page.mapLoaded
                          ? "READY"
                          : "LOAD"

                    color: page.textColor

                    font.pixelSize: 11
                    font.bold: true
                }
            }
        }
    }

    Timer {
        id: hideToolsTimer

        interval: 6000
        repeat: false

        onTriggered: {
            if (!page.anyPopupOpen())
                page.toolsVisible = false
        }
    }

    NavigationDrawer {
        id: navigationDrawer
        z: 500

        width: Math.min(
            390,
            page.width * 0.42
        )

        height: page.height

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor

        secondaryTextColor:
            page.secondaryTextColor

        onClosed: page.showTools()

        onTripsRequested: {
            navigationDrawer.close()
            tripsPopup.open()
        }
    }

    WaypointsListPopup {
        id: waypointsListPopup
        z: 500

        mapViewRef: mapView

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor

        secondaryTextColor:
            page.secondaryTextColor

        warningColor:
            page.warningColor

        accentColor:
            page.accentColor

        onClosed: page.showTools()

        onAddWaypointRequested: {
            waypointPopup.open()
        }

        onWaypointOpenRequested: {
            waypointInfoPopup.open()
        }
    }

    WaypointPopup {
        id: waypointPopup
        z: 500

        mapViewRef: mapView

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor

        secondaryTextColor:
            page.secondaryTextColor

        warningColor:
            page.warningColor

        accentColor:
            page.accentColor

        onClosed: page.showTools()
    }

    WaypointInfoPopup {
        id: waypointInfoPopup

        parent: page
        z: 600

        mapViewRef: mapView

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor

        secondaryTextColor:
            page.secondaryTextColor

        warningColor:
            page.warningColor

        accentColor:
            page.accentColor

        dangerColor:
            page.dangerColor

        onClosed: page.showTools()
    }
    LayersPopup {
        id: layersPopup
        z: 500

        anchors.centerIn: parent

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor

        onClosed: page.showTools()
    }

    GotoPopup {
        id: gotoPopup
        z: 500

        anchors.centerIn: parent

        mapViewRef: mapView

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor
        warningColor: page.warningColor

        onClosed: page.showTools()
    }

    TripsPopup {
        id: tripsPopup
        z: 500

        anchors.centerIn: parent

        mapViewRef: mapView
        trackVisibility: page.tripVisibility

        panelColor: page.panelColor
        borderColor: page.borderColor
        textColor: page.textColor
        secondaryTextColor: page.secondaryTextColor

        onClosed: page.showTools()
    }
}
