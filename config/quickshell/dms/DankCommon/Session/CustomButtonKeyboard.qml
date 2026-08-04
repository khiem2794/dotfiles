pragma ComponentBehavior: Bound

import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

DankActionButton {
    id: customButtonKeyboard
    circular: false
    property string text: ""
    width: 40
    height: 40
    property bool isShift: false
    color: Style.surface

    property bool isIcon: text === "keyboard_hide" || text === "Backspace" || text === "Enter"

    DankIcon {
        anchors.centerIn: parent
        name: {
            if (parent.text === "keyboard_hide")
                return "keyboard_hide";
            if (parent.text === "Backspace")
                return "backspace";
            if (parent.text === "Enter")
                return "keyboard_return";
            return "";
        }
        size: 20
        color: Style.surfaceText
        visible: parent.isIcon
    }

    StyledText {
        id: contentItem
        anchors.centerIn: parent
        text: parent.text
        color: Style.surfaceText
        font.pixelSize: Style.fontSizeXLarge
        font.weight: Font.Normal
        visible: !parent.isIcon
    }
}
