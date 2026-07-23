import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "pages"
import "components"
import "components/developer"

ApplicationWindow {
    id: root

    visible: true
    visibility: Window.FullScreen

    width: 1280
    height: 800

    title: "Off-Road Command"
    color: "#000000"

    property int currentPage: 0

    readonly property color backgroundColor: "#000000"
    readonly property color panelColor: "#050708"
    readonly property color borderColor: "#151a1f"
    readonly property color accentColor: "#009cff"
    readonly property color textColor: "#ffffff"
    readonly property color secondaryTextColor: "#9a9a9a"
    readonly property color warningColor: "#ffb347"
    readonly property color dangerColor: "#ff3b3b"
    readonly property color successColor: "#55d889"

    property int radioChannel: 4
    property string radioChannelName: "CHASE"
    property string radioFrequency: ""

    property int gpsSpeed: gpsBackend.speedMph
    property int gpsHeading: gpsBackend.heading
    property int gpsSatellites: gpsBackend.satellites

    property int engineRpm: 0
    property int coolantTemp: 0
    property int oilPressure: 0
    property real batteryVoltage: 0.0

    property int maxCoolantTemp: 230
    property int minOilPressure: 15
    property real minBatteryVoltage: 11.5
    property int maxEngineRpm: 6500

    property bool warningAcknowledged: false
    property string lastWarningText: ""

    function changePage(pageNumber) {
        currentPage = pageNumber
        pageStack.currentIndex = pageNumber

        logBridge.info(
            "UI",
            "Changed to page " + pageNumber
        )
    }

    function criticalWarningText() {
        if (coolantTemp >= maxCoolantTemp) {
            return "CRITICAL ENGINE WARNING - COOLANT "
                + coolantTemp
                + " F"
        }

        if (
            oilPressure <= minOilPressure
            && engineRpm > 800
        ) {
            return "CRITICAL ENGINE WARNING - OIL PRESSURE "
                + oilPressure
                + " PSI"
        }

        if (batteryVoltage <= minBatteryVoltage) {
            return "CRITICAL ELECTRICAL WARNING - BATTERY "
                + batteryVoltage.toFixed(1)
                + " V"
        }

        if (engineRpm >= maxEngineRpm) {
            return "CRITICAL ENGINE WARNING - OVER REV "
                + engineRpm
                + " RPM"
        }

        return ""
    }

    function visibleWarningText() {
        var warning = criticalWarningText()

        if (warning === "") {
            warningAcknowledged = false
            lastWarningText = ""
            return ""
        }

        if (warning !== lastWarningText) {
            warningAcknowledged = false
            lastWarningText = warning
        }

        if (warningAcknowledged)
            return ""

        return warning
    }

    Component.onCompleted: {
        logBridge.info(
            "UI",
            "Main application window loaded"
        )
    }

    Shortcut {
        sequence: "Escape"

        onActivated: {
            if (developerConsole.consoleVisible) {
                developerConsole.closeConsole()
            } else {
                root.close()
            }
        }
    }

    Shortcut {
        sequence: "F11"

        onActivated: {
            if (root.visibility === Window.FullScreen) {
                root.visibility = Window.Windowed

                logBridge.info(
                    "UI",
                    "Window changed to windowed mode"
                )
            } else {
                root.visibility = Window.FullScreen

                logBridge.info(
                    "UI",
                    "Window changed to fullscreen mode"
                )
            }
        }
    }

    Shortcut {
        sequence: "F12"

        onActivated: {
            developerConsole.toggleConsole()

            if (developerConsole.consoleVisible) {
                logBridge.info(
                    "UI",
                    "Developer console opened"
                )
            } else {
                logBridge.info(
                    "UI",
                    "Developer console closed"
                )
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        AppHeader {
            Layout.fillWidth: true
            Layout.preferredHeight: 72

            panelColor: "#000000"
            borderColor: root.borderColor
            accentColor: root.accentColor
            textColor: root.textColor
            secondaryTextColor: root.secondaryTextColor

            radioChannel: root.radioChannel
            radioChannelName: root.radioChannelName
            radioFrequency: root.radioFrequency
            gpsSatellites: root.gpsSatellites

            bluetoothConnected: mediaBackend.connected
            mediaTitle: mediaBackend.title
            mediaArtist: mediaBackend.artist

            radioConnected: true
            transmitting: false
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            StackLayout {
                id: pageStack

                anchors.fill: parent
                currentIndex: root.currentPage

                MapsPage {
                    id: mapsPage

                    panelColor: root.panelColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    secondaryTextColor:
                        root.secondaryTextColor
                    warningColor: root.warningColor
                    dangerColor: root.dangerColor
                    successColor: root.successColor
                }

                MediaPage {
                    panelColor: root.panelColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    secondaryTextColor:
                        root.secondaryTextColor
                    warningColor: root.warningColor
                    dangerColor: root.dangerColor
                    successColor: root.successColor
                }

                RadioPage {
                    panelColor: root.panelColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    secondaryTextColor:
                        root.secondaryTextColor
                    warningColor: root.warningColor
                    dangerColor: root.dangerColor
                    successColor: root.successColor

                    currentChannel: root.radioChannel

                    onChannelSelected:
                        function(channel) {
                            root.radioChannel = channel

                            logBridge.info(
                                "RADIO",
                                "Selected radio channel "
                                    + channel
                            )
                        }
                }

                PlaceholderPage {
                    pageTitle: "ENGINE"
                    description:
                        "MEFI-4 engine gauges and diagnostics"
                }

                PlaceholderPage {
                    pageTitle: "CAMERAS"
                    description:
                        "Vehicle camera system"
                }

                PlaceholderPage {
                    pageTitle: "VEHICLE"
                    description:
                        "Lights, compressor and PDM controls"
                }

                SettingsPage {
                    panelColor: root.panelColor
                    borderColor: root.borderColor
                    accentColor: root.accentColor
                    textColor: root.textColor
                    secondaryTextColor:
                        root.secondaryTextColor
                    warningColor: root.warningColor
                    dangerColor: root.dangerColor
                    successColor: root.successColor

                    bluetoothConnected:
                        mediaBackend.connected

                    gpsSatellites:
                        root.gpsSatellites

                    canConnected: false

                    coolantWarning:
                        root.maxCoolantTemp

                    oilPressureWarning:
                        root.minOilPressure

                    batteryWarning:
                        root.minBatteryVoltage

                    rpmWarning:
                        root.maxEngineRpm

                    onCoolantWarningChangedByUser:
                        function(value) {
                            root.maxCoolantTemp = value

                            logBridge.info(
                                "UI",
                                "Coolant warning set to "
                                    + value
                                    + " F"
                            )
                        }

                    onOilPressureWarningChangedByUser:
                        function(value) {
                            root.minOilPressure = value

                            logBridge.info(
                                "UI",
                                "Oil pressure warning set to "
                                    + value
                                    + " PSI"
                            )
                        }

                    onBatteryWarningChangedByUser:
                        function(value) {
                            root.minBatteryVoltage = value

                            logBridge.info(
                                "UI",
                                "Battery warning set to "
                                    + value.toFixed(1)
                                    + " V"
                            )
                        }

                    onRpmWarningChangedByUser:
                        function(value) {
                            root.maxEngineRpm = value

                            logBridge.info(
                                "UI",
                                "RPM warning set to "
                                    + value
                            )
                        }

                    onExitRequested: {
                        logBridge.info(
                            "SYSTEM",
                            "Exit requested from settings"
                        )

                        root.close()
                    }
                }
            }

            GhostSpeed {
                z: 1

                anchors.left: parent.left
                anchors.bottom: parent.bottom

                anchors.leftMargin: 20
                anchors.bottomMargin: 16

                visible:
                    root.currentPage === 0
                    && !mapsPage.toolsVisible
                    && !developerConsole.consoleVisible

                speed: root.gpsSpeed
                textColor: "white"
            }

            GhostCompass {
                z: 1

                anchors.top: parent.top
                anchors.right: parent.right

                anchors.topMargin: 16
                anchors.rightMargin: 20

                visible:
                    root.currentPage === 0
                    && !mapsPage.toolsVisible
                    && !developerConsole.consoleVisible

                heading: root.gpsHeading
                textColor: "white"
            }

            CriticalAlert {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter:
                    parent.verticalCenter

                z: 1000

                dangerColor: root.dangerColor

                // Disabled until live MEFI/CAN
                // engine data is connected.
                warningText: ""
                visible: false

                onAcknowledged: {
                    root.warningAcknowledged = true

                    logBridge.warning(
                        "SYSTEM",
                        "Critical warning acknowledged"
                    )
                }
            }
        }

        BottomNavigation {
            Layout.fillWidth: true
            Layout.preferredHeight: 78

            currentPage: root.currentPage

            panelColor: "#000000"
            borderColor: root.borderColor
            accentColor: root.accentColor
            textColor: root.textColor

            onPageSelected:
                function(pageNumber) {
                    root.changePage(pageNumber)
                }
        }
    }

    Rectangle {
        id: developerConsoleBackdrop

        anchors.fill: parent
        z: 19990

        visible: developerConsole.consoleVisible

        color: "#99000000"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                developerConsole.closeConsole()

                logBridge.info(
                    "UI",
                    "Developer console closed"
                )
            }
        }
    }

    DeveloperConsole {
        id: developerConsole

        z: 20000

        anchors.horizontalCenter:
            parent.horizontalCenter

        anchors.verticalCenter:
            parent.verticalCenter

        width: Math.min(
            parent.width - 40,
            1220
        )

        height: Math.min(
            parent.height - 40,
            740
        )

        onCloseRequested: {
            logBridge.info(
                "UI",
                "Developer console closed"
            )
        }
    }

    OnScreenKeyboard {
        id: onScreenKeyboard

        z: 1000

        anchors.left: parent.left
        anchors.right: parent.right
    }
}
