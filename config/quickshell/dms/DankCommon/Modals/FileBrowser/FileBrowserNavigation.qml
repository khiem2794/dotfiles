import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Row {
    id: navigation

    property string currentPath: ""
    property string homeDir: ""
    property bool backButtonFocused: false
    property bool keyboardNavigationActive: false
    property bool showSidebar: true
    property bool pathEditMode: false
    property bool pathInputHasFocus: false

    signal navigateUp
    signal navigateTo(string path)
    signal pathInputFocusChanged(bool hasFocus)

    height: 40
    leftPadding: Style.spacingM
    rightPadding: Style.spacingM
    spacing: Style.spacingS

    StyledRect {
        width: 32
        height: 32
        radius: Style.cornerRadius
        color: (backButtonMouseArea.containsMouse || (backButtonFocused && keyboardNavigationActive)) && currentPath !== homeDir ? Style.surfaceVariant : Style.withAlpha(Style.surfaceVariant, 0)
        opacity: currentPath !== homeDir ? 1 : 0
        anchors.verticalCenter: parent.verticalCenter

        DankIcon {
            anchors.centerIn: parent
            name: "arrow_back"
            size: Style.iconSizeSmall
            color: Style.surfaceText
        }

        MouseArea {
            id: backButtonMouseArea

            anchors.fill: parent
            hoverEnabled: currentPath !== homeDir
            cursorShape: currentPath !== homeDir ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: currentPath !== homeDir
            onClicked: navigation.navigateUp()
        }
    }

    Item {
        width: Math.max(0, (parent?.width ?? 0) - 40 - Style.spacingS - (showSidebar ? 0 : 80))
        height: 32
        anchors.verticalCenter: parent.verticalCenter

        StyledRect {
            anchors.fill: parent
            radius: Style.cornerRadius
            color: pathEditMode ? Style.withAlpha(Style.surfaceContainer, Style.popupTransparency) : Style.withAlpha(Style.surfaceContainer, 0)
            border.color: pathEditMode ? Style.primary : Style.withAlpha(Style.primary, 0)
            border.width: pathEditMode ? 1 : 0
            visible: !pathEditMode

            StyledText {
                id: pathDisplay
                text: currentPath.replace("file://", "")
                font.pixelSize: Style.fontSizeMedium
                color: Style.surfaceText
                font.weight: Font.Medium
                anchors.fill: parent
                anchors.leftMargin: Style.spacingS
                anchors.rightMargin: Style.spacingS
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 1
                wrapMode: Text.NoWrap
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: {
                    pathEditMode = true;
                    pathInput.text = currentPath.replace("file://", "");
                    Qt.callLater(() => pathInput.forceActiveFocus());
                }
            }
        }

        DankTextField {
            id: pathInput
            anchors.fill: parent
            visible: pathEditMode
            topPadding: Style.spacingXS
            bottomPadding: Style.spacingXS
            onAccepted: {
                const newPath = text.trim();
                if (newPath !== "") {
                    navigation.navigateTo(newPath);
                }
                pathEditMode = false;
            }
            Keys.onEscapePressed: {
                pathEditMode = false;
            }
            Keys.onDownPressed: {
                pathEditMode = false;
            }
            onActiveFocusChanged: {
                navigation.pathInputFocusChanged(activeFocus);
                if (!activeFocus && pathEditMode) {
                    pathEditMode = false;
                }
            }
        }
    }

    Row {
        spacing: Style.spacingXS
        visible: !showSidebar
        anchors.verticalCenter: parent.verticalCenter

        DankActionButton {
            circular: false
            iconName: "sort"
            iconSize: Style.iconSize - 6
            iconColor: Style.surfaceText
        }
    }
}
