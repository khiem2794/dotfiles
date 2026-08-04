import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: root

    property string iconName: ""
    property int iconSize: Style.iconSize - 4
    property color iconColor: Style.surfaceText
    property color backgroundColor: "transparent"
    property bool circular: true
    property int buttonSize: 32
    property var tooltipText: null
    property string tooltipSide: "bottom"
    readonly property alias pressed: stateLayer.pressed

    signal clicked
    signal entered
    signal exited

    width: buttonSize
    height: buttonSize
    radius: Style.cornerRadius
    color: backgroundColor

    DankIcon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.iconSize
        color: root.iconColor
    }

    StateLayer {
        id: stateLayer
        disabled: !root.enabled
        stateColor: Style.primary
        cornerRadius: root.radius
        onClicked: root.clicked()
        onEntered: root.entered()
        onExited: root.exited()
        tooltipText: root.tooltipText
        tooltipSide: root.tooltipSide
    }
}
