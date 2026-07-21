import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

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

    property bool recording: false
    property bool mapLoaded: false
    property bool followVehicle: true
    property bool toolsVisible: false

    function showTools() {
        toolsVisible = true
        hideToolsTimer.restart()
    }

    function hideTools() {
        toolsVisible = false
        hideToolsTimer.stop()
    }

    Rectangle {
        anchors.fill: parent
        color: "#101820"

        WebEngineView {
            id: mapView

            anchors.fill: parent

            url: Qt.resolvedUrl(
                "../navigation/web/map.html"
            )

            settings.localContentCanAccessRemoteUrls: true
            settings.localContentCanAccessFileUrls: true
            settings.javascriptEnabled: true

            onLoadingChanged: function(loadRequest) {
                if (
                    loadRequest.status
                    === WebEngineView.LoadSucceededStatus
                ) {
                    page.mapLoaded = true
                }

                if (
                    loadRequest.status
                    === WebEngineView.LoadFailedStatus
                ) {
                    console.log(
                        "Map load failed:",
                        loadRequest.errorString
                    )
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true
            preventStealing: false

            onClicked: function(mouse) {
                if (
                    navigationDrawer.opened
                    || waypointPopup.opened
                    || layersPopup.opened
                    || gotoPopup.opened
                ) {
                    mouse.accepted = false
                    return
                }

                if (page.toolsVisible)
                    page.hideTools()
                else
                    page.showTools()

                mouse.accepted = false
            }
        }

        Column {
            id: leftControls

            z: 30

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 18
            anchors.verticalCenterOffset: -85

            spacing: 6

            visible: page.toolsVisible
            opacity: page.toolsVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            MapControls {
                id: mapControls

                accentColor: page.accentColor
                textColor: page.textColor
                borderColor: "#66717a"

                toolsVisible: true

                onZoomInRequested: {
                    page.showTools()
                    mapView.runJavaScript("zoomIn();")
                }

                onZoomOutRequested: {
                    page.showTools()
                    mapView.runJavaScript("zoomOut();")
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
                    page.followVehicle ? 2 : 1

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
                        font.letterSpacing: 0.7
                    }
                }

                MouseArea {
                    id: followMouse

                    anchors.fill: parent

                    onClicked: {
                        page.showTools()
                        page.followVehicle =
                            !page.followVehicle

                        if (page.followVehicle) {
                            mapView.runJavaScript(
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

            toolsVisible: page.toolsVisible
            recording: page.recording

            borderColor: page.borderColor

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            onWaypointRequested: {
                page.hideTools()
                waypointPopup.open()
            }

            onRecordingRequested: {
                page.showTools()
                page.recording =
                    !page.recording

                mapView.runJavaScript(
                    "toggleSimulation();"
                )
            }

            onRoutesRequested: {
                page.showTools()
                navigationDrawer.open()
            }

            onTracksRequested: {
                page.showTools()
                navigationDrawer.open()
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

            width: statusLabel.implicitWidth + 22
            height: 32
            radius: 6

            color: "#ef000000"

            border.width: 1

            border.color:
                page.recording
                ? page.dangerColor
                : page.mapLoaded
                  ? page.successColor
                  : page.warningColor

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
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
                        page.recording
                        ? page.dangerColor
                        : page.mapLoaded
                          ? page.successColor
                          : page.warningColor

                    SequentialAnimation on opacity {
                        running: page.recording
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1.0
                            to: 0.25
                            duration: 450
                        }

                        NumberAnimation {
                            from: 0.25
                            to: 1.0
                            duration: 450
                        }
                    }
                }

                Label {
                    id: statusLabel

                    text:
                        page.recording
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
            if (
                !navigationDrawer.opened
                && !waypointPopup.opened
                && !layersPopup.opened
                && !gotoPopup.opened
            ) {
                page.toolsVisible = false
            }
        }
    }

    NavigationDrawer {
        id: navigationDrawer
        z: 500

        width:
            Math.min(
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

        warningColor: page.warningColor
        accentColor: page.accentColor

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
}
