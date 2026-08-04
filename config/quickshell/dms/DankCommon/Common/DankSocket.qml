pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io

Item {
    id: root

    property string path: ""
    property var parser: null
    property bool connected: false
    property bool linkUp: false

    property int reconnectBaseMs: 400
    property int reconnectMaxMs: 15000

    property int _reconnectAttempt: 0

    signal connectionStateChanged

    onConnectedChanged: {
        if (connected) {
            _restartSocket();
        } else {
            reconnectTimer.stop();
            _teardown();
        }
    }

    // Quickshell's Socket cannot redial after a failed attempt: its dead
    // QLocalSocket is only cleared when a *successful* connection closes, and
    // setting connected back to true is a no-op while the object exists. Every
    // attempt therefore gets a fresh Socket instance.
    function _restartSocket() {
        _teardown();
        socketLoader.active = true;
    }

    function _teardown() {
        socketLoader.active = false;
        if (linkUp) {
            linkUp = false;
            connectionStateChanged();
        }
    }

    function send(data) {
        const socket = socketLoader.item;
        if (!socket)
            return;
        const json = typeof data === "string" ? data : JSON.stringify(data);
        const message = json.endsWith("\n") ? json : json + "\n";
        socket.write(message);
        socket.flush();
    }

    function _scheduleReconnect() {
        const pow = Math.min(_reconnectAttempt, 10);
        const base = Math.min(reconnectBaseMs * Math.pow(2, pow), reconnectMaxMs);
        const jitter = Math.floor(Math.random() * Math.floor(base / 4));
        reconnectTimer.interval = base + jitter;
        reconnectTimer.restart();
        _reconnectAttempt++;
    }

    Loader {
        id: socketLoader
        active: false

        // Dial only once `item` is assigned: a unix connect can complete
        // synchronously, and handlers fired mid-creation would see a null
        // `socketLoader.item`, silently dropping the first sends.
        onLoaded: item.connected = true

        sourceComponent: Socket {
            path: root.path
            parser: root.parser

            onConnectionStateChanged: {
                root.linkUp = connected;
                root.connectionStateChanged();
                if (connected) {
                    root._reconnectAttempt = 0;
                    return;
                }
                if (root.connected)
                    root._scheduleReconnect();
            }

            // A failed dial emits only the error signal, never a connection
            // state transition, so the retry loop must also start from here.
            onError: err => {
                if (root.connected && !root.linkUp)
                    root._scheduleReconnect();
            }
        }
    }

    Timer {
        id: reconnectTimer
        repeat: false
        onTriggered: {
            if (root.connected && !root.linkUp)
                root._restartSocket();
        }
    }
}
