import Quickshell.Io

JsonObject {
    property bool persistent: true
    property bool showOnHover: true
    property int dragThreshold: 20

    property JsonObject sizes: JsonObject {
        property int innerHeight: 20
        property int windowPreviewSize: 200
        property int trayMenuWidth: 200
        property int batteryWidth: 150
    }

    property JsonObject workspaces: JsonObject {
        property int shown: 3
        property bool rounded: true
        property bool activeIndicator: true
        property bool occupiedBg: false
        property bool showWindows: true
        property bool activeTrail: false
        property string label: "  "
        property string occupiedLabel: "󰮯 "
        property string activeLabel: "󰮯 "
    }
}
