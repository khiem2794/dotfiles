import QtQuick
import QtQuick.Layouts
import qs.DankCommon.Common
import qs.DankCommon.Widgets

ColumnLayout {
    id: root

    required property string title
    property string description: ""
    property bool expanded: false
    property bool showBackground: false
    property alias headerColor: headerRect.color

    signal toggleRequested

    spacing: Style.spacingS
    Layout.fillWidth: true

    Rectangle {
        id: headerRect
        Layout.fillWidth: true
        Layout.preferredHeight: Math.max(titleRow.implicitHeight + Style.spacingM * 2, 48)
        radius: Style.cornerRadius
        color: "transparent"

        RowLayout {
            id: titleRow
            anchors.fill: parent
            anchors.leftMargin: Style.spacingM
            anchors.rightMargin: Style.spacingM
            spacing: Style.spacingM

            StyledText {
                text: root.title
                font.pixelSize: Style.fontSizeLarge
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            DankIcon {
                name: "expand_more"
                size: Style.iconSizeSmall
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                    NumberAnimation {
                        easing.type: Easing.BezierSpline
                        duration: Style.shortDuration
                        easing.bezierCurve: Style.expressiveCurves.standard
                    }
                }
            }
        }

        StateLayer {
            anchors.fill: parent
            onClicked: {
                root.toggleRequested();
                root.expanded = !root.expanded;
            }
        }
    }

    default property alias content: contentColumn.data

    Item {
        id: contentWrapper
        Layout.fillWidth: true
        Layout.preferredHeight: root.expanded ? (contentColumn.implicitHeight + Style.spacingS * 2) : 0
        clip: true

        Behavior on Layout.preferredHeight {
            enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
            DankAnim {
                duration: Style.expressiveDurations.expressiveDefaultSpatial
                easing.bezierCurve: Style.expressiveCurves.standard
            }
        }

        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            radius: Style.cornerRadius
            color: Style.surfaceContainer
            opacity: root.showBackground && root.expanded ? 1.0 : 0.0
            visible: root.showBackground

            Behavior on opacity {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                NumberAnimation {
                    easing.type: Easing.BezierSpline
                    duration: Style.shortDuration
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            y: Style.spacingS
            anchors.leftMargin: Style.spacingM
            anchors.rightMargin: Style.spacingM
            anchors.bottomMargin: Style.spacingS
            spacing: Style.spacingS
            opacity: root.expanded ? 1.0 : 0.0

            Behavior on opacity {
                enabled: Style.currentAnimationSpeed !== Style.AnimationSpeed.None
                NumberAnimation {
                    easing.type: Easing.BezierSpline
                    duration: Style.shortDuration
                    easing.bezierCurve: Style.expressiveCurves.standard
                }
            }

            StyledText {
                id: descriptionText
                Layout.fillWidth: true
                Layout.topMargin: root.description !== "" ? Style.spacingXS : 0
                Layout.bottomMargin: root.description !== "" ? Style.spacingS : 0
                visible: root.description !== ""
                text: root.description
                color: Style.surfaceTextSecondary
                font.pixelSize: Style.fontSizeSmall
                wrapMode: Text.Wrap
            }
        }
    }
}
