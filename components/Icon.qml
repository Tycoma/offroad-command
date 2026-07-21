import QtQuick

Text {
    id: icon

    // Name of the Material Symbol (e.g. "bluetooth", "location_on")
    property string symbol: ""

    // Icon size
    property int size: 24

    // Icon color
    property color iconColor: "white"

    // Filled style
    property bool filled: false

    text: symbol

    color: iconColor

    font.family: "Material Symbols Rounded"
    font.pixelSize: size

    // Variable font settings
    font.variableAxes: ({
        "FILL": filled ? 1 : 0,
        "wght": 500,
        "GRAD": 0,
        "opsz": size
    })

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    width: size
    height: size
}
