import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page

    property string pageTitle: "PAGE"
    property string description: "Module under development"

    property color panelColor: "#141b23"
    property color borderColor: "#2a3947"
    property color textColor: "#f4f7fa"
    property color secondaryTextColor: "#8fa1b2"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 18

        radius: 14
        color: page.panelColor

        border.width: 1
        border.color: page.borderColor

        ColumnLayout {
            anchors.centerIn: parent

            Label {
                Layout.alignment: Qt.AlignHCenter

                text: page.pageTitle
                color: page.textColor

                font.pixelSize: 40
                font.bold: true
            }

            Label {
                Layout.alignment: Qt.AlignHCenter

                text: page.description
                color: page.secondaryTextColor

                font.pixelSize: 18
            }
        }
    }
}
