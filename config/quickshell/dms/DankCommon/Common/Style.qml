pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    enum AnimationSpeed {
        None,
        Short,
        Medium,
        Long,
        Custom
    }

    enum TextRenderType {
        Qt,
        Native,
        Curve
    }

    enum TextRenderQuality {
        Default,
        Low,
        Normal,
        High,
        VeryHigh
    }

    property var theme: null
    property var settings: null

    readonly property bool isLightMode: theme?.isLightMode ?? false

    readonly property color primary: theme?.primary ?? "#D0BCFF"
    readonly property color primaryText: theme?.primaryText ?? "#381E72"
    readonly property color primaryContainer: theme?.primaryContainer ?? "#4F378B"
    readonly property color secondary: theme?.secondary ?? "#CCC2DC"
    readonly property color surface: theme?.surface ?? "#141218"
    readonly property color surfaceText: theme?.surfaceText ?? "#e6e0e9"
    readonly property color surfaceVariant: theme?.surfaceVariant ?? "#49454e"
    readonly property color surfaceVariantText: theme?.surfaceVariantText ?? "#cac4cf"
    readonly property color surfaceTint: theme?.surfaceTint ?? "#D0BCFF"
    readonly property color background: theme?.background ?? "#141218"
    readonly property color outline: theme?.outline ?? "#948f99"
    readonly property color surfaceContainer: theme?.surfaceContainer ?? "#211f24"
    readonly property color surfaceContainerHigh: theme?.surfaceContainerHigh ?? "#2b292f"
    readonly property color error: theme?.error ?? "#F2B8B5"
    readonly property color warning: theme?.warning ?? "#FF9800"

    readonly property color onSurface: theme?.onSurface ?? surfaceText
    readonly property color onPrimary: theme?.onPrimary ?? primaryText
    readonly property color onSurface_12: theme?.onSurface_12 ?? withAlpha(onSurface, 0.12)
    readonly property color onSurface_38: theme?.onSurface_38 ?? withAlpha(onSurface, 0.38)

    readonly property color primaryHover: theme?.primaryHover ?? withAlpha(primary, 0.12)
    readonly property color primaryHoverLight: theme?.primaryHoverLight ?? withAlpha(primary, 0.08)
    readonly property color primaryPressed: theme?.primaryPressed ?? withAlpha(primary, 0.16)
    readonly property color primarySelected: theme?.primarySelected ?? withAlpha(primary, 0.3)

    readonly property color surfaceHover: theme?.surfaceHover ?? withAlpha(surfaceVariant, 0.08)
    readonly property color surfacePressed: theme?.surfacePressed ?? withAlpha(surfaceVariant, 0.12)
    readonly property color surfaceLight: theme?.surfaceLight ?? withAlpha(surfaceVariant, 0.1)
    readonly property color surfaceVariantAlpha: theme?.surfaceVariantAlpha ?? withAlpha(surfaceVariant, 0.2)

    readonly property color surfaceTextHover: theme?.surfaceTextHover ?? withAlpha(surfaceText, 0.08)
    readonly property color surfaceTextSecondary: theme?.surfaceTextSecondary ?? withAlpha(surfaceText, 0.6)
    readonly property color surfaceTextMedium: theme?.surfaceTextMedium ?? withAlpha(surfaceText, 0.7)

    readonly property color outlineButton: theme?.outlineButton ?? withAlpha(outline, 0.5)
    readonly property color outlineMedium: theme?.outlineMedium ?? withAlpha(outline, 0.12)
    readonly property color outlineStrong: theme?.outlineStrong ?? withAlpha(outline, 0.18)
    readonly property color outlineHeavy: theme?.outlineHeavy ?? withAlpha(outline, 0.2)

    readonly property color errorHover: theme?.errorHover ?? withAlpha(error, 0.12)
    readonly property color errorSelected: theme?.errorSelected ?? withAlpha(error, 0.3)

    readonly property color floatingSurface: theme?.floatingSurface ?? withAlpha(surfaceContainer, popupTransparency)
    readonly property color nestedSurface: theme?.nestedSurface ?? withAlpha(surfaceContainerHigh, popupTransparency)
    readonly property color shadowStrong: theme?.shadowStrong ?? Qt.rgba(0, 0, 0, 0.3)

    readonly property color buttonBg: theme?.buttonBg ?? primary
    readonly property color buttonText: theme?.buttonText ?? primaryText
    readonly property color buttonHover: theme?.buttonHover ?? primaryHover
    readonly property color buttonPressed: theme?.buttonPressed ?? primaryPressed
    readonly property color widgetBaseHoverColor: theme?.widgetBaseHoverColor ?? _blend(surfaceContainer, primary, 0.1)

    readonly property real cornerRadius: theme?.cornerRadius ?? 12
    readonly property real spacingXXS: theme?.spacingXXS ?? 2
    readonly property real spacingXS: theme?.spacingXS ?? 4
    readonly property real spacingS: theme?.spacingS ?? 8
    readonly property real spacingM: theme?.spacingM ?? 12
    readonly property real spacingL: theme?.spacingL ?? 16
    readonly property real spacingXL: theme?.spacingXL ?? 24
    readonly property real fontSizeSmall: theme?.fontSizeSmall ?? 12
    readonly property real fontSizeMedium: theme?.fontSizeMedium ?? 14
    readonly property real fontSizeLarge: theme?.fontSizeLarge ?? 16
    readonly property real fontSizeXLarge: theme?.fontSizeXLarge ?? 20
    readonly property real iconSize: theme?.iconSize ?? 24
    readonly property real iconSizeSmall: theme?.iconSizeSmall ?? 16
    readonly property real iconSizeLarge: theme?.iconSizeLarge ?? 32
    readonly property string fontFamily: theme?.fontFamily ?? Fonts.sans
    readonly property string monoFontFamily: theme?.monoFontFamily ?? Fonts.mono
    readonly property int fontWeight: theme?.fontWeight ?? Font.Normal
    readonly property real popupTransparency: theme?.popupTransparency ?? 1.0

    readonly property int currentAnimationSpeed: theme?.currentAnimationSpeed ?? Style.AnimationSpeed.Short
    readonly property int currentAnimationBaseDuration: theme?.currentAnimationBaseDuration ?? 500
    readonly property int shorterDuration: theme?.shorterDuration ?? 50
    readonly property int shortDuration: theme?.shortDuration ?? 75
    readonly property int mediumDuration: theme?.mediumDuration ?? 150
    readonly property int standardEasing: theme?.standardEasing ?? Easing.OutCubic
    readonly property int emphasizedEasing: theme?.emphasizedEasing ?? Easing.OutQuart

    readonly property var expressiveCurves: theme?.expressiveCurves ?? ({
            "emphasized": [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1],
            "emphasizedAccel": [0.3, 0, 0.8, 0.15, 1, 1],
            "emphasizedDecel": [0.05, 0.7, 0.1, 1, 1, 1],
            "standard": [0.2, 0, 0, 1, 1, 1],
            "standardAccel": [0.3, 0, 1, 1, 1, 1],
            "standardDecel": [0, 0, 0, 1, 1, 1],
            "expressiveFastSpatial": [0.42, 1.67, 0.21, 0.9, 1, 1],
            "expressiveDefaultSpatial": [0.38, 1.21, 0.22, 1, 1, 1],
            "expressiveEffects": [0.34, 0.8, 0.34, 1, 1, 1]
        })

    readonly property var expressiveDurations: theme?.expressiveDurations ?? ({
            "fast": 200,
            "normal": 400,
            "large": 600,
            "extraLarge": 1000,
            "expressiveFastSpatial": 350,
            "expressiveDefaultSpatial": 500,
            "expressiveEffects": 200
        })

    readonly property bool elevationEnabled: theme?.elevationEnabled ?? true
    readonly property string elevationLightDirection: theme?.elevationLightDirection ?? "top"
    readonly property var elevationLevel2: theme?.elevationLevel2 ?? ({
            blurPx: 8,
            offsetX: 0,
            offsetY: 4,
            spreadPx: 0,
            alpha: 0.25
        })

    readonly property bool enableRippleEffects: settings?.enableRippleEffects ?? true
    readonly property bool popoutElevationEnabled: settings?.popoutElevationEnabled ?? true
    readonly property int textRenderType: settings?.textRenderType ?? Style.TextRenderType.Qt
    readonly property int textRenderQuality: settings?.textRenderQuality ?? Style.TextRenderQuality.Default
    readonly property bool powerActionConfirm: settings?.powerActionConfirm ?? true
    readonly property real powerActionHoldDuration: settings?.powerActionHoldDuration ?? 0.5
    readonly property var powerMenuActions: settings?.powerMenuActions ?? ["reboot", "logout", "poweroff", "lock", "suspend", "restart"]
    readonly property string powerMenuDefaultAction: settings?.powerMenuDefaultAction ?? "logout"
    readonly property bool powerMenuGridLayout: settings?.powerMenuGridLayout ?? false

    function withAlpha(c, a) {
        if (!c || c.r === undefined)
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function blendAlpha(c, a) {
        if (!c || c.r === undefined)
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(c.r, c.g, c.b, c.a * a);
    }

    function _blend(c1, c2, r) {
        return Qt.rgba(c1.r * (1 - r) + c2.r * r, c1.g * (1 - r) + c2.g * r, c1.b * (1 - r) + c2.b * r, c1.a * (1 - r) + c2.a * r);
    }

    function elevationOffsetXFor(level, direction, fallback) {
        if (theme)
            return theme.elevationOffsetXFor(level, direction, fallback);
        return level?.offsetX ?? 0;
    }

    function elevationOffsetYFor(level, direction, fallback) {
        if (theme)
            return theme.elevationOffsetYFor(level, direction, fallback);
        return level?.offsetY ?? (fallback ?? 0);
    }

    function elevationShadowColor(level) {
        if (theme)
            return theme.elevationShadowColor(level);
        return Qt.rgba(0, 0, 0, level?.alpha ?? 0.3);
    }

    function elevationAmbient(level) {
        if (theme)
            return theme.elevationAmbient(level);
        return {
            blurPx: (level?.blurPx ?? 0) * 1.75,
            spreadPx: 1,
            alpha: (level?.alpha ?? 0.3) * 0.5
        };
    }
}
