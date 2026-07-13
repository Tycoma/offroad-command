import QtQuick
import QtQuick.VirtualKeyboard

InputPanel {
    id: keyboard

    property int animationDuration: 180

    z: 10000

    anchors.left: parent.left
    anchors.right: parent.right

    y: active
       ? parent.height - height
       : parent.height

    visible: y < parent.height
    active: Qt.inputMethod.visible

    Behavior on y {
        NumberAnimation {
            duration: keyboard.animationDuration
            easing.type: Easing.OutCubic
        }
    }
}
