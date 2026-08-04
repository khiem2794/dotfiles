pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    property var backend: null

    readonly property bool isRtl: backend?.isRtl ?? false

    function tr(term, context, isRealContext) {
        return backend ? backend.tr(term, context, isRealContext) : term;
    }
}
