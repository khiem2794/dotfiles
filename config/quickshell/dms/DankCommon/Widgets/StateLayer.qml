import QtQuick
import qs.DankCommon.Common

MouseArea {
    id: root

    property bool disabled: false
    property color stateColor: Style.surfaceText
    property real cornerRadius: parent && parent.radius !== undefined ? parent.radius : Style.cornerRadius
    property var tooltipText: null
    property string tooltipSide: "bottom"
    property bool enableRipple: Style.enableRippleEffects

    readonly property real stateOpacity: disabled ? 0 : pressed ? 0.12 : containsMouse ? 0.08 : 0

    anchors.fill: parent
    cursorShape: disabled ? undefined : Qt.PointingHandCursor
    hoverEnabled: true

    onPressed: mouse => {
        if (!disabled && enableRipple) {
            rippleLayer.trigger(mouse.x, mouse.y);
        }
    }

    Rectangle {
        id: stateRect
        anchors.fill: parent
        radius: root.cornerRadius
        color: Style.withAlpha(stateColor, stateOpacity)

        Behavior on color {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankColorAnim {
                duration: Style.shorterDuration
                easing.bezierCurve: Style.expressiveCurves.standardDecel
            }
        }
    }

    DankRipple {
        id: rippleLayer
        anchors.fill: parent
        rippleColor: root.stateColor
        cornerRadius: root.cornerRadius
        enableRipple: root.enableRipple
    }

    Timer {
        id: hoverDelay
        interval: 400
        repeat: false
        onTriggered: {
            tooltip.show(root.tooltipText, root, 0, 0, root.tooltipSide);
        }
    }

    onEntered: {
        if (!tooltipText)
            return;
        hoverDelay.restart();
    }

    onExited: {
        if (!tooltipText)
            return;
        hoverDelay.stop();
        tooltip.hide();
    }

    DankTooltipV2 {
        id: tooltip
    }
}
