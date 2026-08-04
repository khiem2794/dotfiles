import QtQuick
import Quickshell
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Row {
    id: root

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property var model: []
    property int currentIndex: -1
    property string selectionMode: "single"
    property bool multiSelect: selectionMode === "multi"
    property var initialSelection: []
    property var currentSelection: initialSelection
    property bool checkEnabled: true
    property string size: "medium"
    property int buttonHeight: size === "small" ? 32 : 40
    property int minButtonWidth: size === "small" ? 56 : 64
    property int buttonPadding: size === "small" ? Style.spacingM : Style.spacingL
    property int checkIconSize: size === "small" ? Style.iconSizeSmall - 2 : Style.iconSizeSmall
    property int textSize: size === "small" ? Style.fontSizeSmall : Style.fontSizeMedium
    property bool userInteracted: false
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property real maximumWidth: -1
    readonly property real _segmentCap: {
        const count = model?.length ?? 0;
        if (maximumWidth <= 0 || count === 0)
            return -1;
        return (maximumWidth - spacing * (count - 1)) / count - 4;
    }

    signal selectionChanged(int index, bool selected)
    signal animationCompleted

    spacing: Style.spacingXS

    Timer {
        id: animationTimer
        interval: Style.shortDuration
        onTriggered: {
            root.userInteracted = false;
            root.animationCompleted();
        }
    }

    function isSelected(index) {
        if (multiSelect) {
            return repeater.itemAt(index)?.selected || false;
        }
        return index === currentIndex;
    }

    function selectItem(index) {
        userInteracted = true;
        if (multiSelect) {
            const modelValue = model[index];
            let newSelection = [...currentSelection];
            const isCurrentlySelected = newSelection.includes(modelValue);

            if (isCurrentlySelected) {
                newSelection = newSelection.filter(item => item !== modelValue);
            } else {
                newSelection.push(modelValue);
            }

            currentSelection = newSelection;
            selectionChanged(index, !isCurrentlySelected);
            animationTimer.restart();
        } else {
            const oldIndex = currentIndex;
            selectionChanged(index, true);
            if (oldIndex !== index && oldIndex >= 0) {
                selectionChanged(oldIndex, false);
            }
            animationTimer.restart();
        }
    }

    Repeater {
        id: repeater
        model: ScriptModel {
            values: root.model
        }

        delegate: Rectangle {
            id: segment

            property bool selected: multiSelect ? root.currentSelection.includes(modelData) : (index === root.currentIndex)
            property bool hovered: mouseArea.containsMouse
            property bool pressed: mouseArea.pressed
            property bool isFirst: index === 0
            property bool isLast: index === repeater.count - 1
            property bool visualFirst: I18n.isRtl ? isLast : isFirst
            property bool visualLast: I18n.isRtl ? isFirst : isLast
            property bool prevSelected: index > 0 ? root.isSelected(index - 1) : false
            property bool nextSelected: index < repeater.count - 1 ? root.isSelected(index + 1) : false

            readonly property real contentNaturalWidth: (checkIcon.visible ? checkIcon.width + contentRow.spacing : 0) + buttonText.implicitWidth

            width: {
                const natural = Math.max(contentNaturalWidth + root.buttonPadding * 2, root.minButtonWidth);
                const capped = root._segmentCap > 0 ? Math.min(natural, Math.max(root._segmentCap, root.minButtonWidth)) : natural;
                return capped + (selected ? 4 : 0);
            }
            height: root.buttonHeight

            color: selected ? Style.buttonBg : (root.usePopupTransparency ? Style.withAlpha(Style.surfaceVariant, Style.popupTransparency) : Style.surfaceVariant)
            border.color: "transparent"
            border.width: 0

            topLeftRadius: (visualFirst || selected) ? Style.cornerRadius : Math.min(4, Style.cornerRadius)
            bottomLeftRadius: (visualFirst || selected) ? Style.cornerRadius : Math.min(4, Style.cornerRadius)
            topRightRadius: (visualLast || selected) ? Style.cornerRadius : Math.min(4, Style.cornerRadius)
            bottomRightRadius: (visualLast || selected) ? Style.cornerRadius : Math.min(4, Style.cornerRadius)

            Behavior on width {
                enabled: root.userInteracted
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Behavior on topLeftRadius {
                enabled: root.userInteracted
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Behavior on topRightRadius {
                enabled: root.userInteracted
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Behavior on bottomLeftRadius {
                enabled: root.userInteracted
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Behavior on bottomRightRadius {
                enabled: root.userInteracted
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Behavior on color {
                enabled: root.userInteracted
                ColorAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }

            Rectangle {
                id: stateLayer
                anchors.fill: parent
                topLeftRadius: parent.topLeftRadius
                bottomLeftRadius: parent.bottomLeftRadius
                topRightRadius: parent.topRightRadius
                bottomRightRadius: parent.bottomRightRadius
                color: {
                    if (pressed)
                        return selected ? Style.buttonPressed : Style.surfaceTextHover;
                    if (hovered)
                        return selected ? Style.buttonHover : Style.surfaceTextHover;
                    return "transparent";
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Style.shorterDuration
                        easing.type: Style.standardEasing
                    }
                }
            }

            DankRipple {
                id: segmentRipple
                cornerRadius: Style.cornerRadius
                rippleColor: segment.selected ? Style.buttonText : Style.surfaceVariantText
            }

            Item {
                id: contentItem
                anchors.centerIn: parent
                implicitWidth: contentRow.implicitWidth
                implicitHeight: contentRow.implicitHeight

                Row {
                    id: contentRow
                    spacing: Style.spacingS

                    DankIcon {
                        id: checkIcon
                        name: "check"
                        size: root.checkIconSize
                        color: segment.selected ? Style.buttonText : Style.surfaceVariantText
                        visible: root.checkEnabled && segment.selected
                        opacity: segment.selected ? 1 : 0
                        scale: segment.selected ? 1 : 0.6
                        anchors.verticalCenter: parent.verticalCenter

                        Behavior on opacity {
                            enabled: root.userInteracted
                            NumberAnimation {
                                duration: Style.shortDuration
                                easing.type: Style.standardEasing
                            }
                        }

                        Behavior on scale {
                            enabled: root.userInteracted
                            NumberAnimation {
                                duration: Style.shortDuration
                                easing.type: Style.emphasizedEasing
                            }
                        }
                    }

                    StyledText {
                        id: buttonText

                        readonly property real capAvailable: {
                            if (root._segmentCap <= 0)
                                return -1;
                            const cap = Math.max(root._segmentCap, root.minButtonWidth);
                            return Math.max(0, cap - root.buttonPadding * 2 - (checkIcon.visible ? checkIcon.width + contentRow.spacing : 0));
                        }

                        text: typeof modelData === "string" ? modelData : modelData.text || ""
                        font.pixelSize: root.textSize
                        font.weight: segment.selected ? Font.Medium : Font.Normal
                        color: segment.selected ? Style.buttonText : Style.surfaceVariantText
                        anchors.verticalCenter: parent.verticalCenter
                        width: capAvailable < 0 ? implicitWidth : Math.min(implicitWidth, capAvailable)
                        maximumLineCount: 1
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => segmentRipple.trigger(mouse.x, mouse.y)
                onClicked: root.selectItem(index)
            }
        }
    }
}
