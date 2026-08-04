import QtQuick

NumberAnimation {
    duration: Style.expressiveDurations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Style.expressiveCurves.standard
}
