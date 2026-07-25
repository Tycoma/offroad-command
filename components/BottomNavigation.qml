import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: navigation

    property int currentPage: 0

    property color panelColor: "#000000"
    property color borderColor: "#151a1f"
    property color accentColor: "#009cff"
    property color textColor: "#ffffff"
    property color secondaryTextColor: "#9a9a9a"

    signal pageSelected(int pageNumber)

    implicitHeight: 60
    color: "#000000"

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 1
        color: navigation.borderColor
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        NavItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: "MAPS"
            iconType: "map"
            selected: navigation.currentPage === 0

            onClicked: navigation.pageSelected(0)
        }

        NavItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: "RADIO"
            iconType: "radio"
            selected: navigation.currentPage === 2

            onClicked: navigation.pageSelected(2)
        }

        NavItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: "VEHICLE"
            iconType: "gauge"
            selected: navigation.currentPage === 5

            onClicked: navigation.pageSelected(5)
        }

        NavItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: "MEDIA"
            iconType: "music"
            selected: navigation.currentPage === 1

            onClicked: navigation.pageSelected(1)
        }

        NavItem {
            Layout.fillWidth: true
            Layout.fillHeight: true

            label: "SETTINGS"
            iconType: "settings"
            selected: navigation.currentPage === 6

            onClicked: navigation.pageSelected(6)
        }
    }

    component NavItem: Item {
        id: navItem

        property string label: ""
        property string iconType: ""
        property bool selected: false

        signal clicked()

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 24
            anchors.rightMargin: 24

            height: 3
            radius: 1.5

            visible: navItem.selected
            color: navigation.accentColor
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2

            spacing: 1

            Item {
                width: 42
                height: 37

                anchors.horizontalCenter: parent.horizontalCenter

                Canvas {
                    id: iconCanvas
                    anchors.fill: parent
                    visible: navItem.iconType !== "music"

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        ctx.scale(0.72, 0.72)

                        var iconColor = navItem.selected
                                ? navigation.accentColor
                                : "#a5a5a5"

                        ctx.strokeStyle = iconColor
                        ctx.fillStyle = iconColor
                        ctx.lineWidth = 3
                        ctx.lineCap = "round"
                        ctx.lineJoin = "round"

                        if (navItem.iconType === "map") {
                            ctx.beginPath()
                            ctx.moveTo(5, 11)
                            ctx.lineTo(19, 6)
                            ctx.lineTo(36, 12)
                            ctx.lineTo(52, 6)
                            ctx.lineTo(52, 41)
                            ctx.lineTo(36, 46)
                            ctx.lineTo(19, 40)
                            ctx.lineTo(5, 46)
                            ctx.closePath()
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.moveTo(19, 6)
                            ctx.lineTo(19, 40)
                            ctx.moveTo(36, 12)
                            ctx.lineTo(36, 46)
                            ctx.stroke()
                        }

                        else if (navItem.iconType === "radio") {
                            ctx.strokeRect(8, 18, 41, 27)

                            ctx.beginPath()
                            ctx.moveTo(12, 18)
                            ctx.lineTo(44, 6)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(19, 33, 7, 0, Math.PI * 2)
                            ctx.stroke()

                            ctx.strokeRect(33, 26, 11, 5)
                        }

                        else if (navItem.iconType === "gauge") {
                            ctx.beginPath()
                            ctx.arc(29, 32, 21, Math.PI, 0)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.moveTo(29, 32)
                            ctx.lineTo(42, 17)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(29, 32, 4, 0, Math.PI * 2)
                            ctx.fill()

                            ctx.beginPath()
                            ctx.moveTo(10, 32)
                            ctx.lineTo(14, 32)
                            ctx.moveTo(15, 20)
                            ctx.lineTo(18, 23)
                            ctx.moveTo(29, 11)
                            ctx.lineTo(29, 15)
                            ctx.moveTo(43, 20)
                            ctx.lineTo(40, 23)
                            ctx.moveTo(48, 32)
                            ctx.lineTo(44, 32)
                            ctx.stroke()
                        }

                        else if (navItem.iconType === "settings") {
                            ctx.beginPath()
                            ctx.arc(29, 26, 16, 0, Math.PI * 2)
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(29, 26, 6, 0, Math.PI * 2)
                            ctx.stroke()

                            for (var i = 0; i < 8; i++) {
                                var angle = i * Math.PI / 4
                                var x1 = 29 + Math.cos(angle) * 18
                                var y1 = 26 + Math.sin(angle) * 18
                                var x2 = 29 + Math.cos(angle) * 23
                                var y2 = 26 + Math.sin(angle) * 23

                                ctx.beginPath()
                                ctx.moveTo(x1, y1)
                                ctx.lineTo(x2, y2)
                                ctx.stroke()
                            }
                        }

                        else {
                            ctx.beginPath()
                            ctx.arc(13, 26, 5, 0, Math.PI * 2)
                            ctx.arc(29, 26, 5, 0, Math.PI * 2)
                            ctx.arc(45, 26, 5, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }

                    Connections {
                        target: navItem

                        function onSelectedChanged() {
                            iconCanvas.requestPaint()
                        }

                        function onIconTypeChanged() {
                            iconCanvas.requestPaint()
                        }
                    }
                }

                Icon {
                    anchors.centerIn: parent

                    visible: navItem.iconType === "music"

                    symbol: "music_note"
                    size: 30
                    filled: navItem.selected

                    iconColor: navItem.selected
                               ? navigation.accentColor
                               : "#a5a5a5"
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: navItem.label

                color: navItem.selected
                       ? navigation.accentColor
                       : navigation.secondaryTextColor

                font.pixelSize: 12
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked: navItem.clicked()
        }
    }
}
