import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Button {
    id: control

    property bool selected: false
    property color accentColor: "#2da8ff"
    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"

    Layout.fillWidth: true
    Layout.fillHeight: true

    background: Rectangle {
        radius: 8

        color: control.selected
               ? control.accentColor
               : control.down
                 ? "#1b2530"
                 : control.panelColor

        border.width: 1
        border.color: control.selected
                      ? control.accentColor
                      : control.borderColor
    }

    contentItem: Label {
        text: control.text

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: control.selected
               ? "#06101a"
               : control.textColor

        font.pixelSize: 13
        font.bold: true
    }
}
