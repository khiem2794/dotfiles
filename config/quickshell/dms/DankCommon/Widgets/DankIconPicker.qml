import QtQuick
import QtQuick.Controls
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property string currentIcon: ""
    property string iconType: "icon"

    signal iconSelected(string iconName, string iconType)

    width: 240
    height: 32
    radius: Style.cornerRadius
    color: Style.surfaceContainer
    border.color: iconPopup.visible ? Style.primary : Style.outline
    border.width: 1

    property var iconCategories: [
        {
            "name": I18n.tr("Numbers"),
            "icons": ["looks_one", "looks_two", "looks_3", "looks_4", "looks_5", "looks_6", "filter_1", "filter_2", "filter_3", "filter_4", "filter_5", "filter_6", "filter_7", "filter_8", "filter_9", "filter_9_plus", "plus_one", "exposure_plus_1", "exposure_plus_2"]
        },
        {
            "name": I18n.tr("Workspace"),
            "icons": ["work", "laptop", "desktop_windows", "folder", "view_module", "dashboard", "apps", "grid_view"]
        },
        {
            "name": I18n.tr("Development"),
            "icons": ["code", "terminal", "bug_report", "build", "engineering", "integration_instructions", "data_object", "schema", "api", "webhook"]
        },
        {
            "name": I18n.tr("Communication"),
            "icons": ["chat", "mail", "forum", "message", "video_call", "call", "contacts", "group", "notifications", "campaign"]
        },
        {
            "name": I18n.tr("Media"),
            "icons": ["music_note", "headphones", "mic", "videocam", "photo", "movie", "library_music", "album", "radio", "volume_up"]
        },
        {
            "name": I18n.tr("System"),
            "icons": ["memory", "storage", "developer_board", "monitor", "keyboard", "mouse", "battery_std", "wifi", "bluetooth", "security", "settings"]
        },
        {
            "name": I18n.tr("Navigation"),
            "icons": ["home", "arrow_forward", "arrow_back", "expand_more", "expand_less", "menu", "close", "search", "filter_list", "sort"]
        },
        {
            "name": I18n.tr("Actions"),
            "icons": ["add", "remove", "edit", "delete", "save", "download", "upload", "share", "content_copy", "content_paste", "content_cut", "undo", "redo"]
        },
        {
            "name": I18n.tr("Status"),
            "icons": ["check", "error", "warning", "info", "done", "pending", "schedule", "update", "sync", "offline_bolt"]
        },
        {
            "name": I18n.tr("Fun"),
            "icons": ["celebration", "cake", "star", "favorite", "pets", "sports_esports", "local_fire_department", "bolt", "auto_awesome", "diamond"]
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (iconPopup.visible) {
                iconPopup.close();
                return;
            }
            const pos = root.mapToItem(Overlay.overlay, 0, 0);
            const popupHeight = 500;
            const overlayHeight = Overlay.overlay?.height ?? 800;
            iconPopup.x = pos.x;
            if (pos.y + root.height + popupHeight + 4 > overlayHeight) {
                iconPopup.y = pos.y - popupHeight - 4;
            } else {
                iconPopup.y = pos.y + root.height + 4;
            }
            iconPopup.open();
        }
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Style.spacingS
        spacing: Style.spacingS

        DankIcon {
            name: (root.iconType === "icon" && root.currentIcon) ? root.currentIcon : (root.iconType === "text" ? "text_fields" : "add")
            size: 16
            color: root.currentIcon ? Style.surfaceText : Style.outline
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: root.currentIcon ? root.currentIcon : I18n.tr("Choose icon")
            font.pixelSize: Style.fontSizeSmall
            color: root.currentIcon ? Style.surfaceText : Style.outline
            anchors.verticalCenter: parent.verticalCenter
            width: 160
            elide: Text.ElideRight
        }
    }

    DankIcon {
        name: iconPopup.visible ? "expand_less" : "expand_more"
        size: 16
        color: Style.outline
        anchors.right: parent.right
        anchors.rightMargin: Style.spacingS
        anchors.verticalCenter: parent.verticalCenter
    }

    Popup {
        id: iconPopup

        parent: root.Overlay.overlay
        width: 320
        height: Math.min(500, dropdownContent.implicitHeight + 32)
        padding: 0
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "transparent"
        }

        contentItem: Rectangle {
            id: contentSurface
            color: Style.surface
            radius: Style.cornerRadius

            ElevationShadow {
                id: shadowLayer
                anchors.fill: parent
                z: -1
                level: Style.elevationLevel2
                fallbackOffset: 4
                targetRadius: contentSurface.radius
                targetColor: contentSurface.color
                shadowOpacity: Style.elevationLevel2 && Style.elevationLevel2.alpha !== undefined ? Style.elevationLevel2.alpha : 0.25
                shadowEnabled: Style.elevationEnabled
            }

            Rectangle {
                width: 24
                height: 24
                radius: 12
                color: closeMouseArea.containsMouse ? Style.errorHover : Style.withAlpha(Style.errorHover, 0)
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Style.spacingS
                anchors.rightMargin: Style.spacingS
                z: 1

                DankIcon {
                    name: "close"
                    size: 16
                    color: closeMouseArea.containsMouse ? Style.error : Style.outline
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: iconPopup.close()
                }
            }

            DankFlickable {
                anchors.fill: parent
                anchors.margins: Style.spacingS
                contentHeight: dropdownContent.height
                clip: true
                pressDelay: 0

                Column {
                    id: dropdownContent
                    width: parent.width
                    spacing: Style.spacingM

                    Repeater {
                        model: root.iconCategories

                        Column {
                            required property var modelData
                            width: parent.width
                            spacing: Style.spacingS

                            StyledText {
                                text: modelData.name
                                font.pixelSize: Style.fontSizeSmall
                                font.weight: Font.Medium
                                color: Style.surfaceText
                            }

                            Flow {
                                width: parent.width
                                spacing: Style.spacingXS

                                Repeater {
                                    model: modelData.icons

                                    Rectangle {
                                        required property string modelData
                                        width: 36
                                        height: 36
                                        radius: Style.cornerRadius
                                        color: iconMouseArea.containsMouse ? Style.primaryHover : Style.withAlpha(Style.primaryHover, 0)
                                        border.color: root.currentIcon === modelData ? Style.primary : Style.withAlpha(Style.primary, 0)
                                        border.width: 2

                                        DankIcon {
                                            name: parent.modelData
                                            size: 20
                                            color: root.currentIcon === parent.modelData ? Style.primary : Style.surfaceText
                                            anchors.centerIn: parent
                                        }

                                        MouseArea {
                                            id: iconMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.iconSelected(parent.modelData, "icon");
                                                iconPopup.close();
                                            }
                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Style.shortDuration
                                                easing.type: Style.standardEasing
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function setIcon(iconName, type) {
        root.iconType = type;
        root.iconType = "icon";
        root.currentIcon = iconName;
    }
}
