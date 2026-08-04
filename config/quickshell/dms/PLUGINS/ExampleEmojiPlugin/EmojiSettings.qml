import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "exampleEmojiPlugin"

    // Header section to explain what this plugin does
    StyledText {
        width: parent.width
        text: "Emoji Cycler Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure which emojis appear in your bar, how quickly they cycle, and how many show at once."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    // Dropdown to select which emoji set to use
    SelectionSetting {
        settingKey: "emojiSet"
        label: "Emoji Set"
        description: "Choose which collection of emojis to cycle through"
        options: [
            {label: "Happy & Sad", value: "happySad"},
            {label: "Hearts", value: "hearts"},
            {label: "Hand Gestures", value: "hands"},
            {label: "All Mixed", value: "mixed"}
        ]
        defaultValue: "happySad"

        // Update the actual emoji array when selection changes
        onValueChanged: {
            const sets = {
                "happySad": ["😊", "😢", "😂", "😭", "😍", "😡"],
                "hearts": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍"],
                "hands": ["👍", "👎", "👊", "✌️", "🤘", "👌", "✋", "🤚"],
                "mixed": ["😊", "❤️", "👍", "🎉", "🔥", "✨", "🌟", "💯"]
            }
            const newEmojis = sets[value] || sets["happySad"]
            root.saveValue("emojis", newEmojis)
        }

        Component.onCompleted: {
            // Initialize the emojis array on first load
            const currentSet = value || defaultValue
            const sets = {
                "happySad": ["😊", "😢", "😂", "😭", "😍", "😡"],
                "hearts": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍"],
                "hands": ["👍", "👎", "👊", "✌️", "🤘", "👌", "✋", "🤚"],
                "mixed": ["😊", "❤️", "👍", "🎉", "🔥", "✨", "🌟", "💯"]
            }
            const emojis = sets[currentSet] || sets["happySad"]
            root.saveValue("emojis", emojis)
        }
    }

    // Slider to control how fast emojis cycle (in milliseconds)
    SliderSetting {
        settingKey: "cycleInterval"
        label: "Cycle Speed"
        description: "How quickly emojis rotate (in seconds)"
        defaultValue: 3000
        minimum: 500
        maximum: 10000
        unit: "ms"
        leftIcon: "schedule"
    }

    // Slider to control max emojis shown in the bar
    SliderSetting {
        settingKey: "maxBarEmojis"
        label: "Max Bar Emojis"
        description: "Maximum number of emojis to display in the bar at once"
        defaultValue: 3
        minimum: 1
        maximum: 8
        unit: ""
        rightIcon: "emoji_emotions"
    }

    StyledText {
        width: parent.width
        text: "💡 Tip: Click the emoji widget in your bar to open the emoji picker and copy any emoji to your clipboard!"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }
}
