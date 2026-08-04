import QtQuick
import qs.DankCommon.Common

// Premultiplied-alpha color tween: bind `to`, read `value`. Plain
// ColorAnimation lerps raw RGBA and flashes when the endpoints differ
// in both color and alpha (translucent <-> opaque).
QtObject {
    id: root

    property color to
    property bool animated: true
    property int duration: Style.mediumDuration
    property int easingType: Style.emphasizedEasing

    property color _from: to
    property color _target: to
    property real _mix: 1
    property bool _ready: false

    readonly property color value: {
        const from = _from;
        const target = _target;
        const alpha = from.a + (target.a - from.a) * _mix;
        if (alpha <= 0)
            return Qt.rgba(target.r, target.g, target.b, 0);
        const mix = (a, b) => (a * from.a + (b * target.a - a * from.a) * _mix) / alpha;
        return Qt.rgba(mix(from.r, target.r), mix(from.g, target.g), mix(from.b, target.b), alpha);
    }

    readonly property NumberAnimation _anim: NumberAnimation {
        target: root
        property: "_mix"
        from: 0
        to: 1
        duration: root.duration
        easing.type: root.easingType
    }

    onToChanged: {
        if (!_ready || !animated) {
            _anim.stop();
            _from = to;
            _target = to;
            _mix = 1;
            return;
        }
        if (Qt.colorEqual(to, _target))
            return;
        const current = value;
        _anim.stop();
        _from = current;
        _target = to;
        _mix = 0;
        _anim.restart();
    }

    Component.onCompleted: {
        _from = to;
        _target = to;
        _ready = true;
    }
}
