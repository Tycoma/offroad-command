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

    width: Math.min(430, parent ? parent.width * 0.8 : 430)
    height: 320

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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Label {
            text: "GO TO LOCATION"
            color: popup.textColor

            font.pixelSize: 22
            font.bold: true
        }

        TextField {
    id: latitudeField

    Layout.fillWidth: true

    placeholderText: "Latitude"
    inputMethodHints:
        Qt.ImhFormattedNumbersOnly |
        Qt.ImhPreferNumbers

    onAccepted: longitudeField.forceActiveFocus()
}

	TextField {
    id: longitudeField

    Layout.fillWidth: true

    placeholderText: "Longitude"
    inputMethodHints:
        Qt.ImhFormattedNumbersOnly |
        Qt.ImhPreferNumbers
}

        Label {
            id: statusLabel

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

                text: "GO"

                onClicked: {
                    var latitude =
                            parseFloat(latitudeField.text)

                    var longitude =
                            parseFloat(longitudeField.text)

                    if (
                        isNaN(latitude)
                        || isNaN(longitude)
                        || latitude < -90
                        || latitude > 90
                        || longitude < -180
                        || longitude > 180
                    ) {
                        statusLabel.text =
                                "Enter valid coordinates."
                        return
                    }

                    if (!popup.mapViewRef) {
                        statusLabel.text =
                                "Map is not available."
                        return
                    }

                    popup.mapViewRef.runJavaScript(
                        "map.setView([" +
                        latitude + "," +
                        longitude +
                        "], 15);"
                    )

                    statusLabel.text = ""
                    popup.close()
                }
            }
        }
    }
}
