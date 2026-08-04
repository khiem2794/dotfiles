import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "exampleDesktopClock"

    SelectionSetting {
        settingKey: "clockStyle"
        label: "Clock Style"
        options: [
            {
                label: "Analog",
                value: "analog"
            },
            {
                label: "Digital",
                value: "digital"
            }
        ]
        defaultValue: "analog"
    }

    ToggleSetting {
        settingKey: "showSeconds"
        label: "Show Seconds"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showDate"
        label: "Show Date"
        defaultValue: true
    }

    SliderSetting {
        settingKey: "backgroundOpacity"
        label: "Background Opacity"
        defaultValue: 50
        minimum: 0
        maximum: 100
        unit: "%"
    }
}
