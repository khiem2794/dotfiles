import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string scriptPath: pluginData.scriptPath || ""
    property var popoutService: null

    Connections {
        target: SessionData
        function onWallpaperPathChanged() {
            if (scriptPath) {
                var scriptProcess = scriptProcessComponent.createObject(root, {
                    wallpaperPath: SessionData.wallpaperPath
                })
                scriptProcess.running = true
            }
        }
    }

    Component {
        id: scriptProcessComponent

        Process {
            property string wallpaperPath: ""

            command: [scriptPath, wallpaperPath]

            stdout: StdioCollector {
                onStreamFinished: {
                    if (text.trim()) {
                        console.log("WallpaperWatcherDaemon script output:", text.trim())
                    }
                }
            }

            stderr: StdioCollector {
                onStreamFinished: {
                    if (text.trim()) {
                        ToastService.showError("Wallpaper Change Script Error", text.trim())
                    }
                }
            }

            onExited: (exitCode) => {
                if (exitCode !== 0) {
                    ToastService.showError("Wallpaper Change Script Error", "Script exited with code: " + exitCode)
                }
                destroy()
            }
        }
    }

    Component.onCompleted: {
        console.info("WallpaperWatcherDaemon: Started monitoring wallpaper changes")
    }

    Component.onDestruction: {
        console.info("WallpaperWatcherDaemon: Stopped monitoring wallpaper changes")
    }
}
