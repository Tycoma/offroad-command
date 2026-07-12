import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtWebEngine

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

    property int simulatedSpeed: 34
    property int simulatedRpm: 2450
    property int simulatedOilPressure: 58
    property int simulatedCoolant: 188
    property real simulatedBattery: 14.2

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

        /*
         * Transparent tap layer.
         *
         * A normal tap shows or hides the map controls.
         * The click is passed through so Leaflet can still handle
         * map interaction.
         */
        MouseArea {
            anchors.fill: parent

            acceptedButtons: Qt.LeftButton
            propagateComposedEvents: true
            preventStealing: false

            onClicked: function(mouse) {
                if (
                    navigationDrawer.opened
                    || vehicleDrawer.opened
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

        /*
         * Small status indicator.
         * This replaces the large map-page header.
         */
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right

            anchors.topMargin: 14
            anchors.rightMargin: 14

            width: statusLabel.implicitWidth + 26
            height: 38
            radius: 19

            color: "#d90a0f15"

            border.width: 1
            border.color: page.borderColor

            Label {
                id: statusLabel

                anchors.centerIn: parent

                text: page.recording
                      ? "REC"
                      : page.mapLoaded
                        ? "MAP READY"
                        : "LOADING"

                color: page.recording
                       ? page.dangerColor
                       : page.mapLoaded
                         ? page.successColor
                         : page.warningColor

                font.pixelSize: 12
                font.bold: true
            }
        }

        /*
         * Floating map controls.
         * They appear with the lower toolbar after tapping the map.
         */
        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14

            spacing: 8

            visible: page.toolsVisible
            opacity: page.toolsVisible ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            Button {
                width: 64
                height: 58

                text: "+"
                font.pixelSize: 26

                onClicked: {
                    page.showTools()
                    mapView.runJavaScript("zoomIn();")
                }
            }

            Button {
                width: 64
                height: 58

                text: "-"
                font.pixelSize: 26

                onClicked: {
                    page.showTools()
                    mapView.runJavaScript("zoomOut();")
                }
            }

            Button {
                width: 64
                height: 58

                text: "MENU"

                font.pixelSize: 11
                font.bold: true

                onClicked: {
                    page.showTools()
                    navigationDrawer.open()
                }
            }
        }

        Button {
            anchors.right: parent.right
            anchors.bottom: bottomToolbar.top

            anchors.rightMargin: 18
            anchors.bottomMargin: 14

            width: 82
            height: 62

            visible: page.toolsVisible
            opacity: page.toolsVisible ? 1 : 0

            text: page.followVehicle
                  ? "FOLLOW"
                  : "FREE"

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            onClicked: {
                page.showTools()
                page.followVehicle = !page.followVehicle

                if (page.followVehicle) {
                    mapView.runJavaScript(
                        "recenterVehicle();"
                    )
                }
            }
        }

        /*
         * Bottom toolbar is hidden until the map is tapped.
         */
        Rectangle {
            id: bottomToolbar

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.bottomMargin: page.toolsVisible ? 12 : -90

            height: 72
            radius: 12

            visible: opacity > 0

            opacity: page.toolsVisible ? 1 : 0

            color: "#ed0a0f15"

            border.width: 1
            border.color: page.borderColor

            Behavior on anchors.bottomMargin {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 160
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8

                spacing: 8

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: "WAYPOINT"

                    onClicked: {
                        page.showTools()
                        waypointStatus.text = ""
                        waypointPopup.open()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: page.recording
                          ? "STOP"
                          : "RECORD"

                    onClicked: {
                        page.showTools()
                        page.recording = !page.recording

                        mapView.runJavaScript(
                            "toggleSimulation();"
                        )
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: "ROUTES"

                    onClicked: {
                        page.showTools()
                        navigationDrawer.open()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: "TRACKS"

                    onClicked: {
                        page.showTools()
                        navigationDrawer.open()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: "LAYERS"

                    onClicked: {
                        page.showTools()
                        layersPopup.open()
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    text: "GO TO"

                    onClicked: {
                        page.showTools()
                        gotoPopup.open()
                    }
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
                && !vehicleDrawer.opened
                && !waypointPopup.opened
                && !layersPopup.opened
                && !gotoPopup.opened
            ) {
                page.toolsVisible = false
            }
        }
    }

    Drawer {
        id: navigationDrawer

        edge: Qt.LeftEdge

        width: Math.min(390, page.width * 0.42)
        height: page.height

        modal: true
        interactive: true

        onClosed: page.showTools()

        background: Rectangle {
            color: page.panelColor

            border.width: 1
            border.color: page.borderColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 10

            Label {
                text: "NAVIGATION"

                color: page.textColor

                font.pixelSize: 25
                font.bold: true
            }

            Label {
                text: "Offline maps and trip tools"

                color: page.secondaryTextColor

                font.pixelSize: 13
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: page.borderColor
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "ROUTES"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "WAYPOINTS"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "RECORDED TRACKS"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "FAVORITES"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "IMPORT GPX"
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                text: "EXPORT GPX"
            }

            Item {
                Layout.fillHeight: true
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 54

                text: "CLOSE"

                onClicked: navigationDrawer.close()
            }
        }
    }

    Drawer {
        id: vehicleDrawer

        edge: Qt.RightEdge

        width: Math.min(390, page.width * 0.42)
        height: page.height

        modal: true
        interactive: true

        onClosed: page.showTools()

        background: Rectangle {
            color: page.panelColor

            border.width: 1
            border.color: page.borderColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18

            spacing: 12

            Label {
                text: "VEHICLE STATUS"

                color: page.textColor

                font.pixelSize: 25
                font.bold: true
            }

            Label {
                text: "Simulated vehicle data"

                color: page.warningColor

                font.pixelSize: 13
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1

                color: page.borderColor
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76

                radius: 10
                color: "#1b2530"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    Label {
                        text: "SPEED"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: page.simulatedSpeed + " MPH"
                        color: page.textColor
                        font.pixelSize: 25
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76

                radius: 10
                color: "#1b2530"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    Label {
                        text: "ENGINE"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: page.simulatedRpm + " RPM"
                        color: page.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76

                radius: 10
                color: "#1b2530"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    Label {
                        text: "OIL PRESSURE"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: page.simulatedOilPressure + " PSI"
                        color: page.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76

                radius: 10
                color: "#1b2530"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    Label {
                        text: "COOLANT"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: page.simulatedCoolant + " F"
                        color: page.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 76

                radius: 10
                color: "#1b2530"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14

                    Label {
                        text: "BATTERY"
                        color: page.secondaryTextColor
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Label {
                        text: page.simulatedBattery.toFixed(1) + " V"
                        color: page.textColor
                        font.pixelSize: 22
                        font.bold: true
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 54

                text: "CLOSE"

                onClicked: vehicleDrawer.close()
            }
        }
    }

    Popup {
        id: waypointPopup

        anchors.centerIn: parent

        width: Math.min(460, page.width * 0.8)
        height: 400

        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape |
                     Popup.CloseOnPressOutside

        onClosed: page.showTools()

        background: Rectangle {
            radius: 14
            color: page.panelColor

            border.width: 1
            border.color: page.borderColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 12

            Label {
                text: "ADD WAYPOINT"

                color: page.textColor

                font.pixelSize: 22
                font.bold: true
            }

            TextField {
                id: waypointName

                Layout.fillWidth: true
                placeholderText: "Waypoint name"
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
            }

            Label {
                id: waypointStatus

                Layout.fillWidth: true

                text: ""
                color: page.warningColor
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

                    onClicked: waypointPopup.close()
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

                        mapView.runJavaScript(
                            "getVehiclePositionJson();",
                            function(result) {
                                try {
                                    const position =
                                            JSON.parse(result)

                                    const saved =
                                            navigationBackend.saveWaypoint(
                                                waypointName.text,
                                                waypointCategory.currentText,
                                                waypointNotes.text,
                                                position.latitude,
                                                position.longitude
                                            )

                                    if (saved) {
                                        mapView.runJavaScript(
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

                                        waypointName.clear()
                                        waypointNotes.clear()
                                        waypointCategory.currentIndex = 0
                                        waypointPopup.close()
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

    Popup {
        id: layersPopup

        anchors.centerIn: parent

        width: 340
        height: 360

        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape |
                     Popup.CloseOnPressOutside

        onClosed: page.showTools()

        background: Rectangle {
            radius: 14
            color: page.panelColor

            border.width: 1
            border.color: page.borderColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 8

            Label {
                text: "MAP LAYERS"

                color: page.textColor

                font.pixelSize: 22
                font.bold: true
            }

            CheckBox {
                text: "Street Map"
                checked: true
            }

            CheckBox {
                text: "Topographic"
            }

            CheckBox {
                text: "Satellite"
            }

            CheckBox {
                text: "Trails"
                checked: true
            }

            CheckBox {
                text: "Public Land"
            }

            CheckBox {
                text: "Saved Tracks"
                checked: true
            }

            Item {
                Layout.fillHeight: true
            }

            Button {
                Layout.fillWidth: true

                text: "CLOSE"

                onClicked: layersPopup.close()
            }
        }
    }

    Popup {
        id: gotoPopup

        anchors.centerIn: parent

        width: Math.min(430, page.width * 0.8)
        height: 290

        modal: true
        focus: true

        closePolicy: Popup.CloseOnEscape |
                     Popup.CloseOnPressOutside

        onClosed: page.showTools()

        background: Rectangle {
            radius: 14
            color: page.panelColor

            border.width: 1
            border.color: page.borderColor
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 12

            Label {
                text: "GO TO LOCATION"

                color: page.textColor

                font.pixelSize: 22
                font.bold: true
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: "Latitude"
            }

            TextField {
                Layout.fillWidth: true
                placeholderText: "Longitude"
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    Layout.fillWidth: true
                    text: "CANCEL"

                    onClicked: gotoPopup.close()
                }

                Button {
                    Layout.fillWidth: true
                    text: "GO"
                }
            }
        }
    }

    Timer {
        interval: 900
        running: page.visible
        repeat: true

        onTriggered: {
            page.simulatedSpeed =
                    30 + Math.floor(Math.random() * 10)

            page.simulatedRpm =
                    2200 + Math.floor(Math.random() * 500)

            page.simulatedOilPressure =
                    54 + Math.floor(Math.random() * 8)

            page.simulatedCoolant =
                    184 + Math.floor(Math.random() * 8)

            page.simulatedBattery =
                    13.9 + Math.random() * 0.5
        }
    }
}
