import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Row {
    id: saveRow

    property bool saveMode: false
    property bool folderMode: false
    property string defaultFileName: ""
    property string currentPath: ""
    property alias fileName: fileNameInput.text

    signal saveRequested(string filePath)
    signal folderSelected(string folderPath)

    height: (saveMode || folderMode) ? 40 : 0
    visible: saveMode || folderMode
    spacing: Style.spacingM

    DankTextField {
        id: fileNameInput

        visible: saveRow.saveMode
        width: parent.width - saveButton.width - Style.spacingM
        height: 40
        text: defaultFileName
        placeholderText: I18n.tr("Enter filename...", "file browser save filename input placeholder")
        ignoreLeftRightKeys: false
        focus: saveMode
        topPadding: Style.spacingS
        bottomPadding: Style.spacingS
        Component.onCompleted: {
            if (saveMode)
                Qt.callLater(() => {
                    forceActiveFocus();
                });
        }
        onAccepted: {
            if (text.trim() !== "") {
                var basePath = currentPath.replace(/^file:\/\//, '');
                var fullPath = basePath + "/" + text.trim();
                fullPath = fullPath.replace(/\/+/g, '/');
                saveRequested(fullPath);
            }
        }
    }

    StyledRect {
        id: saveButton

        visible: saveRow.saveMode
        width: 80
        height: 40
        color: fileNameInput.text.trim() !== "" ? Style.primary : Style.surfaceVariant
        radius: Style.cornerRadius

        StyledText {
            anchors.centerIn: parent
            text: I18n.tr("Save", "file browser save button")
            color: fileNameInput.text.trim() !== "" ? Style.primaryText : Style.surfaceVariantText
            font.pixelSize: Style.fontSizeMedium
        }

        StateLayer {
            stateColor: Style.primary
            cornerRadius: Style.cornerRadius
            enabled: fileNameInput.text.trim() !== ""
            onClicked: {
                if (fileNameInput.text.trim() !== "") {
                    var basePath = currentPath.replace(/^file:\/\//, '');
                    var fullPath = basePath + "/" + fileNameInput.text.trim();
                    fullPath = fullPath.replace(/\/+/g, '/');
                    saveRequested(fullPath);
                }
            }
        }
    }

    StyledRect {
        id: useFolderButton

        visible: saveRow.folderMode
        width: parent.width
        height: 40
        color: Style.primary
        radius: Style.cornerRadius

        Row {
            anchors.centerIn: parent
            spacing: Style.spacingS

            DankIcon {
                name: "check"
                size: Style.iconSize - 4
                color: Style.primaryText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: I18n.tr("Use this folder", "file browser folder selection confirm button")
                color: Style.primaryText
                font.pixelSize: Style.fontSizeMedium
                font.weight: Font.Medium
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        StateLayer {
            stateColor: Style.primaryText
            cornerRadius: Style.cornerRadius
            onClicked: {
                var basePath = currentPath.replace(/^file:\/\//, '');
                saveRow.folderSelected(basePath);
            }
        }
    }
}
