import QtQuick
import QtQuick.Shapes
import Quickshell.Services.UPower
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

BasePill {
    id: battery
    readonly property var log: Log.scoped("Battery")

    property bool batteryPopupVisible: false
    property var popoutTarget: null
    property var widgetData: null
    readonly property bool showPercentOnlyOnBattery: widgetData?.showBatteryPercentOnlyOnBattery !== undefined ? widgetData.showBatteryPercentOnlyOnBattery : SettingsData.showBatteryPercentOnlyOnBattery
    readonly property bool showPercent: {
        const base = widgetData?.showBatteryPercent !== undefined ? widgetData.showBatteryPercent : SettingsData.showBatteryPercent;
        return base && !(showPercentOnlyOnBattery && BatteryService.isPluggedIn);
    }
    readonly property bool showTime: widgetData?.showBatteryTime !== undefined ? widgetData.showBatteryTime : SettingsData.showBatteryTime
    readonly property bool showTimeOnlyOnBattery: widgetData?.showBatteryTimeOnlyOnBattery !== undefined ? widgetData.showBatteryTimeOnlyOnBattery : SettingsData.showBatteryTimeOnlyOnBattery
    readonly property bool pillStyle: widgetData?.batteryPillStyle !== undefined ? widgetData.batteryPillStyle : SettingsData.batteryPillStyle
    readonly property bool pillPercentSign: widgetData?.batteryPillPercentSign !== undefined ? widgetData.batteryPillPercentSign : SettingsData.batteryPillPercentSign

    readonly property string batteryTimeText: {
        if (showTimeOnlyOnBattery && BatteryService.isPluggedIn) {
            return "";
        }
        const time = BatteryService.formatTimeRemaining();
        return time !== "Unknown" ? time : "";
    }

    readonly property string verticalBatteryTimeText: {
        if (!batteryTimeText)
            return "";

        // Parse batteryTimeText, e.g., "2h 41m" or "41m"
        let hours = 0;
        let minutes = 0;

        const hourMatch = batteryTimeText.match(/(\d+)h/);
        const minMatch = batteryTimeText.match(/(\d+)m/);

        if (hourMatch) {
            hours = parseInt(hourMatch[1], 10);
        }
        if (minMatch) {
            minutes = parseInt(minMatch[1], 10);
        }

        const hoursStr = hours < 10 ? "0" + hours : hours.toString();
        const minutesStr = minutes < 10 ? "0" + minutes : minutes.toString();

        return `${hoursStr}\n${minutesStr}`;
    }

    readonly property string horizontalDisplayText: {
        if (showPercent && showTime && batteryTimeText) {
            return `${BatteryService.batteryLevel}% (${batteryTimeText})`;
        }
        if (showPercent) {
            return `${BatteryService.batteryLevel}%`;
        }
        if (showTime && batteryTimeText) {
            return batteryTimeText;
        }
        return "";
    }

    // Percent always stays inside the pill; only the time shows beside it.
    readonly property string horizontalSideText: {
        if (!pillStyle) {
            return horizontalDisplayText;
        }
        return (showTime && batteryTimeText) ? batteryTimeText : "";
    }

    readonly property string verticalDisplayText: {
        if (showPercent && showTime && batteryTimeText) {
            return `${BatteryService.batteryLevel}\n${verticalBatteryTimeText}`;
        }
        if (showPercent) {
            return BatteryService.batteryLevel.toString();
        }
        if (showTime && batteryTimeText) {
            return verticalBatteryTimeText;
        }
        return "";
    }

    property real touchpadAccumulator: 0

    readonly property int barPosition: {
        switch (axis?.edge) {
        case "top":
            return 0;
        case "bottom":
            return 1;
        case "left":
            return 2;
        case "right":
            return 3;
        default:
            return 0;
        }
    }

    signal toggleBatteryPopup

    visible: true

    // AOSP's battery bolt glyph (config_batterymeterBoltPath), solid-filled and
    // cropped tight to its own ink so it reads bold at normal icon size instead
    // of needing to be inflated past the bar's calibrated icon height.
    component OfficialBolt: Shape {
        id: officialBolt
        property color fillColor: Theme.surfaceText
        property real size: 16
        implicitWidth: Math.round(officialBolt.size * (6 / 13))
        implicitHeight: Math.round(officialBolt.size)
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: officialBolt.fillColor
            strokeColor: "transparent"

            startX: officialBolt.width * (1 / 3)
            startY: officialBolt.height
            PathLine {
                x: officialBolt.width * (1 / 3)
                y: officialBolt.height * (7.5 / 13)
            }
            PathLine {
                x: 0
                y: officialBolt.height * (7.5 / 13)
            }
            PathLine {
                x: officialBolt.width * (2 / 3)
                y: 0
            }
            PathLine {
                x: officialBolt.width * (2 / 3)
                y: officialBolt.height * (5.5 / 13)
            }
            PathLine {
                x: officialBolt.width
                y: officialBolt.height * (5.5 / 13)
            }
            PathLine {
                x: officialBolt.width * (1 / 3)
                y: officialBolt.height
            }
        }
    }

    // Material 3 style horizontal/vertical battery pill with the level inside
    component BatteryPill: Item {
        id: pill

        property real thickness: 18
        property bool vertical: false
        property bool showNumber: true
        property bool showPercentSign: false

        readonly property int signSize: Math.max(1, Math.round(pill.glyphSize * 0.72))
        readonly property real bodyLength: Math.round(pill.thickness * 1.95)
        readonly property real level: Math.max(0, Math.min(100, BatteryService.batteryLevel))
        readonly property bool charging: BatteryService.isCharging
        readonly property bool lowState: BatteryService.isLowBattery && !BatteryService.isCharging
        readonly property color fillColor: {
            if (!BatteryService.batteryAvailable)
                return Theme.surfaceVariant;
            if (pill.lowState)
                return Theme.error;
            return Theme.primary;
        }
        readonly property color onFillColor: {
            const c = pill.fillColor;
            const lum = 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
            return lum > 0.5 ? Qt.rgba(0, 0, 0, 0.9) : Qt.rgba(1, 1, 1, 0.95);
        }
        readonly property string numberText: Math.round(pill.level).toString()
        readonly property int glyphSize: Math.round(pill.thickness * 0.58)
        readonly property int boltSize: Math.round(pill.thickness * 0.72)
        readonly property real nubBreadth: Math.round(pill.thickness * 0.16)
        readonly property real nubSpan: Math.round(pill.thickness * 0.46)

        implicitWidth: pill.vertical ? pill.thickness : Math.max(pill.bodyLength, (!pill.vertical && pill.showNumber) ? numRowTrack.width + pill.thickness * 0.7 : 0) + pill.nubBreadth
        implicitHeight: pill.vertical ? pill.bodyLength + pill.nubBreadth : pill.thickness

        Rectangle {
            id: body
            x: 0
            y: pill.vertical ? pill.nubBreadth : 0
            width: pill.vertical ? parent.width : parent.width - pill.nubBreadth
            height: pill.vertical ? parent.height - pill.nubBreadth : parent.height
            radius: Math.round(Math.min(width, height) * 0.34)
            color: Theme.withAlpha(Theme.surfaceVariant, 0.9)

            Rectangle {
                id: fill
                radius: body.radius
                color: pill.fillColor
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: pill.vertical ? parent.width : Math.round(parent.width * pill.level / 100)
                height: pill.vertical ? Math.round(parent.height * pill.level / 100) : parent.height

                Behavior on width {
                    enabled: !pill.vertical
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.standardEasing
                    }
                }

                Behavior on height {
                    enabled: pill.vertical
                    NumberAnimation {
                        duration: Theme.mediumDuration
                        easing.type: Theme.standardEasing
                    }
                }
            }

            // Tinted for the empty track. Horizontal always shows the number;
            // vertical swaps in a centered bolt while charging.
            Item {
                id: glyphTrack
                anchors.fill: parent
                visible: BatteryService.batteryAvailable && ((pill.charging && pill.vertical) || (!pill.vertical && pill.showNumber))

                Row {
                    id: numRowTrack
                    visible: !pill.vertical && pill.showNumber
                    anchors.centerIn: parent
                    spacing: 1

                    StyledText {
                        id: numTrack
                        text: pill.numberText
                        color: Theme.surfaceText
                        font.pixelSize: pill.glyphSize
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "%"
                        visible: pill.showPercentSign
                        color: Theme.surfaceText
                        font.pixelSize: pill.signSize
                        font.weight: Font.Bold
                        anchors.baseline: numTrack.baseline
                    }
                }

                DankIcon {
                    name: "bolt"
                    size: pill.boltSize
                    color: Theme.surfaceText
                    visible: pill.charging && pill.vertical
                    anchors.centerIn: parent
                }
            }

            // Same glyphs tinted for the fill, clipped so they stay legible over it.
            Item {
                visible: glyphTrack.visible
                x: fill.x
                y: fill.y
                width: fill.width
                height: fill.height
                clip: true

                Item {
                    x: -fill.x
                    y: -fill.y
                    width: body.width
                    height: body.height

                    Row {
                        visible: !pill.vertical && pill.showNumber
                        anchors.centerIn: parent
                        spacing: 1

                        StyledText {
                            id: numFill
                            text: pill.numberText
                            color: pill.onFillColor
                            font.pixelSize: pill.glyphSize
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "%"
                            visible: pill.showPercentSign
                            color: pill.onFillColor
                            font.pixelSize: pill.signSize
                            font.weight: Font.Bold
                            anchors.baseline: numFill.baseline
                        }
                    }

                    DankIcon {
                        name: "bolt"
                        size: pill.boltSize
                        color: pill.onFillColor
                        visible: pill.charging && pill.vertical
                        anchors.centerIn: parent
                    }
                }
            }
        }

        // Battery terminal nub, colored to match the outline/track so it
        // reads as part of the same frame rather than a fill segment.
        Rectangle {
            visible: !pill.vertical
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: pill.nubBreadth
            height: pill.nubSpan
            radius: Math.round(pill.nubBreadth * 0.35)
            color: Theme.withAlpha(Theme.surfaceVariant, 0.9)
        }

        Rectangle {
            visible: pill.vertical
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: pill.nubSpan
            height: pill.nubBreadth
            radius: Math.round(pill.nubBreadth * 0.35)
            color: Theme.withAlpha(Theme.surfaceVariant, 0.9)
        }
    }

    content: Component {
        Item {
            implicitWidth: battery.isVerticalOrientation ? (battery.widgetThickness - battery.horizontalPadding * 2) : batteryContent.implicitWidth
            implicitHeight: battery.isVerticalOrientation ? batteryColumn.implicitHeight : (battery.widgetThickness - battery.horizontalPadding * 2)

            Column {
                id: batteryColumn
                visible: battery.isVerticalOrientation
                anchors.centerIn: parent
                spacing: 1

                DankIcon {
                    name: BatteryService.getBatteryIcon()
                    visible: !battery.pillStyle
                    size: Theme.barIconSize(battery.barThickness, undefined, battery.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                    color: {
                        if (!BatteryService.batteryAvailable) {
                            return Theme.widgetIconColor;
                        }

                        if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                            return Theme.error;
                        }

                        if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                            return Theme.primary;
                        }

                        return Theme.widgetIconColor;
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                BatteryPill {
                    visible: battery.pillStyle
                    vertical: true
                    showNumber: false
                    thickness: Theme.barIconSize(battery.barThickness, undefined, battery.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                StyledText {
                    text: battery.verticalDisplayText
                    font.pixelSize: Theme.barTextSize(battery.barThickness, battery.barConfig?.fontScale, battery.barConfig?.maximizeWidgetText)
                    color: Theme.widgetTextColor
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: BatteryService.batteryAvailable && battery.verticalDisplayText !== ""
                }
            }

            Row {
                id: batteryContent
                visible: !battery.isVerticalOrientation
                anchors.centerIn: parent
                spacing: (barConfig?.noBackground ?? false) ? 1 : 2

                DankIcon {
                    name: BatteryService.getBatteryIcon()
                    visible: !battery.pillStyle
                    size: Theme.barIconSize(battery.barThickness, -4, battery.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                    color: {
                        if (!BatteryService.batteryAvailable) {
                            return Theme.widgetIconColor;
                        }

                        if (BatteryService.isLowBattery && !BatteryService.isCharging) {
                            return Theme.error;
                        }

                        if (BatteryService.isCharging || BatteryService.isPluggedIn) {
                            return Theme.primary;
                        }

                        return Theme.widgetIconColor;
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                BatteryPill {
                    visible: battery.pillStyle
                    vertical: false
                    showNumber: battery.showPercent
                    showPercentSign: battery.pillPercentSign
                    thickness: Theme.barIconSize(battery.barThickness, -4, battery.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale)
                    anchors.verticalCenter: parent.verticalCenter
                }

                OfficialBolt {
                    visible: battery.pillStyle && BatteryService.batteryAvailable && BatteryService.isCharging
                    fillColor: Theme.primary
                    size: Math.round(Theme.barIconSize(battery.barThickness, -4, battery.barConfig?.maximizeWidgetIcons, root.barConfig?.iconScale) * 0.85)
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: battery.horizontalSideText
                    font.pixelSize: Theme.barTextSize(battery.barThickness, battery.barConfig?.fontScale, battery.barConfig?.maximizeWidgetText)
                    color: Theme.widgetTextColor
                    anchors.verticalCenter: parent.verticalCenter
                    visible: BatteryService.batteryAvailable && battery.horizontalSideText !== ""
                }
            }
        }
    }

    MouseArea {
        x: -battery.leftMargin
        y: -battery.topMargin
        width: battery.width + battery.leftMargin + battery.rightMargin
        height: battery.height + battery.topMargin + battery.bottomMargin
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: mouse => {
            battery.triggerRipple(this, mouse.x, mouse.y);
            if (mouse.button === Qt.LeftButton) {
                toggleBatteryPopup();
            } else if (mouse.button === Qt.RightButton) {
                if (PowerProfileWatcher.available) {
                    PowerProfileWatcher.cycleProfile();
                } else {
                    ToastService.showError(I18n.tr("power-profiles-daemon not available"));
                }
            }
        }
        onWheel: wheel => {
            var delta = wheel.angleDelta.y;
            if (delta === 0)
                return;

            // Check if this is a touchpad
            if (delta !== 120 && delta !== -120) {
                touchpadAccumulator += delta;
                if (Math.abs(touchpadAccumulator) < 500)
                    return;
                delta = touchpadAccumulator;
                touchpadAccumulator = 0;
            }

            if (!DisplayService.brightnessAvailable) {
                return;
            }

            const step = 5;
            const change = delta > 0 ? step : -step;
            const newBrightness = Math.max(0, Math.min(100, DisplayService.brightnessLevel + change));
            DisplayService.setBrightness(newBrightness, "", false);
        }
    }
}
