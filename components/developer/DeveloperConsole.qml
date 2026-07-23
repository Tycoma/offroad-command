import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: developerConsoleRoot

    property bool consoleVisible: false
    property bool paused: false
    property string selectedLevel: "ALL"
    property string selectedModule: "ALL"

    signal closeRequested()

    visible: consoleVisible
    enabled: visible

    color: "#ed0b1015"
    border.color: "#425466"
    border.width: 1
    radius: 12

    function openConsole() {
        consoleVisible = true
        paused = false

        Qt.callLater(function() {
            logList.positionViewAtEnd()
        })
    }

    function closeConsole() {
        consoleVisible = false
        closeRequested()
    }

    function toggleConsole() {
        if (consoleVisible)
            closeConsole()
        else
            openConsole()
    }

    function entryVisible(level, module) {
        const levelMatches =
            selectedLevel === "ALL" ||
            selectedLevel === level

        const moduleMatches =
            selectedModule === "ALL" ||
            selectedModule === module

        return levelMatches && moduleMatches
    }

    Connections {
        target: consoleLogModel

        function onCountChanged() {
            if (
                developerConsoleRoot.consoleVisible &&
                !developerConsoleRoot.paused
            ) {
                Qt.callLater(function() {
                    logList.positionViewAtEnd()
                })
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            spacing: 8

            Label {
                text: "DEVELOPER CONSOLE"
                color: "#f4f7fa"
                font.pixelSize: 20
                font.bold: true
                Layout.fillWidth: true
            }

            Label {
                text:
                    consoleLogModel.getCount() +
                    " EVENTS"

                color: "#8fa1b2"
                font.pixelSize: 13
            }

            Button {
                text: developerConsoleRoot.paused ? "RESUME" : "PAUSE"

                onClicked: {
                    developerConsoleRoot.paused = !developerConsoleRoot.paused

                    if (!developerConsoleRoot.paused) {
                        logList.positionViewAtEnd()
                    }
                }
            }

            Button {
                text: "CLEAR"

                onClicked: {
                    logBridge.clear()
                }
            }

            Button {
                text: "SAVE"

                onClicked: {
                    logBridge.saveLog(
                        "logs/developer-developerConsoleRoot.log"
                    )
                }
            }

            Button {
                text: "CLOSE"

                onClicked: {
                    developerConsoleRoot.closeConsole()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 8

            Label {
                text: "LEVEL"
                color: "#8fa1b2"
                font.pixelSize: 13
            }

            ComboBox {
                id: levelFilter

                model: [
                    "ALL",
                    "DEBUG",
                    "INFO",
                    "WARNING",
                    "ERROR"
                ]

                onCurrentTextChanged: {
                    developerConsoleRoot.selectedLevel =
                        currentText
                }
            }

            Label {
                text: "MODULE"
                color: "#8fa1b2"
                font.pixelSize: 13
            }

            ComboBox {
                id: moduleFilter

                model: [
                    "ALL",
                    "SYSTEM",
                    "MAP",
                    "WAYPOINT",
                    "GPS",
                    "UI",
                    "CAN",
                    "RADIO",
                    "BLUETOOTH"
                ]

                onCurrentTextChanged: {
                    developerConsoleRoot.selectedModule =
                        currentText
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: "F12 TO TOGGLE"
                color: "#607487"
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#080c10"
            border.color: "#273746"
            border.width: 1
            radius: 8
            clip: true

            ListView {
                id: logList

                anchors.fill: parent
                anchors.margins: 8

                model: consoleLogModel
                spacing: 3
                clip: true

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: Rectangle {
                    required property string time
                    required property string module
                    required property string level
                    required property string message

                    width: logList.width
                    height: visible
                        ? messageRow.implicitHeight + 10
                        : 0

                    visible: developerConsoleRoot.entryVisible(
                        level,
                        module
                    )

                    color: index % 2 === 0
                        ? "#10161d"
                        : "#0c1218"

                    radius: 4

                    RowLayout {
                        id: messageRow

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter:
                            parent.verticalCenter

                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        spacing: 12

                        Label {
                            text: time
                            color: "#718497"
                            font.family: "monospace"
                            font.pixelSize: 13
                            Layout.preferredWidth: 72
                        }

                        Label {
                            text: module
                            color: "#6fbfff"
                            font.family: "monospace"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.preferredWidth: 100
                        }

                        Label {
                            text: level

                            color: {
                                if (level === "ERROR")
                                    return "#ff5d5d"

                                if (level === "WARNING")
                                    return "#ffb347"

                                if (level === "DEBUG")
                                    return "#a58cff"

                                return "#55d889"
                            }

                            font.family: "monospace"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.preferredWidth: 84
                        }

                        Label {
                            text: message
                            color: "#d8e1e9"
                            font.family: "monospace"
                            font.pixelSize: 13
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent

                visible:
                    consoleLogModel.getCount() === 0

                text: "No developer events yet"
                color: "#607487"
                font.pixelSize: 16
            }
        }
    }
}
