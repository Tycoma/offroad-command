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

    signal coolantWarningChangedByUser(int value)
    signal oilPressureWarningChangedByUser(int value)
    signal batteryWarningChangedByUser(real value)
    signal rpmWarningChangedByUser(int value)
    signal exitRequested()

    Rectangle {
        anchors.fill: parent
        color: "#090d12"

        Flickable {
            anchors.fill: parent

            contentWidth: width
            contentHeight: settingsColumn.implicitHeight + 50

            clip: true

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            ColumnLayout {
                id: settingsColumn

                width: parent.width
                spacing: 18

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20

                Label {
                    text: "SYSTEM SETTINGS"
                    color: page.textColor
                    font.pixelSize: 28
                    font.bold: true
                }

                Label {
                    text: "Display, Bluetooth, system status, and warning limits"
                    color: page.secondaryTextColor
                    font.pixelSize: 14
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 320

                    radius: 16
                    color: page.panelColor

                    border.width: 1
                    border.color: page.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 22

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1.15

                            spacing: 9

                            Label {
                                text: "PREVIOUS PHONE"
                                color: page.textColor
                                font.pixelSize: 21
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true

                                text: mediaBackend.previousPhoneName
                                color: page.accentColor
                                elide: Text.ElideRight

                                font.pixelSize: 25
                                font.bold: true
                            }

                            Label {
                                text: mediaBackend.previousPhoneMac
                                color: page.secondaryTextColor
                                font.pixelSize: 13
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

                            Item {
                                Layout.fillHeight: true
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            color: page.borderColor
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1

                            spacing: 10

                            Label {
                                text: "PHONE AUDIO"
                                color: page.textColor
                                font.pixelSize: 21
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true

                                text:
                                    mediaBackend.previousPhoneConnected
                                    ? "Bluetooth audio is available."
                                    : "Enable Bluetooth on the previous phone, then press Connect."

                                color: page.secondaryTextColor
                                wrapMode: Text.WordWrap
                                font.pixelSize: 13
                            }

                            Label {
                                Layout.fillWidth: true

                                text: mediaBackend.title

                                color: page.textColor
                                elide: Text.ElideRight

                                font.pixelSize: 17
                                font.bold: true
                            }

                            Label {
                                Layout.fillWidth: true

                                text: mediaBackend.artist

                                color: page.accentColor
                                elide: Text.ElideRight

                                font.pixelSize: 14
                            }

                            Label {
                                Layout.fillWidth: true

                                text: mediaBackend.connectionMessage

                                visible:
                                    mediaBackend.connectionMessage.length > 0

                                color: page.warningColor
                                wrapMode: Text.WordWrap
                                font.pixelSize: 12
                            }

                            Item {
                                Layout.fillHeight: true
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 58

                                Button {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    text:
                                        mediaBackend.previousPhoneConnected
                                        ? "RECONNECT"
                                        : "CONNECT PREVIOUS PHONE"

                                    onClicked: {
                                        mediaBackend.connectPreviousPhone()
                                    }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    text: "DISCONNECT"

                                    enabled:
                                        mediaBackend.previousPhoneConnected

                                    onClicked: {
                                        mediaBackend.disconnectPreviousPhone()
                                    }
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48

                                text: "REFRESH PHONE DATA"

                                onClicked: {
                                    mediaBackend.refreshPreviousPhone()
                                    mediaBackend.refresh()
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 18

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 285

                        radius: 16
                        color: page.panelColor

                        border.width: 1
                        border.color: page.borderColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Label {
                                text: "DISPLAY"
                                color: page.textColor
                                font.pixelSize: 21
                                font.bold: true
                            }

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
                                checked: page.automaticBrightness

                                onToggled:
                                    page.automaticBrightness = checked
                            }

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 285

                        radius: 16
                        color: page.panelColor

                        border.width: 1
                        border.color: page.borderColor

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 20
                            spacing: 12

                            Label {
                                text: "CONNECTIONS"
                                color: page.textColor
                                font.pixelSize: 21
                                font.bold: true
                            }

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
                                    ? page.gpsSatellites + " SATELLITES"
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

                            Item {
                                Layout.fillHeight: true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 360

                    radius: 16
                    color: page.panelColor

                    border.width: 1
                    border.color: page.borderColor

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Label {
                            text: "CRITICAL ENGINE WARNING LIMITS"
                            color: page.textColor
                            font.pixelSize: 21
                            font.bold: true
                        }

                        Label {
                            text: "These limits control the full-screen warning banner."
                            color: page.warningColor
                            font.pixelSize: 13
                        }

                        SettingSpinRow {
                            labelText: "Maximum coolant temperature"
                            suffixText: "F"
                            minimumValue: 180
                            maximumValue: 280
                            stepValue: 1
                            currentValue: page.coolantWarning

                            onNewValue: function(value) {
                                page.coolantWarning = value
                                page.coolantWarningChangedByUser(value)
                            }
                        }

                        SettingSpinRow {
                            labelText: "Minimum oil pressure"
                            suffixText: "PSI"
                            minimumValue: 5
                            maximumValue: 60
                            stepValue: 1
                            currentValue: page.oilPressureWarning

                            onNewValue: function(value) {
                                page.oilPressureWarning = value
                                page.oilPressureWarningChangedByUser(value)
                            }
                        }

                        SettingSpinRow {
                            labelText: "Maximum engine speed"
                            suffixText: "RPM"
                            minimumValue: 3000
                            maximumValue: 9000
                            stepValue: 100
                            currentValue: page.rpmWarning

                            onNewValue: function(value) {
                                page.rpmWarning = value
                                page.rpmWarningChangedByUser(value)
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 135

                    radius: 16
                    color: page.panelColor

                    border.width: 1
                    border.color: page.borderColor

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 18

                        ColumnLayout {
                            Layout.fillWidth: true

                            Label {
                                text: "APPLICATION"
                                color: page.textColor
                                font.pixelSize: 20
                                font.bold: true
                            }

                            Label {
                                text: "Close the passenger-display application."
                                color: page.secondaryTextColor
                                font.pixelSize: 13
                            }
                        }

                        Button {
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 58

                            text: "EXIT APPLICATION"

                            onClicked: page.exitRequested()
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: 20
                }
            }
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
            Layout.preferredWidth: 260

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
