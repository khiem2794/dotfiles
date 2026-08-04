import QtQuick
import qs.DankCommon.Common

Text {
    property bool isMonospace: false

    readonly property string resolvedFontFamily: isMonospace ? Style.monoFontFamily : Style.fontFamily

    readonly property int resolvedRenderType: {
        switch (Style.textRenderType) {
        case Style.TextRenderType.Qt:
            return Text.QtRendering;
        case Style.TextRenderType.Curve:
            return Text.CurveRendering;
        default:
            return Text.NativeRendering;
        }
    }

    readonly property int resolvedRenderQuality: {
        switch (Style.textRenderQuality) {
        case Style.TextRenderQuality.Low:
            return Text.LowRenderTypeQuality;
        case Style.TextRenderQuality.Normal:
            return Text.NormalRenderTypeQuality;
        case Style.TextRenderQuality.High:
            return Text.HighRenderTypeQuality;
        case Style.TextRenderQuality.VeryHigh:
            return Text.VeryHighRenderTypeQuality;
        default:
            return Text.DefaultRenderTypeQuality;
        }
    }

    readonly property var standardAnimation: {
        "duration": Appearance.anim.durations.normal,
        "easing.type": Easing.BezierSpline,
        "easing.bezierCurve": Appearance.anim.curves.standard
    }

    color: Style.surfaceText
    font.pixelSize: Appearance.fontSize.normal
    font.family: resolvedFontFamily
    font.weight: Style.fontWeight
    textFormat: Text.PlainText
    wrapMode: Text.WordWrap
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    renderType: resolvedRenderType
    renderTypeQuality: resolvedRenderQuality

    Behavior on opacity {
        NumberAnimation {
            duration: standardAnimation.duration
            easing.type: standardAnimation["easing.type"]
            easing.bezierCurve: standardAnimation["easing.bezierCurve"]
        }
    }
}
