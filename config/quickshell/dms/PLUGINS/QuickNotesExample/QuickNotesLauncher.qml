import QtQuick
import Quickshell
import qs.Services

Item {
    id: root

    property var pluginService: null
    property string trigger: "n"

    signal itemsChanged

    property var notes: []
    property int maxNotes: 50

    Component.onCompleted: {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData("quickNotesExample", "trigger", "n");
        maxNotes = pluginService.loadPluginData("quickNotesExample", "maxNotes", 50);

        // Load notes from plugin STATE (persistent across sessions, separate file)
        notes = pluginService.loadPluginState("quickNotesExample", "notes", []);
    }

    function getItems(query) {
        const items = [];

        if (query && query.trim().length > 0) {
            const text = query.trim();
            items.push({
                name: "Save note: " + text,
                icon: "material:note_add",
                comment: "Save as a new note",
                action: "add:" + text,
                categories: ["Quick Notes"]
            });

            items.push({
                name: "Copy: " + text,
                icon: "material:content_copy",
                comment: "Copy text to clipboard",
                action: "copy:" + text,
                categories: ["Quick Notes"]
            });
        }

        const filteredNotes = query ? notes.filter(n => n.text.toLowerCase().includes(query.toLowerCase())) : notes;

        for (let i = 0; i < Math.min(20, filteredNotes.length); i++) {
            const note = filteredNotes[i];
            const age = _formatAge(note.timestamp);
            items.push({
                name: note.text,
                icon: "material:sticky_note_2",
                comment: age + " — select to copy, hold for options",
                action: "copy:" + note.text,
                categories: ["Quick Notes"]
            });
        }

        if (notes.length > 0 && !query) {
            items.push({
                name: "Clear all notes (" + notes.length + ")",
                icon: "material:delete_sweep",
                comment: "Remove all saved notes",
                action: "clear:",
                categories: ["Quick Notes"]
            });
        }

        return items;
    }

    function executeItem(item) {
        if (!item?.action)
            return;

        const colonIdx = item.action.indexOf(":");
        const actionType = item.action.substring(0, colonIdx);
        const actionData = item.action.substring(colonIdx + 1);

        switch (actionType) {
        case "add":
            addNote(actionData);
            break;
        case "copy":
            copyToClipboard(actionData);
            break;
        case "remove":
            removeNote(actionData);
            break;
        case "clear":
            clearAllNotes();
            break;
        default:
            showToast("Unknown action: " + actionType);
        }
    }

    function addNote(text) {
        if (!text)
            return;

        const existing = notes.findIndex(n => n.text === text);
        if (existing !== -1)
            notes.splice(existing, 1);

        notes.unshift({
            text: text,
            timestamp: Date.now()
        });

        if (notes.length > maxNotes)
            notes = notes.slice(0, maxNotes);

        _saveNotes();
        showToast("Note saved");
    }

    function removeNote(text) {
        notes = notes.filter(n => n.text !== text);
        _saveNotes();
        showToast("Note removed");
    }

    function clearAllNotes() {
        notes = [];
        pluginService.clearPluginState("quickNotesExample");
        showToast("All notes cleared");
        itemsChanged();
    }

    function _saveNotes() {
        if (!pluginService)
            return;
        // Save to plugin STATE — writes to quickNotesExample_state.json
        // This is separate from plugin SETTINGS (plugin_settings.json)
        pluginService.savePluginState("quickNotesExample", "notes", notes);
        itemsChanged();
    }

    function copyToClipboard(text) {
        Quickshell.execDetached(["dms", "cl", "copy", text]);
        showToast("Copied to clipboard");
    }

    function showToast(message) {
        if (typeof ToastService !== "undefined")
            ToastService.showInfo("Quick Notes", message);
    }

    function _formatAge(timestamp) {
        if (!timestamp)
            return "";
        const seconds = Math.floor((Date.now() - timestamp) / 1000);
        if (seconds < 60)
            return "just now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m ago";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h ago";
        const days = Math.floor(hours / 24);
        return days + "d ago";
    }

    onTriggerChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("quickNotesExample", "trigger", trigger);
    }
}
