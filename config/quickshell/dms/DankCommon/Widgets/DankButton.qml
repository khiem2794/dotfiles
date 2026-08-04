import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property int iconSize: Style.iconSizeSmall
    property bool hovered: mouseArea.containsMouse
    property bool pressed: mouseArea.pressed
    property color backgroundColor: Style.buttonBg
    property color textColor: Style.buttonText
    property int buttonHeight: 40
    property int horizontalPadding: Style.spacingL
    property bool enableScaleAnimation: false
    property bool enableRipple: Style.enableRippleEffects

    signal clicked

    width: Math.max(contentRow.implicitWidth + horizontalPadding * 2, 64)
    height: buttonHeight
    radius: Style.cornerRadius
    color: backgroundColor
    opacity: enabled ? 1 : 0.4
    scale: (enableScaleAnimation && pressed) ? 0.98 : 1.0

    Behavior on scale {
        enabled: enableScaleAnimation && Style.currentAnimationSpeed !== Style.AnimationSpeed.None
        NumberAnimation {
            easing.type: Easing.BezierSpline
            duration: 100
            easing.bezierCurve: Style.expressiveCurves.standard
        }
    }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        radius: parent.radius
        color: {
            if (pressed)
                return Style.withAlpha(root.textColor, 0.20);
            if (hovered)
                return Style.withAlpha(root.textColor, 0.12);
            return Style.withAlpha(root.textColor, 0);
        }

        Behavior on color {
            ColorAnimation {
                duration: Style.shorterDuration
                easing.type: Style.standardEasing
            }
        }
    }

    DankRipple {
        id: rippleLayer
        rippleColor: root.textColor
        cornerRadius: root.radius
        enableRipple: root.enableRipple
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: Style.spacingS

        DankIcon {
            name: root.iconName
            size: root.iconSize
            color: root.textColor
            visible: root.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: root.text
            font.pixelSize: Style.fontSizeMedium
            font.weight: Font.Medium
            color: root.textColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        onPressed: mouse => {
            if (root.enableRipple)
                rippleLayer.trigger(mouse.x, mouse.y);
        }
        onClicked: root.clicked()
    }
}
