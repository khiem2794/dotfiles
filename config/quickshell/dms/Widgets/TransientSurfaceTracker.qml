pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    property var _entries: []
    readonly property bool active: _entries.length > 0
    readonly property var focusWindows: _entries.map(entry => entry.focusWindow).filter(window => window)

    signal closeRequested

    function setActive(owner, active, focusWindow) {
        if (!owner)
            return;
        const next = _entries.filter(entry => entry.owner !== owner);
        if (active) {
            next.push({
                "owner": owner,
                "focusWindow": focusWindow ?? null
            });
        }
        _entries = next;
    }

    function unregister(owner) {
        setActive(owner, false, null);
    }

    function closeAll() {
        if (_entries.length === 0)
            return;
        closeRequested();
        _entries = [];
    }
}
