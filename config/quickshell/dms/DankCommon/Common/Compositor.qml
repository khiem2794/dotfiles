pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string desktop: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").split(":")[0].toLowerCase()

    readonly property bool supportsMinimize: {
        if (Quickshell.env("NIRI_SOCKET"))
            return false;
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
            return false;

        switch (desktop) {
        case "niri":
        case "hyprland":
        case "sway":
        case "river":
        case "dwl":
            return false;
        default:
            return true;
        }
    }
}
