import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

FocusScope {
    id: root

    property var editingApp: null
    property string editAppId: ""

    signal closeRequested

    function loadOverride() {
        var existing = SessionData.getAppOverride(editAppId);
        editNameField.text = existing?.name || "";
        editIconField.text = existing?.icon || "";
        editCommentField.text = existing?.comment || "";
        editEnvVarsField.text = existing?.envVars || "";
        editExtraFlagsField.text = existing?.extraFlags || "";
        Qt.callLater(() => editNameField.forceActiveFocus());
    }

    function saveAppOverride() {
        var override = {};
        if (editNameField.text.trim())
            override.name = editNameField.text.trim();
        if (editIconField.text.trim())
            override.icon = editIconField.text.trim();
        if (editCommentField.text.trim())
            override.comment = editCommentField.text.trim();
        if (editEnvVarsField.text.trim())
            override.envVars = editEnvVarsField.text.trim();
        if (editExtraFlagsField.text.trim())
            override.extraFlags = editExtraFlagsField.text.trim();
        SessionData.setAppOverride(editAppId, override);
        closeRequested();
    }

    function resetAppOverride() {
        SessionData.clearAppOverride(editAppId);
        closeRequested();
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            closeRequested();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (event.modifiers & Qt.ControlModifier) {
                saveAppOverride();
                event.accepted = true;
            }
        } else if (event.key === Qt.Key_S && event.modifiers & Qt.ControlModifier) {
            saveAppOverride();
            event.accepted = true;
        }
    }

    Column {
        anchors.fill: parent
        spacing: Theme.spacingM

        Row {
            width: parent.width
            spacing: Theme.spacingM

            Rectangle {
                width: 40
                height: 40
                radius: Theme.cornerRadius
                color: backButtonArea.containsMouse ? Theme.surfaceHover : Theme.withAlpha(Theme.surfaceHover, 0)

                DankIcon {
                    anchors.centerIn: parent
                    name: "arrow_back"
                    size: 20
                    color: Theme.surfaceText
                }

                MouseArea {
                    id: backButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }

            Image {
                width: 40
                height: 40
                source: Paths.resolveIconUrl(root.editingApp?.icon || "application-x-executable")
                sourceSize.width: 40
                sourceSize.height: 40
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacingXXS

                StyledText {
                    text: I18n.tr("Edit App")
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                }

                StyledText {
                    text: root.editingApp?.name || ""
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.outlineMedium
        }

        Flickable {
            width: parent.width
            height: parent.height - y - buttonsRow.height - Theme.spacingM
            contentHeight: editFieldsColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: editFieldsColumn
                width: parent.width
                spacing: Theme.spacingS

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        text: I18n.tr("Name")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    DankTextField {
                        id: editNameField
                        width: parent.width
                        placeholderText: root.editingApp?.name || ""
                        keyNavigationTab: editIconField
                        keyNavigationBacktab: editExtraFlagsField
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        text: I18n.tr("Icon")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    DankTextField {
                        id: editIconField
                        width: parent.width
                        placeholderText: root.editingApp?.icon || ""
                        keyNavigationTab: editCommentField
                        keyNavigationBacktab: editNameField
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        text: I18n.tr("Description")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    DankTextField {
                        id: editCommentField
                        width: parent.width
                        placeholderText: root.editingApp?.comment || ""
                        keyNavigationTab: editEnvVarsField
                        keyNavigationBacktab: editIconField
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        text: I18n.tr("Environment Variables")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: "KEY=value KEY2=value2"
                        font.pixelSize: Theme.fontSizeSmall - 1
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: editEnvVarsField
                        width: parent.width
                        placeholderText: "VAR=value"
                        keyNavigationTab: editExtraFlagsField
                        keyNavigationBacktab: editCommentField
                    }
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingXS

                    StyledText {
                        text: I18n.tr("Extra Arguments")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    DankTextField {
                        id: editExtraFlagsField
                        width: parent.width
                        placeholderText: "--flag --option=value"
                        keyNavigationTab: editNameField
                        keyNavigationBacktab: editEnvVarsField
                    }
                }
            }
        }

        Row {
            id: buttonsRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.spacingM

            Rectangle {
                id: resetButton
                width: 90
                height: 40
                radius: Theme.cornerRadius
                color: resetButtonArea.containsMouse ? Theme.surfacePressed : Theme.surfaceVariantAlpha
                visible: SessionData.getAppOverride(root.editAppId) !== null

                StyledText {
                    text: I18n.tr("Reset")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.error
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: resetButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.resetAppOverride()
                }
            }

            Rectangle {
                id: cancelButton
                width: 90
                height: 40
                radius: Theme.cornerRadius
                color: cancelButtonArea.containsMouse ? Theme.surfacePressed : Theme.surfaceVariantAlpha

                StyledText {
                    text: I18n.tr("Cancel")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: cancelButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }

            Rectangle {
                id: saveButton
                width: 90
                height: 40
                radius: Theme.cornerRadius
                color: saveButtonArea.containsMouse ? Theme.withAlpha(Theme.primary, 0.9) : Theme.primary

                StyledText {
                    text: I18n.tr("Save")
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.primaryText
                    font.weight: Font.Medium
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: saveButtonArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveAppOverride()
                }
            }
        }
    }
}
