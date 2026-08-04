import QtQuick
import qs.DankCommon.Common

Column {
    id: root
    property string text: ""
    property var incrementTooltipText: ""
    property var decrementTooltipText: ""
    property var onIncrement: undefined
    property var onDecrement: undefined
    property string incrementIconName: "keyboard_arrow_up"
    property string decrementIconName: "keyboard_arrow_down"

    property bool incrementEnabled: true
    property bool decrementEnabled: true

    property color textColor: Style.surfaceText
    property color iconColor: Style.withAlpha(Style.surfaceText, 0.5)
    property color backgroundColor: Style.primary

    property int textSize: Style.fontSizeSmall
    property var iconSize: 12
    property int buttonSize: 20
    property int horizontalPadding: Style.spacingL

    readonly property bool effectiveIncrementEnabled: root.onIncrement ? root.incrementEnabled : false
    readonly property bool effectiveDecrementEnabled: root.onDecrement ? root.decrementEnabled : false

    width: Math.max(buttonSize * 2, root.implicitWidth + horizontalPadding * 2)
    spacing: Style.spacingXS

    DankActionButton {
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: root.effectiveIncrementEnabled
        iconColor: root.effectiveIncrementEnabled ? root.iconColor : Style.blendAlpha(root.iconColor, 0.5)
        iconSize: root.iconSize
        buttonSize: root.buttonSize
        iconName: root.incrementIconName
        onClicked: if (typeof root.onIncrement === 'function')
            root.onIncrement()
        tooltipText: root.incrementTooltipText
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        Item {
            width: 5
            height: 1
        }
        StyledText {
            isMonospace: true
            text: root.text
            font.pixelSize: root.textSize
            color: root.textColor
        }
        Item {
            width: 5
            height: 1
        }
    }

    DankActionButton {
        anchors.horizontalCenter: parent.horizontalCenter
        enabled: root.effectiveDecrementEnabled
        iconColor: root.effectiveDecrementEnabled ? root.iconColor : Style.blendAlpha(root.iconColor, 0.5)
        iconSize: root.iconSize
        buttonSize: root.buttonSize
        iconName: root.decrementIconName
        onClicked: if (typeof root.onDecrement === 'function')
            root.onDecrement()
        tooltipText: root.decrementTooltipText
    }
}
