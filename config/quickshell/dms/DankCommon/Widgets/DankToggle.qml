import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Item {
    id: toggle

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    // API
    property bool checked: false
    property bool toggling: false
    property string text: ""
    property string description: ""
    property color descriptionColor: Style.surfaceVariantText
    property bool hideText: false

    signal clicked
    signal toggled(bool checked)
    signal toggleCompleted(bool checked)

    readonly property bool showText: text && !hideText

    readonly property int trackWidth: 52
    readonly property int trackHeight: 30
    readonly property int insetCircle: 24

    width: showText ? parent.width : trackWidth
    height: showText ? Math.max(trackHeight, textColumn.implicitHeight + Style.spacingM * 2) : trackHeight

    function handleClick() {
        if (!enabled)
            return;
        clicked();
        toggled(!checked);
    }

    StyledRect {
        id: background
        anchors.fill: parent
        radius: showText ? Style.cornerRadius : 0
        color: "transparent"
        visible: showText

        StateLayer {
            visible: showText
            disabled: !toggle.enabled
            stateColor: Style.primary
            cornerRadius: parent.radius
            onClicked: toggle.handleClick()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.right: toggleTrack.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.spacingM
        anchors.rightMargin: Style.spacingM
        spacing: Style.spacingXS
        visible: showText

        Column {
            id: textColumn
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.spacingXS

            StyledText {
                text: toggle.text
                font.pixelSize: Appearance.fontSize.normal
                font.weight: Font.Medium
                opacity: toggle.enabled ? 1 : 0.4
                width: parent.width
                horizontalAlignment: Text.AlignLeft
            }

            StyledText {
                text: toggle.description
                font.pixelSize: Appearance.fontSize.small
                color: toggle.descriptionColor
                wrapMode: Text.WordWrap
                width: parent.width
                visible: toggle.description.length > 0
                horizontalAlignment: Text.AlignLeft
            }
        }
    }

    StyledRect {
        id: toggleTrack

        width: showText ? trackWidth : Math.max(parent.width, trackWidth)
        height: showText ? trackHeight : Math.max(parent.height, trackHeight)
        anchors.right: parent.right
        anchors.rightMargin: showText ? Style.spacingM : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.cornerRadius

        // Distinguish disabled checked vs unchecked so unchecked disabled switches don't look enabled
        color: !toggle.enabled ? (toggle.checked ? Qt.alpha(Style.surfaceText, 0.12) : Style.withAlpha(Qt.alpha(Style.surfaceText, 0.12), 0)) : (toggle.checked ? Style.primary : Style.surfaceVariantAlpha)
        opacity: toggle.toggling ? 0.6 : 1

        // M3 disabled unchecked border: on surface 12% opacity
        border.color: toggle.checked ? Style.withAlpha(Style.outline, 0) : (!toggle.enabled ? Qt.alpha(Style.surfaceText, 0.12) : Style.outline)

        readonly property int pad: Math.round((height - thumb.width) / 2)
        readonly property int edgeLeft: pad
        readonly property int edgeRight: width - thumb.width - pad

        StyledRect {
            id: thumb

            width: toggle.checked ? insetCircle : insetCircle - 4
            height: toggle.checked ? insetCircle : insetCircle - 4
            radius: Style.cornerRadius
            anchors.verticalCenter: parent.verticalCenter

            // M3 disabled thumb:
            // checked = solid surface | unchecked = outlined off-state thumb
            color: !toggle.enabled ? (toggle.checked ? Style.surface : Style.withAlpha(Style.surface, 0)) : (toggle.checked ? Style.surface : Style.outline)
            border.color: !toggle.enabled ? (toggle.checked ? Style.withAlpha(Qt.alpha(Style.surfaceText, 0.38), 0) : Qt.alpha(Style.surfaceText, 0.38)) : Style.outline
            border.width: (toggle.checked && toggle.enabled) ? 1 : 2

            x: toggle.checked ? toggleTrack.edgeRight : toggleTrack.edgeLeft

            Behavior on x {
                SequentialAnimation {
                    NumberAnimation {
                        duration: Appearance.anim.durations.normal
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.anim.curves.emphasizedDecel
                    }
                    ScriptAction {
                        script: {
                            toggle.toggleCompleted(toggle.checked);
                        }
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }

            Behavior on border.width {
                NumberAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.emphasized
                }
            }

            DankIcon {
                id: checkIcon
                anchors.centerIn: parent
                name: "check"
                size: 20
                // M3 disabled icon: on surface 38%
                color: toggle.enabled ? Style.surfaceText : Qt.alpha(Style.surfaceText, 0.38)
                filled: true
                opacity: (toggle.checked && toggle.enabled) ? 1 : 0
                scale: (toggle.checked && toggle.enabled) ? 1 : 0.6

                Behavior on opacity {
                    NumberAnimation {
                        duration: Anims.durShort
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Anims.emphasized
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Anims.durShort
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Anims.emphasized
                    }
                }
            }
        }

        StateLayer {
            disabled: !toggle.enabled
            stateColor: Style.primary
            cornerRadius: parent.radius
            onClicked: toggle.handleClick()
        }
    }
}
