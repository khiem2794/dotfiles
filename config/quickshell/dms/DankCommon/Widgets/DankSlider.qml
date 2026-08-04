import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Item {
    id: slider

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property int value: 50
    property int minimum: 0
    property int maximum: 100
    property int step: 1
    property string leftIcon: ""
    property string rightIcon: ""
    property string unit: "%"
    property bool showValue: true
    property bool isDragging: false
    property bool wheelEnabled: true
    property bool centerMinimum: false
    property real valueOverride: -1
    property bool alwaysShowValue: false
    readonly property bool containsMouse: sliderMouseArea.containsMouse

    property color thumbOutlineColor: Style.surfaceContainer
    property color trackColor: enabled ? Style.outline : Style.outline
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property real trackOpacity: usePopupTransparency ? Style.popupTransparency : 1.0

    signal sliderValueChanged(int newValue)
    signal sliderDragFinished(int finalValue)

    height: 48

    function updateValueFromPosition(x) {
        let ratio = Math.max(0, Math.min(1, (x - sliderHandle.width / 2) / (sliderTrack.width - sliderHandle.width)));
        if (centerMinimum)
            ratio = Math.max(0, (ratio - 0.5) * 2);
        let rawValue = minimum + ratio * (maximum - minimum);
        let newValue = step > 1 ? Math.round(rawValue / step) * step : Math.round(rawValue);
        newValue = Math.max(minimum, Math.min(maximum, newValue));
        if (newValue !== value) {
            value = newValue;
            sliderValueChanged(newValue);
        }
    }

    Row {
        anchors.centerIn: parent
        width: parent.width
        spacing: Style.spacingM

        DankIcon {
            name: slider.leftIcon
            size: Style.iconSize
            color: slider.enabled ? Style.surfaceText : Style.onSurface_38
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.leftIcon.length > 0
        }

        StyledRect {
            id: sliderTrack

            property int leftIconWidth: slider.leftIcon.length > 0 ? Style.iconSize : 0
            property int rightIconWidth: slider.rightIcon.length > 0 ? Style.iconSize : 0

            width: parent.width - (leftIconWidth + rightIconWidth + (slider.leftIcon.length > 0 ? Style.spacingM : 0) + (slider.rightIcon.length > 0 ? Style.spacingM : 0))
            height: 12
            radius: Style.cornerRadius
            color: Style.withAlpha(slider.trackColor, slider.trackOpacity)
            anchors.verticalCenter: parent.verticalCenter
            clip: false

            StyledRect {
                id: sliderFill
                height: parent.height
                radius: Style.cornerRadius
                topRightRadius: 0
                bottomRightRadius: 0
                width: {
                    const range = slider.maximum - slider.minimum;
                    const rawRatio = range === 0 ? 0 : (slider.value - slider.minimum) / range;
                    const ratio = slider.centerMinimum ? (0.5 + rawRatio * 0.5) : rawRatio;
                    const travel = sliderTrack.width - sliderHandle.width;
                    const handleLeft = travel * ratio;
                    const endPoint = handleLeft - 3;
                    return Math.max(0, Math.min(sliderTrack.width, endPoint));
                }
                color: slider.enabled ? Style.primary : Style.withAlpha(Style.onSurface, 0.12)
            }

            StyledRect {
                id: sliderHandle

                property bool active: sliderMouseArea.containsMouse || sliderMouseArea.pressed || slider.isDragging

                width: 4
                height: 20
                radius: Style.cornerRadius
                x: {
                    const range = slider.maximum - slider.minimum;
                    const rawRatio = range === 0 ? 0 : (slider.value - slider.minimum) / range;
                    const ratio = slider.centerMinimum ? (0.5 + rawRatio * 0.5) : rawRatio;
                    const travel = sliderTrack.width - width;
                    return Math.max(0, Math.min(travel, travel * ratio));
                }
                anchors.verticalCenter: parent.verticalCenter
                color: slider.enabled ? Style.primary : Style.withAlpha(Style.onSurface, 0.12)
                border.width: 0
                border.color: slider.thumbOutlineColor

                StyledRect {
                    anchors.fill: parent
                    radius: Style.cornerRadius
                    color: Style.onPrimary
                    opacity: slider.enabled ? (sliderMouseArea.pressed ? 0.16 : (sliderMouseArea.containsMouse ? 0.08 : 0)) : 0
                    visible: opacity > 0
                }

                StyledRect {
                    anchors.centerIn: parent
                    width: parent.width + 20
                    height: parent.height + 20
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Style.primary
                    opacity: slider.enabled && slider.focus ? 0.3 : 0
                    visible: opacity > 0
                }

                Rectangle {
                    id: ripple
                    anchors.centerIn: parent
                    width: 0
                    height: 0
                    radius: width / 2
                    color: Style.onPrimary
                    opacity: 0

                    function start() {
                        opacity = 0.16;
                        width = 0;
                        height = 0;
                        rippleAnimation.start();
                    }

                    SequentialAnimation {
                        id: rippleAnimation
                        NumberAnimation {
                            target: ripple
                            properties: "width,height"
                            to: 28
                            duration: 180
                        }
                        NumberAnimation {
                            target: ripple
                            property: "opacity"
                            to: 0
                            duration: 150
                        }
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onPressedChanged: {
                        if (pressed && slider.enabled) {
                            ripple.start();
                        }
                    }
                }

                scale: active ? 1.05 : 1.0

                Behavior on scale {
                    NumberAnimation {
                        duration: Style.shortDuration
                        easing.type: Style.standardEasing
                    }
                }
            }

            Item {
                id: sliderContainer

                anchors.fill: parent

                MouseArea {
                    id: sliderMouseArea

                    property bool isDragging: false

                    anchors.fill: parent
                    anchors.topMargin: -10
                    anchors.bottomMargin: -10
                    hoverEnabled: true
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: slider.enabled
                    preventStealing: true
                    acceptedButtons: Qt.LeftButton
                    onWheel: wheelEvent => {
                        if (!slider.wheelEnabled) {
                            wheelEvent.accepted = false;
                            return;
                        }
                        let wheelStep = slider.step > 1 ? slider.step : Math.max(1, (maximum - minimum) / 100);
                        let newValue = wheelEvent.angleDelta.y > 0 ? Math.min(maximum, value + wheelStep) : Math.max(minimum, value - wheelStep);
                        if (slider.step > 1)
                            newValue = Math.round(newValue / slider.step) * slider.step;
                        newValue = Math.round(newValue);
                        if (newValue !== value) {
                            value = newValue;
                            sliderValueChanged(newValue);
                        }
                        wheelEvent.accepted = true;
                    }
                    onPressed: mouse => {
                        if (slider.enabled) {
                            slider.isDragging = true;
                            sliderMouseArea.isDragging = true;
                            updateValueFromPosition(mouse.x);
                        }
                    }
                    onReleased: {
                        if (slider.enabled) {
                            slider.isDragging = false;
                            sliderMouseArea.isDragging = false;
                            slider.sliderDragFinished(slider.value);
                        }
                    }
                    onPositionChanged: mouse => {
                        if (pressed && slider.isDragging && slider.enabled) {
                            updateValueFromPosition(mouse.x);
                        }
                    }
                    onClicked: mouse => {
                        if (slider.enabled && !slider.isDragging) {
                            updateValueFromPosition(mouse.x);
                        }
                    }
                }
            }

            StyledRect {
                id: valueTooltip

                width: tooltipText.reservedWidth + Style.spacingS * 2
                height: tooltipText.contentHeight + Style.spacingXS * 2
                radius: Style.cornerRadius
                color: Style.surfaceContainer
                border.color: Style.outline
                border.width: 1
                anchors.bottom: parent.top
                anchors.bottomMargin: Style.spacingM
                x: Math.max(0, Math.min(parent.width - width, sliderHandle.x + sliderHandle.width / 2 - width / 2))
                visible: slider.alwaysShowValue ? slider.showValue : ((sliderMouseArea.containsMouse && slider.showValue) || (slider.isDragging && slider.showValue))
                opacity: visible ? 1 : 0

                NumericText {
                    id: tooltipText

                    text: (slider.valueOverride >= 0 ? Math.round(slider.valueOverride) : slider.value) + slider.unit
                    reserveText: {
                        let widest = "";
                        const samples = [slider.minimum, slider.maximum];
                        if (slider.valueOverride >= 0)
                            samples.push(slider.valueOverride);
                        for (let i = 0; i < samples.length; i++) {
                            const candidate = Math.round(samples[i]) + slider.unit;
                            if (candidate.length > widest.length)
                                widest = candidate;
                        }
                        return widest;
                    }
                    font.pixelSize: Style.fontSizeSmall
                    color: Style.surfaceText
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                    font.hintingPreference: Font.PreferFullHinting
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Style.shortDuration
                        easing.type: Style.standardEasing
                    }
                }
            }
        }

        DankIcon {
            name: slider.rightIcon
            size: Style.iconSize
            color: slider.enabled ? Style.surfaceText : Style.onSurface_38
            anchors.verticalCenter: parent.verticalCenter
            visible: slider.rightIcon.length > 0
        }
    }
}
