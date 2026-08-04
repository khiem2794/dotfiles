import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: sidebar

    property var quickAccessLocations: []
    property string currentPath: ""
    signal locationSelected(string path)

    width: 200
    color: Style.nestedSurface
    clip: true

    Column {
        anchors.fill: parent
        anchors.margins: Style.spacingS
        spacing: Style.spacingXS

        StyledText {
            text: I18n.tr("Quick Access", "file browser sidebar section header")
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceTextMedium
            font.weight: Font.Medium
            leftPadding: Style.spacingS
            bottomPadding: Style.spacingXS
        }

        Repeater {
            model: quickAccessLocations

            StyledRect {
                width: parent?.width ?? 0
                height: 38
                radius: Style.cornerRadius
                color: quickAccessMouseArea.containsMouse ? Style.withAlpha(Style.surfaceContainerHigh, Style.popupTransparency) : (currentPath === modelData?.path ? Style.surfacePressed : Style.withAlpha(Style.surfacePressed, 0))

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.spacingM
                    spacing: Style.spacingS

                    DankIcon {
                        name: modelData?.icon ?? ""
                        size: Style.iconSize - 2
                        color: currentPath === modelData?.path ? Style.primary : Style.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: modelData?.name ?? ""
                        font.pixelSize: Style.fontSizeMedium
                        color: currentPath === modelData?.path ? Style.primary : Style.surfaceText
                        font.weight: currentPath === modelData?.path ? Font.Medium : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: quickAccessMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: locationSelected(modelData?.path ?? "")
                }
            }
        }
    }
}
