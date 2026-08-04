import QtQuick

// Reusable ColorAnimation wrapper
ColorAnimation {
    duration: Style.expressiveDurations.normal
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Style.expressiveCurves.standard
}
