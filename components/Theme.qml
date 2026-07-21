pragma Singleton

import QtQuick

QtObject {

    //
    // Colors
    //

    readonly property color background: "#000000"

    readonly property color panel: "#11161d"

    readonly property color border: "#2a3138"

    readonly property color text: "#ffffff"

    readonly property color secondaryText: "#93a2b2"

    readonly property color accent: "#169cff"

    readonly property color success: "#6EE600"

    readonly property color warning: "#FFA000"

    readonly property color danger: "#F44336"

    //
    // Header
    //

    readonly property int headerHeight: 72

    //
    // Fonts
    //

    readonly property int clockSize: 20

    readonly property int titleSize: 18

    readonly property int subtitleSize: 14

    readonly property int channelSize: 18

    readonly property int gpsSize: 17

    readonly property int iconSize: 22

    //
    // Radius
    //

    readonly property int radius: 8

    //
    // Margins
    //

    readonly property int margin: 16
}
