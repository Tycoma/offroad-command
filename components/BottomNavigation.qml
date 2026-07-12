import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: navigation

    property int currentPage: 0

    property color panelColor: "#0c1117"
    property color borderColor: "#2a3947"
    property color accentColor: "#2da8ff"
    property color textColor: "#f4f7fa"

    signal pageSelected(int pageNumber)

    implicitHeight: 70
    color: panelColor

    border.width: 1
    border.color: borderColor

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        NavButton {
            text: "MAPS"
            selected: navigation.currentPage === 0

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(0)
        }

        NavButton {
            text: "MEDIA"
            selected: navigation.currentPage === 1

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(1)
        }

        NavButton {
            text: "RADIO"
            selected: navigation.currentPage === 2

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(2)
        }

        NavButton {
            text: "ENGINE"
            selected: navigation.currentPage === 3

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(3)
        }

        NavButton {
            text: "CAMERAS"
            selected: navigation.currentPage === 4

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(4)
        }

        NavButton {
            text: "VEHICLE"
            selected: navigation.currentPage === 5

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(5)
        }

        NavButton {
            text: "SETTINGS"
            selected: navigation.currentPage === 6

            accentColor: navigation.accentColor
            panelColor: navigation.panelColor
            borderColor: navigation.borderColor
            textColor: navigation.textColor

            onClicked: navigation.pageSelected(6)
        }
    }
}
