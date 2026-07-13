import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string pageTitle: "SETTINGS"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"
    property color warningColor: "#ffb347"
    property color dangerColor: "#ff3b3b"
    property color successColor: "#55d889"

    property bool bluetoothConnected: false
    property int gpsSatellites: 0
    property bool canConnected: false

    property int coolantWarning: 230
    property int oilPressureWarning: 15
    property real batteryWarning: 11.5
    property int rpmWarning: 6500

    property bool metricUnits: false
    property bool nightMode: true
    property bool automaticBrightness: false
    property int screenBrightness: 80

    property int selectedCategory: 0

    signal coolantWarningChangedByUser(int value)
    signal oilPressureWarningChangedByUser(int value)
    signal batteryWarningChangedByUser(real value)
    signal rpmWarningChangedByUser(int value)
    signal exitRequested()

    Rectangle {
        anchors.fill: parent
        color: "#090d12"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true

                radius: 16
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    Label {
                        text: "SETTINGS"
                        color: page.textColor

                        font.pixelSize: 27
                        font.bold: true
                    }

                    Label {
                        text: "SYSTEM CONFIGURATION"
                        color: page.secondaryTextColor

                        font.pixelSize: 12
                        font.bold: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: page.borderColor
                    }

                    ListView {
                        id: categoryList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        spacing: 6
                        clip: true

                        model: [
                            "GENERAL",
                            "NAVIGATION",
                            "BLUETOOTH",
                            "RADIO",
                            "DISPLAY",
                            "VEHICLE",
                            "ENGINE",
                            "MAPS",
                            "UPDATES",
                            "ABOUT"
                        ]

                        delegate: Button {
                            required property string modelData
                            required property int index

                            width: categoryList.width
                            height: 50

                            text: modelData

                            onClicked: {
                                page.selectedCategory = index
                                settingsStack.currentIndex = index
                            }

                            background: Rectangle {
                                radius: 9

                                color:
                                    page.selectedCategory === index
                                    ? page.accentColor
                                    : parent.down
                                      ? "#233140"
                                      : "#1b2530"

                                border.width: 1

                                border.color:
                                    page.selectedCategory === index
                                    ? page.accentColor
                                    : page.borderColor
                            }

                            contentItem: Label {
                                text: parent.text

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                leftPadding: 14

                                color:
                                    page.selectedCategory === index
                                    ? "#06101a"
                                    : page.textColor

                                font.pixelSize: 14
                                font.bold: true
                            }
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50

                        text: "EXIT APPLICATION"

                        onClicked: page.exitRequested()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                radius: 16
                color: page.panelColor

                border.width: 1
                border.color: page.borderColor

                StackLayout {
                    id: settingsStack

                    anchors.fill: parent
                    anchors.margins: 22

                    currentIndex: page.selectedCategory

                    Flickable {
                        contentWidth: width
                        contentHeight: generalColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: generalColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "GENERAL"
                                subtitleText:
                                    "Units, system status, and general preferences"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 210

                                titleText: "MEASUREMENT UNITS"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 8

                                    RadioButton {
                                        text: "US units"

                                        checked: !page.metricUnits

                                        onClicked:
                                            page.metricUnits = false
                                    }

                                    Label {
                                        text:
                                            "MPH, feet, PSI, Fahrenheit"

                                        color: page.secondaryTextColor
                                        font.pixelSize: 13
                                    }

                                    RadioButton {
                                        text: "Metric units"

                                        checked: page.metricUnits

                                        onClicked:
                                            page.metricUnits = true
                                    }

                                    Label {
                                        text:
                                            "km/h, meters, kPa, Celsius"

                                        color: page.secondaryTextColor
                                        font.pixelSize: 13
                                    }
                                }
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 250

                                titleText: "SYSTEM STATUS"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 8

                                    ConnectionRow {
                                        labelText: "BLUETOOTH"

                                        statusText:
                                            mediaBackend.previousPhoneConnected
                                            ? "CONNECTED"
                                            : "OFFLINE"

                                        statusColor:
                                            mediaBackend.previousPhoneConnected
                                            ? page.successColor
                                            : page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "GPS"

                                        statusText:
                                            page.gpsSatellites > 0
                                            ? page.gpsSatellites
                                              + " SATELLITES"
                                            : "OFFLINE"

                                        statusColor:
                                            page.gpsSatellites > 0
                                            ? page.successColor
                                            : page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "CAN BUS"

                                        statusText:
                                            page.canConnected
                                            ? "CONNECTED"
                                            : "OFFLINE"

                                        statusColor:
                                            page.canConnected
                                            ? page.successColor
                                            : page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "WI-FI"
                                        statusText: "READY"
                                        statusColor: page.successColor
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: navigationColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: navigationColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "NAVIGATION"
                                subtitleText:
                                    "Routes, tracks, waypoints, imports, and exports"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 250

                                titleText: "GPX DATA"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 12

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "Import or export routes, tracks, and waypoints from Garmin, Avenza, Gaia GPS, onX, and other GPX-compatible applications."

                                        color: page.secondaryTextColor
                                        wrapMode: Text.WordWrap
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 58
                                        spacing: 12

                                        Button {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            text: "IMPORT GPX"

                                            onClicked: {
                                                navigationStatus.text =
                                                    "GPX import backend will be connected next."
                                            }
                                        }

                                        Button {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            text: "EXPORT GPX"

                                            onClicked: {
                                                navigationStatus.text =
                                                    "GPX export backend will be connected next."
                                            }
                                        }
                                    }

                                    Label {
                                        id: navigationStatus

                                        Layout.fillWidth: true

                                        text: ""
                                        color: page.warningColor
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 220

                                titleText: "NAVIGATION STORAGE"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 12

                                    Label {
                                        text:
                                            "Import folder"

                                        color: page.secondaryTextColor
                                    }

                                    Label {
                                        text:
                                            "~/passenger-display/import"

                                        color: page.textColor
                                        font.bold: true
                                    }

                                    Label {
                                        text:
                                            "Export folder"

                                        color: page.secondaryTextColor
                                    }

                                    Label {
                                        text:
                                            "~/passenger-display/export"

                                        color: page.textColor
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: bluetoothColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: bluetoothColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "BLUETOOTH"
                                subtitleText:
                                    "Phone pairing, reconnection, and media status"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 420

                                titleText: "PREVIOUS PHONE"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 10

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            mediaBackend.previousPhoneName

                                        color: page.accentColor
                                        elide: Text.ElideRight

                                        font.pixelSize: 25
                                        font.bold: true
                                    }

                                    Label {
                                        text:
                                            mediaBackend.previousPhoneMac

                                        color: page.secondaryTextColor
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 1
                                        color: page.borderColor
                                    }

                                    StatusLine {
                                        labelText: "PAIRED"

                                        statusText:
                                            mediaBackend.previousPhonePaired
                                            ? "YES"
                                            : "NO"

                                        active:
                                            mediaBackend.previousPhonePaired
                                    }

                                    StatusLine {
                                        labelText: "TRUSTED"

                                        statusText:
                                            mediaBackend.previousPhoneTrusted
                                            ? "YES"
                                            : "NO"

                                        active:
                                            mediaBackend.previousPhoneTrusted
                                    }

                                    StatusLine {
                                        labelText: "CONNECTION"

                                        statusText:
                                            mediaBackend.previousPhoneConnected
                                            ? "CONNECTED"
                                            : "DISCONNECTED"

                                        active:
                                            mediaBackend.previousPhoneConnected
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            mediaBackend.connectionMessage

                                        visible:
                                            mediaBackend.connectionMessage.length
                                            > 0

                                        color: page.warningColor
                                        wrapMode: Text.WordWrap
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 58
                                        spacing: 12

                                        Button {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            text:
                                                mediaBackend.previousPhoneConnected
                                                ? "RECONNECT"
                                                : "CONNECT PREVIOUS PHONE"

                                            onClicked:
                                                mediaBackend.connectPreviousPhone()
                                        }

                                        Button {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            text: "DISCONNECT"

                                            enabled:
                                                mediaBackend.previousPhoneConnected

                                            onClicked:
                                                mediaBackend.disconnectPreviousPhone()
                                        }
                                    }

                                    Button {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 50

                                        text: "REFRESH PHONE DATA"

                                        onClicked: {
                                            mediaBackend.refreshPreviousPhone()
                                            mediaBackend.refresh()
                                        }
                                    }
                                }
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 190

                                titleText: "CURRENT MEDIA"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 8

                                    Label {
                                        Layout.fillWidth: true

                                        text: mediaBackend.title
                                        color: page.textColor
                                        elide: Text.ElideRight

                                        font.pixelSize: 19
                                        font.bold: true
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text: mediaBackend.artist
                                        color: page.accentColor
                                        elide: Text.ElideRight

                                        font.pixelSize: 15
                                    }

                                    Label {
                                        text:
                                            mediaBackend.playbackStatus

                                        color: page.secondaryTextColor
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: radioColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: radioColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "RADIO"
                                subtitleText:
                                    "VHF channel and radio configuration"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 250

                                titleText: "RADIO STATUS"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 12

                                    ConnectionRow {
                                        labelText: "RADIO HARDWARE"
                                        statusText: "SIMULATION"
                                        statusColor: page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "CURRENT CHANNEL"
                                        statusText: "SEE RADIO PAGE"
                                        statusColor: page.accentColor
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "Channel programming and frequency storage will be connected when the VHF hardware is installed."

                                        color: page.secondaryTextColor
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: displayColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: displayColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "DISPLAY"
                                subtitleText:
                                    "Brightness, appearance, and automatic dimming"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 310

                                titleText: "SCREEN"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 12

                                    Label {
                                        text:
                                            "BRIGHTNESS  "
                                            + brightnessSlider.value.toFixed(0)
                                            + "%"

                                        color: page.secondaryTextColor
                                        font.bold: true
                                    }

                                    Slider {
                                        id: brightnessSlider

                                        Layout.fillWidth: true

                                        from: 10
                                        to: 100
                                        stepSize: 1

                                        value: page.screenBrightness

                                        onMoved: {
                                            page.screenBrightness =
                                                Math.round(value)
                                        }
                                    }

                                    Switch {
                                        text: "Night mode"
                                        checked: page.nightMode

                                        onToggled:
                                            page.nightMode = checked
                                    }

                                    Switch {
                                        text: "Automatic brightness"

                                        checked:
                                            page.automaticBrightness

                                        onToggled:
                                            page.automaticBrightness =
                                                checked
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: vehicleColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: vehicleColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "VEHICLE"
                                subtitleText:
                                    "CAN bus, PDM, accessories, and vehicle configuration"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 260

                                titleText: "VEHICLE CONNECTIONS"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 10

                                    ConnectionRow {
                                        labelText: "CAN BUS"

                                        statusText:
                                            page.canConnected
                                            ? "CONNECTED"
                                            : "OFFLINE"

                                        statusColor:
                                            page.canConnected
                                            ? page.successColor
                                            : page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "PDM"
                                        statusText: "NOT INSTALLED"
                                        statusColor: page.warningColor
                                    }

                                    ConnectionRow {
                                        labelText: "CAMERAS"
                                        statusText: "NOT CONFIGURED"
                                        statusColor: page.warningColor
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: engineColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: engineColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "ENGINE"
                                subtitleText:
                                    "Critical warning thresholds and MEFI-4 configuration"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 390

                                titleText: "CRITICAL WARNING LIMITS"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 14

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "These limits control the flashing full-screen warning banner."

                                        color: page.warningColor
                                        wrapMode: Text.WordWrap
                                    }

                                    SettingSpinRow {
                                        labelText:
                                            "Maximum coolant temperature"

                                        suffixText: "F"
                                        minimumValue: 180
                                        maximumValue: 280
                                        stepValue: 1
                                        currentValue:
                                            page.coolantWarning

                                        onNewValue: function(value) {
                                            page.coolantWarning = value

                                            page.coolantWarningChangedByUser(
                                                value
                                            )
                                        }
                                    }

                                    SettingSpinRow {
                                        labelText:
                                            "Minimum oil pressure"

                                        suffixText: "PSI"
                                        minimumValue: 5
                                        maximumValue: 60
                                        stepValue: 1
                                        currentValue:
                                            page.oilPressureWarning

                                        onNewValue: function(value) {
                                            page.oilPressureWarning =
                                                value

                                            page.oilPressureWarningChangedByUser(
                                                value
                                            )
                                        }
                                    }

                                    SettingSpinRow {
                                        labelText:
                                            "Maximum engine speed"

                                        suffixText: "RPM"
                                        minimumValue: 3000
                                        maximumValue: 9000
                                        stepValue: 100
                                        currentValue:
                                            page.rpmWarning

                                        onNewValue: function(value) {
                                            page.rpmWarning = value

                                            page.rpmWarningChangedByUser(
                                                value
                                            )
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Label {
                                            Layout.preferredWidth: 280

                                            text:
                                                "Minimum battery voltage"

                                            color: page.textColor
                                            font.bold: true
                                        }

                                        Slider {
                                            id: batterySlider

                                            Layout.fillWidth: true

                                            from: 9.0
                                            to: 14.0
                                            stepSize: 0.1

                                            value:
                                                page.batteryWarning

                                            onMoved: {
                                                page.batteryWarning =
                                                    value

                                                page.batteryWarningChangedByUser(
                                                    value
                                                )
                                            }
                                        }

                                        Label {
                                            Layout.preferredWidth: 60

                                            text:
                                                batterySlider.value.toFixed(1)
                                                + " V"

                                            color: page.accentColor
                                            font.bold: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: mapsColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: mapsColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "MAPS"
                                subtitleText:
                                    "Offline maps, layers, and storage"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 260

                                titleText: "MAP SOURCES"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 10

                                    CheckBox {
                                        text: "Street map"
                                        checked: true
                                    }

                                    CheckBox {
                                        text: "Topographic map"
                                    }

                                    CheckBox {
                                        text: "Satellite imagery"
                                    }

                                    CheckBox {
                                        text: "Public land overlay"
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "Offline map package selection will be added when MBTiles support is enabled."

                                        color: page.secondaryTextColor
                                        wrapMode: Text.WordWrap
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: updatesColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: updatesColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "UPDATES"
                                subtitleText:
                                    "Software, maps, and system updates"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 240

                                titleText: "SOFTWARE UPDATE"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 12

                                    Label {
                                        text: "Current prototype: v0.4.0"
                                        color: page.textColor
                                        font.pixelSize: 18
                                        font.bold: true
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "Git-based update checking can be added after the installation process is finalized."

                                        color: page.secondaryTextColor
                                        wrapMode: Text.WordWrap
                                    }

                                    Button {
                                        Layout.preferredWidth: 240
                                        Layout.preferredHeight: 52

                                        text: "CHECK FOR UPDATES"

                                        onClicked:
                                            updateStatus.text =
                                                "Update backend not connected yet."
                                    }

                                    Label {
                                        id: updateStatus

                                        text: ""
                                        color: page.warningColor
                                    }
                                }
                            }
                        }
                    }

                    Flickable {
                        contentWidth: width
                        contentHeight: aboutColumn.implicitHeight + 30
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        ColumnLayout {
                            id: aboutColumn

                            width: parent.width
                            spacing: 18

                            SectionTitle {
                                titleText: "ABOUT"
                                subtitleText:
                                    "System and project information"
                            }

                            SettingsCard {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 310

                                titleText: "OFF-ROAD COMMAND"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 18
                                    anchors.topMargin: 58
                                    spacing: 10

                                    Label {
                                        text:
                                            "Passenger Display Prototype"

                                        color: page.accentColor
                                        font.pixelSize: 24
                                        font.bold: true
                                    }

                                    Label {
                                        text: "Version 0.4.0"
                                        color: page.textColor
                                        font.pixelSize: 16
                                    }

                                    Label {
                                        text:
                                            "Raspberry Pi 4 Model B"

                                        color: page.secondaryTextColor
                                    }

                                    Label {
                                        text:
                                            "Qt Quick / PySide6 / Leaflet"

                                        color: page.secondaryTextColor
                                    }

                                    Label {
                                        Layout.fillWidth: true

                                        text:
                                            "Integrated off-road navigation, Bluetooth media, VHF radio, CAN telemetry, vehicle controls, and camera system."

                                        color: page.secondaryTextColor
                                        wrapMode: Text.WordWrap
                                    }

                                    Item {
                                        Layout.fillHeight: true
                                    }

                                    Button {
                                        Layout.preferredWidth: 240
                                        Layout.preferredHeight: 52

                                        text: "EXIT APPLICATION"

                                        onClicked:
                                            page.exitRequested()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component SectionTitle: ColumnLayout {
        property string titleText: ""
        property string subtitleText: ""

        Layout.fillWidth: true
        spacing: 4

        Label {
            text: parent.titleText
            color: page.textColor

            font.pixelSize: 27
            font.bold: true
        }

        Label {
            Layout.fillWidth: true

            text: parent.subtitleText
            color: page.secondaryTextColor

            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
    }

    component SettingsCard: Rectangle {
        property string titleText: ""

        radius: 14
        color: "#111820"

        border.width: 1
        border.color: page.borderColor

        Label {
            anchors.top: parent.top
            anchors.left: parent.left

            anchors.topMargin: 17
            anchors.leftMargin: 18

            text: parent.titleText
            color: page.textColor

            font.pixelSize: 20
            font.bold: true
        }
    }

    component StatusLine: RowLayout {
        property string labelText: ""
        property string statusText: ""
        property bool active: false

        Layout.fillWidth: true

        Label {
            text: parent.labelText
            color: page.secondaryTextColor

            font.pixelSize: 13
            font.bold: true
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            width: 10
            height: 10
            radius: 5

            color:
                parent.active
                ? page.successColor
                : page.warningColor
        }

        Label {
            text: parent.statusText

            color:
                parent.active
                ? page.successColor
                : page.warningColor

            font.pixelSize: 12
            font.bold: true
        }
    }

    component ConnectionRow: Rectangle {
        property string labelText: ""
        property string statusText: ""
        property color statusColor: page.warningColor

        Layout.fillWidth: true
        Layout.preferredHeight: 46

        radius: 8
        color: "#1b2530"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12

            Label {
                text: parent.parent.labelText
                color: page.textColor

                font.pixelSize: 13
                font.bold: true
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 10
                height: 10
                radius: 5
                color: parent.parent.statusColor
            }

            Label {
                text: parent.parent.statusText
                color: parent.parent.statusColor

                font.pixelSize: 12
                font.bold: true
            }
        }
    }

    component SettingSpinRow: RowLayout {
        property string labelText: ""
        property string suffixText: ""
        property int minimumValue: 0
        property int maximumValue: 100
        property int stepValue: 1
        property int currentValue: 0

        signal newValue(int value)

        Layout.fillWidth: true

        Label {
            Layout.preferredWidth: 280

            text: parent.labelText
            color: page.textColor
            font.bold: true
        }

        SpinBox {
            from: parent.minimumValue
            to: parent.maximumValue
            stepSize: parent.stepValue
            value: parent.currentValue
            editable: true

            onValueModified:
                parent.newValue(value)
        }

        Label {
            text: parent.suffixText
            color: page.secondaryTextColor
        }
    }
}
