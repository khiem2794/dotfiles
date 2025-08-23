import QtQuick
import Quickshell
import "root:/modules/common/functions/color_utils.js" as ColorUtils
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property QtObject m3colors
    property QtObject animation
    property QtObject animationCurves
    property QtObject colors
    property QtObject rounding
    property QtObject font
    property QtObject sizes
    property string syntaxHighlightingTheme

    // Extremely conservative transparency values for consistency and readability
    property real transparency: Config.options?.appearance.transparency ? (m3colors.darkmode ? 0.1 : 0.07) : 0
    property real contentTransparency: Config.options?.appearance.transparency ? (m3colors.darkmode ? 0.55 : 0.55) : 0

    m3colors: QtObject {
    property bool darkmode: true
    property bool transparent: false

    // Palette key colors
    property color m3primary_paletteKeyColor: "#b16286"    // purple
    property color m3secondary_paletteKeyColor: "#689d6a"  // aqua
    property color m3tertiary_paletteKeyColor: "#d79921"   // yellow
    property color m3neutral_paletteKeyColor: "#CDC8B0"    // fg
    property color m3neutral_variant_paletteKeyColor: "#B4AF9A" // bg-1

    // Background and content
    property color m3background: "#4E4B42"        // bg
    property color m3onBackground: "#CDC8B0"      // fg

    // Surface levels
    property color m3surface: "#4E4B42"                          // base
    property color m3surfaceDim: "#38352E"                      // deeper
    property color m3surfaceBright: "#B4AF9A"                   // bg-1
    property color m3surfaceContainerLowest: "#000000"          // black
    property color m3surfaceContainerLow: "#2A2824"             // darkest usable
    property color m3surfaceContainer: "#36332D"                // mid
    property color m3surfaceContainerHigh: "#4A463E"            // lighter
    property color m3surfaceContainerHighest: "#5B574F"         // lightest layer
    property color m3onSurface: "#dad4bb"                       // fg-1

    // Surface variants
    property color m3surfaceVariant: "#bab59d"      // gray
    property color m3onSurfaceVariant: "#B4AF9A"    // bg-1

    // Inverse tones
    property color m3inverseSurface: "#dad4bb"       // fg-1
    property color m3inverseOnSurface: "#4E4B42"     // bg

    // Borders and outlines
    property color m3outline: "#bab59d"              // gray
    property color m3outlineVariant: "#B4AF9A"       // bg-1

    // Shadows & overlays
    property color m3shadow: "#000000"
    property color m3scrim: "#000000"

    // Primary
    property color m3surfaceTint: "#b16286"
    property color m3primary: "#b16286"                // purple
    property color m3onPrimary: "#ffffff"
    property color m3primaryContainer: "#744961"       // darker container
    property color m3onPrimaryContainer: "#f3d6e8"

    // Inverse
    property color m3inversePrimary: "#91689E"

    // Secondary
    property color m3secondary: "#689d6a"              // aqua
    property color m3onSecondary: "#ffffff"
    property color m3secondaryContainer: "#43614b"
    property color m3onSecondaryContainer: "#d6f2dd"

    // Tertiary
    property color m3tertiary: "#d79921"               // yellow
    property color m3onTertiary: "#000000"
    property color m3tertiaryContainer: "#aa8415"
    property color m3onTertiaryContainer: "#fff6d0"

    // Error (Gruvbox red)
    property color m3error: "#cc241d"
    property color m3onError: "#ffffff"
    property color m3errorContainer: "#7c1a14"
    property color m3onErrorContainer: "#ffebe8"

    // Primary fixed
    property color m3primaryFixed: "#dad4bb"               // fg-1
    property color m3primaryFixedDim: "#b16286"
    property color m3onPrimaryFixed: "#362935"
    property color m3onPrimaryFixedVariant: "#744961"

    // Secondary fixed
    property color m3secondaryFixed: "#bab59d"
    property color m3secondaryFixedDim: "#689d6a"
    property color m3onSecondaryFixed: "#29362c"
    property color m3onSecondaryFixedVariant: "#43614b"

    // Tertiary fixed
    property color m3tertiaryFixed: "#f0dc9c"
    property color m3tertiaryFixedDim: "#d79921"
    property color m3onTertiaryFixed: "#3c2c00"
    property color m3onTertiaryFixedVariant: "#aa8415"

    // Success (Gruvbox green)
    property color m3success: "#98971a"
    property color m3onSuccess: "#ffffff"
    property color m3successContainer: "#6b7013"
    property color m3onSuccessContainer: "#f2f8d0"
}


    colors: QtObject {
        property color colSubtext: m3colors.m3outline
        property color colLayer0: ColorUtils.mix(ColorUtils.transparentize(m3colors.m3background, root.transparency), m3colors.m3primary, Config.options.appearance.extraBackgroundTint ? 0.99 : 1)
        property color colOnLayer0: m3colors.m3onBackground
        property color colLayer0Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.9, root.contentTransparency))
        property color colLayer0Active: ColorUtils.transparentize(ColorUtils.mix(colLayer0, colOnLayer0, 0.8, root.contentTransparency))
        property color colLayer1: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainerLow, m3colors.m3background, 0.8), root.contentTransparency);
        property color colOnLayer1: m3colors.m3onSurfaceVariant;
        property color colOnLayer1Inactive: ColorUtils.mix(colOnLayer1, colLayer1, 0.45);
        property color colLayer2: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainer, m3colors.m3surfaceContainerHigh, 0.1), root.contentTransparency)
        property color colOnLayer2: m3colors.m3onSurface;
        property color colOnLayer2Disabled: ColorUtils.mix(colOnLayer2, m3colors.m3background, 0.4);
        property color colLayer3: ColorUtils.transparentize(ColorUtils.mix(m3colors.m3surfaceContainerHigh, m3colors.m3onSurface, 0.96), root.contentTransparency)
        property color colOnLayer3: m3colors.m3onSurface;
        property color colLayer1Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.92), root.contentTransparency)
        property color colLayer1Active: ColorUtils.transparentize(ColorUtils.mix(colLayer1, colOnLayer1, 0.85), root.contentTransparency);
        property color colLayer2Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer2, colOnLayer2, 0.90), root.contentTransparency)
        property color colLayer2Active: ColorUtils.transparentize(ColorUtils.mix(colLayer2, colOnLayer2, 0.80), root.contentTransparency);
        property color colLayer2Disabled: ColorUtils.transparentize(ColorUtils.mix(colLayer2, m3colors.m3background, 0.8), root.contentTransparency);
        property color colLayer3Hover: ColorUtils.transparentize(ColorUtils.mix(colLayer3, colOnLayer3, 0.90), root.contentTransparency)
        property color colLayer3Active: ColorUtils.transparentize(ColorUtils.mix(colLayer3, colOnLayer3, 0.80), root.contentTransparency);
        property color colPrimary: m3colors.m3primary
        property color colOnPrimary: m3colors.m3onPrimary
        property color colPrimaryHover: ColorUtils.mix(colors.colPrimary, colLayer1Hover, 0.87)
        property color colPrimaryActive: ColorUtils.mix(colors.colPrimary, colLayer1Active, 0.7)
        property color colPrimaryContainer: m3colors.m3primaryContainer
        property color colPrimaryContainerHover: ColorUtils.mix(colors.colPrimaryContainer, colLayer1Hover, 0.7)
        property color colPrimaryContainerActive: ColorUtils.mix(colors.colPrimaryContainer, colLayer1Active, 0.6)
        property color colOnPrimaryContainer: m3colors.m3onPrimaryContainer
        property color colSecondary: m3colors.m3secondary
        property color colSecondaryHover: ColorUtils.mix(m3colors.m3secondary, colLayer1Hover, 0.85)
        property color colSecondaryActive: ColorUtils.mix(m3colors.m3secondary, colLayer1Active, 0.4)
        property color colSecondaryContainer: m3colors.m3secondaryContainer
        property color colSecondaryContainerHover: ColorUtils.mix(m3colors.m3secondaryContainer, m3colors.m3onSecondaryContainer, 0.90)
        property color colSecondaryContainerActive: ColorUtils.mix(m3colors.m3secondaryContainer, colLayer1Active, 0.54)
        property color colOnSecondaryContainer: m3colors.m3onSecondaryContainer
        property color colSurfaceContainerLow: ColorUtils.transparentize(m3colors.m3surfaceContainerLow, root.contentTransparency)
        property color colSurfaceContainer: ColorUtils.transparentize(m3colors.m3surfaceContainer, root.contentTransparency)
        property color colSurfaceContainerHigh: ColorUtils.transparentize(m3colors.m3surfaceContainerHigh, root.contentTransparency)
        property color colSurfaceContainerHighest: ColorUtils.transparentize(m3colors.m3surfaceContainerHighest, root.contentTransparency)
        property color colSurfaceContainerHighestHover: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.95)
        property color colSurfaceContainerHighestActive: ColorUtils.mix(m3colors.m3surfaceContainerHighest, m3colors.m3onSurface, 0.85)
        property color colTooltip: m3colors.darkmode ? ColorUtils.mix(m3colors.m3background, "#3C4043", 0.5) : "#3C4043" // m3colors.m3inverseSurface in the specs, but the m3 website actually uses #3C4043
        property color colOnTooltip: "#F8F9FA" // m3colors.m3inverseOnSurface in the specs, but the m3 website actually uses this color
        property color colScrim: ColorUtils.transparentize(m3colors.m3scrim, 0.5)
        property color colShadow: ColorUtils.transparentize(m3colors.m3shadow, 0.7)
        property color colOutlineVariant: m3colors.m3outlineVariant
    }

    rounding: QtObject {
        property int unsharpen: 2
        property int unsharpenmore: 2
        property int verysmall: 2
        property int small: 2
        property int normal: 2
        property int large: 2
        property int verylarge: 2
        property int full: 9999
        property int screenRounding: large
        property int windowRounding: 18
    }

    font: QtObject {
        property QtObject family: QtObject {
            property string main: "Mapple Mono"
            property string title: "Mapple Mono"
            property string iconMaterial: "Material Symbols Rounded"
            property string iconNerd: "JetBrains Mono Nerd Font"
            property string monospace: "JetBrains Mono Nerd Font"
            property string reading: "Mapple Mono"
        }
        property QtObject pixelSize: QtObject {
            property int smallest: 10
            property int smaller: 12
            property int small: 15
            property int normal: 16
            property int large: 17
            property int larger: 19
            property int huge: 22
            property int hugeass: 23
            property int title: huge
        }
    }

    animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }

    animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }
        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }
        property QtObject elementMoveExit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }
        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }

        property QtObject clickBounce: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveFastSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.clickBounce.duration
                    easing.type: root.animation.clickBounce.type
                    easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }
        property QtObject scroll: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }
        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }

    sizes: QtObject {
        property real baseBarHeight: 40
        property real barHeight: Config.options.bar.cornerStyle === 1 ? 
            (baseBarHeight + Appearance.sizes.hyprlandGapsOut * 2) : baseBarHeight
        property real barCenterSideModuleWidth: Config.options?.bar.verbose ? 360 : 140
        property real barCenterSideModuleWidthShortened: 280
        property real barCenterSideModuleWidthHellaShortened: 190
        property real barShortenScreenWidthThreshold: 1200 // Shorten if screen width is at most this value
        property real barHellaShortenScreenWidthThreshold: 1000 // Shorten even more...
        property real sidebarWidth: 450
        property real sidebarWidthExtended: 750
        property real osdWidth: 200
        property real mediaControlsWidth: 440
        property real mediaControlsHeight: 160
        property real notificationPopupWidth: 410
        property real searchWidthCollapsed: 260
        property real searchWidth: 450
        property real hyprlandGapsOut: 8
        property real elevationMargin: 10
        property real fabShadowRadius: 5
        property real fabHoveredShadowRadius: 7
    }

    syntaxHighlightingTheme: Appearance.m3colors.darkmode ? "Monokai" : "ayu Light"
}
