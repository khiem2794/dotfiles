pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import QtCore
import Quickshell

Singleton {
    id: root

    property var backend: null

    readonly property url xdgCache: backend?.xdgCache ?? StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]
    readonly property url imagecache: backend?.imagecache ?? `${xdgCache}/imagecache`

    function stringify(path) {
        if (backend)
            return backend.stringify(path);
        const raw = path.toString();
        try {
            return decodeURIComponent(raw);
        } catch (e) {
            return raw;
        }
    }

    function strip(path) {
        if (backend)
            return backend.strip(path);
        return stringify(path).replace("file://", "");
    }

    function resolveIconPath(iconName) {
        if (backend)
            return backend.resolveIconPath(iconName);
        if (!iconName)
            return "";
        return Quickshell.iconPath(iconName, true) || "";
    }

    function trashPath(path, callback) {
        if (!backend)
            return;
        backend.trashPath(path, callback);
    }

    function copyPathToClipboard(path) {
        if (backend)
            backend.copyPathToClipboard(path);
    }
}
