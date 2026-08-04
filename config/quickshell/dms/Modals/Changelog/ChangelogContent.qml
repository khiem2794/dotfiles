import QtQuick
import QtQuick.Effects
import qs.Common
import qs.Services
import qs.Widgets

Column {
    id: root

    readonly property real logoSize: Math.round(Theme.iconSize * 2.8)
    readonly property real badgeHeight: Math.round(Theme.fontSizeSmall * 1.7)

    topPadding: Theme.spacingL
    spacing: Theme.spacingL

    Column {
        width: parent.width
        spacing: Theme.spacingM

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM

            Image {
                width: root.logoSize
                height: width * (569.94629 / 506.50931)
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
                asynchronous: true
                source: "file://" + Theme.shellDir + "/assets/danklogonormal.svg"
                layer.enabled: true
                layer.smooth: true
                layer.mipmap: true
                layer.effect: MultiEffect {
                    saturation: 0
                    colorization: 1
                    colorizationColor: Theme.primary
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXS

                Row {
                    spacing: Theme.spacingS

                    StyledText {
                        text: "DMS " + ChangelogService.currentVersion
                        font.pixelSize: Theme.fontSizeXLarge + 2
                        font.weight: Font.Bold
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: codenameText.implicitWidth + Theme.spacingM * 2
                        height: root.badgeHeight
                        radius: root.badgeHeight / 2
                        color: Theme.primaryContainer
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            id: codenameText
                            anchors.centerIn: parent
                            text: "The Wolverine"
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.Medium
                            color: Theme.primary
                        }
                    }
                }

                StyledText {
                    text: "Frame Mode, DankCalendar, Spotlight, & more"
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceVariantText
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outlineMedium
        opacity: 0.3
    }

    Column {
        width: parent.width
        spacing: Theme.spacingM

        StyledText {
            text: "What's New"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        Grid {
            width: parent.width
            columns: 2
            rowSpacing: Theme.spacingS
            columnSpacing: Theme.spacingS

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "border_outer"
                title: "Frame Mode"
                description: "Connected shell surfaces"
                onClicked: PopoutService.openSettingsWithTab("frame")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "calendar_month"
                title: "DankCalendar"
                description: "Native calendar & events"
                onClicked: Qt.openUrlExternally("https://github.com/AvengeMedia/dankcalendar")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "search"
                title: "Spotlight"
                description: "Lightweight launcher"
                onClicked: PopoutService.openSpotlightBar()
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "window"
                title: "Window Rules"
                description: "Rules for many compositors"
                onClicked: PopoutService.openSettingsWithTab("window_rules")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "display_settings"
                title: "Display Profiles"
                description: "Auto-switch monitor layouts"
                onClicked: PopoutService.openSettingsWithTab("display_config")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "dvr"
                title: "Multiplexer Launcher"
                description: "Attach to tmux sessions"
                onClicked: PopoutService.openSettingsWithTab("multiplexers")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "edit_note"
                title: "Notepad Rewrite"
                description: "Popout & tiling support"
                onClicked: PopoutService.openNotepad()
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "gradient"
                title: "M3 Shadows"
                description: "Reworked elevation system"
                onClicked: PopoutService.openSettingsWithTab("theme")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "login"
                title: "Greeter Enhancements"
                description: "Settings GUI & multi-user"
                onClicked: PopoutService.openSettingsWithTab("greeter")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "content_paste"
                title: "Clipboard Filtering"
                description: "Text, image & pinned filters"
                onClicked: PopoutService.openSettingsWithTab("clipboard")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "restart_alt"
                title: "XDG Autostart"
                description: "Manage apps at login"
                onClicked: PopoutService.openSettingsWithTab("autostart")
            }

            ChangelogFeatureCard {
                width: (parent.width - Theme.spacingS) / 2
                iconName: "apps"
                title: "Default Apps"
                description: "Set preferred applications"
                onClicked: PopoutService.openSettingsWithTab("default_apps")
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outlineMedium
        opacity: 0.3
    }

    Column {
        width: parent.width
        spacing: Theme.spacingS

        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "warning"
                size: Theme.iconSizeSmall
                color: Theme.warning
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "Upgrade Notes"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: upgradeNotesColumn.height + Theme.spacingM * 2
            radius: Theme.cornerRadius
            color: Theme.withAlpha(Theme.warning, 0.08)
            border.width: 1
            border.color: Theme.withAlpha(Theme.warning, 0.2)

            Column {
                id: upgradeNotesColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingS

                ChangelogUpgradeNote {
                    width: parent.width
                    text: "App ID changed to com.danklinux.dms — update any compositor window rules targeting the old ID"
                }
            }
        }

        // StyledText {
        //     text: "See full release notes for migration steps"
        //     font.pixelSize: Theme.fontSizeSmall
        //     color: Theme.surfaceVariantText
        //     width: parent.width
        // }
    }
}
