import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: popup

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"

    width: 340
    height: 360

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
        spacing: 8

        Label {
            text: "MAP LAYERS"
            color: popup.textColor

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

            onClicked: popup.close()
        }
    }
}
