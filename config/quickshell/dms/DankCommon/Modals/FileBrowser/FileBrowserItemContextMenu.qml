import QtQuick
import QtQuick.Controls
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Popup {
    id: root

    property string filePath: ""
    property string fileName: ""
    property bool fileIsDir: false
    property var parentFocusItem: null

    signal trashed
    signal menuClosed

    readonly property var menuItems: [
        {
            text: I18n.tr("Move to Trash", "file browser item context menu action"),
            icon: "delete",
            action: trashItem,
            enabled: filePath.length > 0,
            dangerous: true
        },
        {
            text: I18n.tr("Copy path", "file browser item context menu action"),
            icon: "content_copy",
            action: copyPath,
            enabled: filePath.length > 0
        }
    ]

    function showAt(parentItem, localX, localY, path, name, isDir) {
        if (!parentItem)
            return;
        parent = parentItem;
        filePath = path || "";
        fileName = name || "";
        fileIsDir = !!isDir;
        x = Math.max(0, Math.min(parentItem.width - width, localX));
        y = Math.max(0, Math.min(parentItem.height - height, localY));
        open();
    }

    function trashItem() {
        if (!filePath)
            return;
        Paths.trashPath(filePath, ok => {
            if (ok)
                root.trashed();
        });
        close();
    }

    function copyPath() {
        if (!filePath)
            return;
        Paths.copyPathToClipboard(filePath);
        close();
    }

    width: 220
    height: menuColumn.implicitHeight + Style.spacingS * 2
    padding: 0
    modal: false
    closePolicy: Popup.CloseOnEscape

    onClosed: {
        closePolicy = Popup.CloseOnEscape;
        menuClosed();
        if (parentFocusItem)
            Qt.callLater(() => parentFocusItem.forceActiveFocus());
    }

    onOpened: outsideClickTimer.start()

    Timer {
        id: outsideClickTimer
        interval: 100
        onTriggered: root.closePolicy = Popup.CloseOnEscape | Popup.CloseOnPressOutside
    }

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        color: Style.floatingSurface
        radius: Style.cornerRadius
        border.color: Qt.rgba(Style.outline.r, Style.outline.g, Style.outline.b, 0.08)
        border.width: 1

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: Style.spacingS
            spacing: 1

            Repeater {
                model: root.menuItems

                Rectangle {
                    width: parent.width
                    height: 32
                    radius: Style.cornerRadius
                    opacity: modelData.enabled ? 1 : 0.5
                    color: {
                        if (!modelData.enabled || !area.containsMouse)
                            return "transparent";
                        if (modelData.dangerous)
                            return Qt.rgba(Style.error.r, Style.error.g, Style.error.b, 0.12);
                        return Style.widgetBaseHoverColor;
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.spacingS
                        anchors.right: parent.right
                        anchors.rightMargin: Style.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Style.spacingS

                        DankIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: modelData.icon
                            size: 16
                            color: modelData.dangerous && area.containsMouse && modelData.enabled ? Style.error : Style.surfaceText
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.text
                            font.pixelSize: Style.fontSizeSmall
                            color: modelData.dangerous && area.containsMouse && modelData.enabled ? Style.error : Style.surfaceText
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: area
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: modelData.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.action()
                    }
                }
            }
        }
    }
}
