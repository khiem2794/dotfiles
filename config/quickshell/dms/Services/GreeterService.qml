pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false

    function refresh() {
        detectProcess.running = true;
    }

    Process {
        id: detectProcess

        command: ["sh", "-c", "command -v dms-greeter >/dev/null 2>&1 || grep -qs dms-greeter /etc/greetd/config.toml"]
        running: true

        onExited: exitCode => {
            root.available = exitCode === 0;
        }
    }
}
