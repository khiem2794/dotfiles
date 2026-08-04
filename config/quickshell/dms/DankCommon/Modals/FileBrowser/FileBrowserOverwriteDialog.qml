import QtQuick
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Item {
    id: overwriteDialog

    property bool showDialog: false
    property string pendingFilePath: ""

    signal confirmed(string filePath)
    signal cancelled

    visible: showDialog
    focus: showDialog

    Keys.onEscapePressed: {
        cancelled();
    }

    Keys.onReturnPressed: {
        confirmed(pendingFilePath);
    }

    Rectangle {
        anchors.fill: parent
        color: Style.shadowStrong
        opacity: 0.8

        MouseArea {
            anchors.fill: parent
            onClicked: {
                cancelled();
            }
        }
    }

    StyledRect {
        anchors.centerIn: parent
        width: 400
        height: 160
        color: Style.surfaceContainer
        radius: Style.cornerRadius
        border.color: Style.outlineMedium
        border.width: 1

        Column {
            anchors.centerIn: parent
            width: parent.width - Style.spacingL * 2
            spacing: Style.spacingM

            StyledText {
                text: I18n.tr("File Already Exists", "file browser overwrite dialog title")
                font.pixelSize: Style.fontSizeLarge
                font.weight: Font.Medium
                color: Style.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: I18n.tr("A file with this name already exists. Do you want to overwrite it?", "file browser overwrite dialog message")
                font.pixelSize: Style.fontSizeMedium
                color: Style.surfaceTextMedium
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Style.spacingM

                StyledRect {
                    width: 80
                    height: 36
                    radius: Style.cornerRadius
                    color: cancelArea.containsMouse ? Qt.lighter(Style.surfaceVariant, 1.2) : Style.surfaceVariant
                    border.color: Style.outline
                    border.width: 1

                    StyledText {
                        anchors.centerIn: parent
                        text: I18n.tr("Cancel", "file browser overwrite dialog cancel button")
                        font.pixelSize: Style.fontSizeMedium
                        color: Style.surfaceText
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: cancelArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cancelled();
                        }
                    }
                }

                StyledRect {
                    width: 90
                    height: 36
                    radius: Style.cornerRadius
                    color: overwriteArea.containsMouse ? Qt.darker(Style.primary, 1.1) : Style.primary

                    StyledText {
                        anchors.centerIn: parent
                        text: I18n.tr("Overwrite", "file browser overwrite dialog confirm button")
                        font.pixelSize: Style.fontSizeMedium
                        color: Style.background
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: overwriteArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            confirmed(pendingFilePath);
                        }
                    }
                }
            }
        }
    }
}
