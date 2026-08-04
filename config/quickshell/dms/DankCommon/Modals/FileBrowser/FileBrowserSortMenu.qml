import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: sortMenu

    property string sortBy: "name"
    property bool sortAscending: true
    property color surfaceColor: Style.surfaceContainer

    signal sortBySelected(string value)
    signal sortOrderSelected(bool ascending)

    width: 200
    height: sortColumn.height + Style.spacingM * 2
    color: surfaceColor
    radius: Style.cornerRadius
    border.color: Style.outlineMedium
    border.width: 1
    visible: false
    z: 100

    Column {
        id: sortColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Style.spacingM
        spacing: Style.spacingXS

        StyledText {
            text: I18n.tr("Sort By", "file browser sort menu section header")
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceTextMedium
            font.weight: Font.Medium
        }

        Repeater {
            model: [
                {
                    "name": I18n.tr("Name", "file browser sort criterion option"),
                    "value": "name"
                },
                {
                    "name": I18n.tr("Size", "file browser sort criterion option"),
                    "value": "size"
                },
                {
                    "name": I18n.tr("Modified", "file browser sort criterion option"),
                    "value": "modified"
                },
                {
                    "name": I18n.tr("Type", "file browser sort criterion option"),
                    "value": "type"
                }
            ]

            StyledRect {
                width: sortColumn?.width ?? 0
                height: 32
                radius: Style.cornerRadius
                color: sortMouseArea.containsMouse ? Style.surfaceVariant : (sortBy === modelData?.value ? Style.surfacePressed : Style.withAlpha(Style.surfacePressed, 0))

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Style.spacingS
                    spacing: Style.spacingS

                    DankIcon {
                        name: sortBy === modelData?.value ? "check" : ""
                        size: Style.iconSizeSmall
                        color: Style.primary
                        anchors.verticalCenter: parent.verticalCenter
                        visible: sortBy === modelData?.value
                    }

                    StyledText {
                        text: modelData?.name ?? ""
                        font.pixelSize: Style.fontSizeMedium
                        color: sortBy === modelData?.value ? Style.primary : Style.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: sortMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sortMenu.sortBySelected(modelData?.value ?? "name");
                        sortMenu.visible = false;
                    }
                }
            }
        }

        StyledRect {
            width: sortColumn.width
            height: 1
            color: Style.outline
        }

        StyledText {
            text: I18n.tr("Order", "file browser sort menu section header")
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceTextMedium
            font.weight: Font.Medium
            topPadding: Style.spacingXS
        }

        StyledRect {
            width: sortColumn?.width ?? 0
            height: 32
            radius: Style.cornerRadius
            color: ascMouseArea.containsMouse ? Style.surfaceVariant : (sortAscending ? Style.surfacePressed : Style.withAlpha(Style.surfacePressed, 0))

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.spacingS
                spacing: Style.spacingS

                DankIcon {
                    name: "arrow_upward"
                    size: Style.iconSizeSmall
                    color: sortAscending ? Style.primary : Style.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: I18n.tr("Ascending", "file browser sort order option")
                    font.pixelSize: Style.fontSizeMedium
                    color: sortAscending ? Style.primary : Style.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: ascMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sortMenu.sortOrderSelected(true);
                    sortMenu.visible = false;
                }
            }
        }

        StyledRect {
            width: sortColumn?.width ?? 0
            height: 32
            radius: Style.cornerRadius
            color: descMouseArea.containsMouse ? Style.surfaceVariant : (!sortAscending ? Style.surfacePressed : Style.withAlpha(Style.surfacePressed, 0))

            Row {
                anchors.fill: parent
                anchors.leftMargin: Style.spacingS
                spacing: Style.spacingS

                DankIcon {
                    name: "arrow_downward"
                    size: Style.iconSizeSmall
                    color: !sortAscending ? Style.primary : Style.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: I18n.tr("Descending", "file browser sort order option")
                    font.pixelSize: Style.fontSizeMedium
                    color: !sortAscending ? Style.primary : Style.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: descMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sortMenu.sortOrderSelected(false);
                    sortMenu.visible = false;
                }
            }
        }
    }
}
