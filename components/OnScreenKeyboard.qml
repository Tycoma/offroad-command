import QtQuick
import QtQuick.Controls
import QtQuick.VirtualKeyboard

InputPanel {
    id: keyboard

    parent: Overlay.overlay

    z: 100000

    width: parent ? parent.width : 0
    x: 0

    y: active && parent
       ? parent.height - height
       : parent
         ? parent.height
         : 0

    visible: active || y < (parent ? parent.height : 0)

    Behavior on y {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }
}
