import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    property var device: null
    property bool modalVisible: false
    property var parentItem
    property var availableCodecs: []
    property string currentCodec: ""
    property bool isLoading: false
    property string statusMessage: ""
    property bool statusIsError: false

    readonly property var mediaCodecs: availableCodecs.filter(c => (c.category || "media") !== "call")
    readonly property var callCodecs: availableCodecs.filter(c => c.category === "call")
    readonly property bool deviceValid: device !== null && device.connected && BluetoothService.isAudioDevice(device)

    signal codecSelected(string deviceAddress, string codecName)

    function show(bluetoothDevice) {
        if (!bluetoothDevice?.connected)
            return;
        if (!BluetoothService.isAudioDevice(bluetoothDevice))
            return;
        device = bluetoothDevice;
        isLoading = true;
        availableCodecs = [];
        currentCodec = "";
        statusMessage = "";
        statusIsError = false;
        visible = true;
        modalVisible = true;
        queryCodecs();
        Qt.callLater(() => {
            focusScope.forceActiveFocus();
        });
    }

    function hide() {
        modalVisible = false;
        Qt.callLater(() => {
            visible = false;
            device = null;
        });
    }

    function queryCodecs() {
        if (!deviceValid) {
            hide();
            return;
        }

        const capturedDevice = device;
        const capturedAddress = device.address;

        BluetoothService.getAvailableCodecs(capturedDevice, function (codecs, current) {
            if (!root.deviceValid || root.device?.address !== capturedAddress)
                return;
            availableCodecs = codecs;
            currentCodec = current;
            isLoading = false;
            if (BluetoothService.wpexecChecked && !BluetoothService.wpexecAvailable && !BluetoothService.dbusBridgeAvailable) {
                statusMessage = I18n.tr("Codec switching is unavailable because WirePlumber was not found");
                statusIsError = true;
            } else if (codecs.length === 0) {
                statusMessage = I18n.tr("No codecs found");
                statusIsError = false;
            } else {
                statusMessage = "";
                statusIsError = false;
            }
        });
    }

    function selectCodec(profileName) {
        if (!deviceValid || isLoading)
            return;

        const capturedDevice = device;
        const capturedAddress = device.address;

        const selectedCodec = availableCodecs.find(c => c.profile === profileName);
        if (!selectedCodec)
            return;

        BluetoothService.updateDeviceCodec(capturedAddress, selectedCodec.name);
        codecSelected(capturedAddress, selectedCodec.name);

        isLoading = true;
        BluetoothService.switchCodec(capturedDevice, profileName, function (success, message) {
            if (!root.device || root.device.address !== capturedAddress)
                return;

            isLoading = false;
            if (success) {
                BluetoothService.updateDeviceCodec(capturedAddress, selectedCodec.name);
                codecSelected(capturedAddress, selectedCodec.name);
                ToastService.showToast(message, ToastService.levelInfo);
                Qt.callLater(root.hide);
                return;
            }
            ToastService.showToast(message, ToastService.levelError);
        }, selectedCodec.name);
    }

    onDeviceValidChanged: {
        if (modalVisible && !deviceValid) {
            hide();
        }
    }

    visible: false
    anchors.fill: parent
    z: 2000

    MouseArea {
        id: modalBlocker
        anchors.fill: parent
        visible: modalVisible
        enabled: modalVisible
        hoverEnabled: true
        preventStealing: true
        propagateComposedEvents: false

        onClicked: root.hide()
        onWheel: wheel => {
            wheel.accepted = true;
        }
        onPositionChanged: mouse => {
            mouse.accepted = true;
        }
    }

    Rectangle {
        id: modalBackground
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, BlurService.enabled ? 0.72 : 0.5)
        opacity: modalVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }
    }

    FocusScope {
        id: focusScope

        anchors.fill: parent
        focus: root.visible
        enabled: root.visible

        Keys.onEscapePressed: event => {
            root.hide();
            event.accepted = true;
        }
    }

    Rectangle {
        id: modalContent
        anchors.centerIn: parent
        width: 320
        height: contentColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.withAlpha(Theme.surfaceContainer, BlurService.enabled ? 0.96 : Theme.popupTransparency)
        border.color: BlurService.enabled ? BlurService.borderColor : Theme.outlineMedium
        border.width: BlurService.enabled ? BlurService.borderWidth : Theme.layerOutlineWidth
        opacity: modalVisible ? 1 : 0
        scale: modalVisible ? 1 : 0.9

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
            onClicked: mouse => {
                mouse.accepted = true;
            }
            onWheel: wheel => {
                wheel.accepted = true;
            }
            onPositionChanged: mouse => {
                mouse.accepted = true;
            }
        }

        Column {
            id: contentColumn

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                width: parent.width
                spacing: Theme.spacingM

                DankIcon {
                    name: device ? BluetoothService.getDeviceIcon(device) : "headset"
                    size: Theme.iconSize + 4
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingXXS

                    StyledText {
                        text: device ? (device.name || device.deviceName) : ""
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: I18n.tr("Audio Codec Selection")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceTextMedium
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.outlineLight
            }

            StyledText {
                text: {
                    if (isLoading)
                        return I18n.tr("Loading codecs...");
                    if (statusMessage.length > 0)
                        return statusMessage;
                    return I18n.tr("Current: %1").arg(currentCodec);
                }
                font.pixelSize: Theme.fontSizeSmall
                color: statusIsError ? Theme.error : (isLoading ? Theme.primary : Theme.surfaceTextMedium)
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS
                visible: !isLoading && availableCodecs.length > 0

                StyledText {
                    text: I18n.tr("Media")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceTextMedium
                    visible: root.mediaCodecs.length > 0 && root.callCodecs.length > 0
                    width: parent.width
                }

                Repeater {
                    model: root.mediaCodecs
                    delegate: codecRow
                }

                Item {
                    width: 1
                    height: Theme.spacingS
                    visible: root.mediaCodecs.length > 0 && root.callCodecs.length > 0
                }

                StyledText {
                    text: I18n.tr("Calls / Headset")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceTextMedium
                    visible: root.callCodecs.length > 0
                    width: parent.width
                }

                Repeater {
                    model: root.callCodecs
                    delegate: codecRow
                }
            }
        }

        Component {
            id: codecRow

            Rectangle {
                required property var modelData
                width: parent ? parent.width : 280
                height: 48
                radius: Theme.cornerRadius
                color: {
                    if (modelData.name === root.currentCodec)
                        return Theme.withAlpha(Theme.surfaceContainerHighest, Theme.popupTransparency);
                    if (codecMouseArea.containsMouse)
                        return Theme.surfaceHover;
                    return "transparent";
                }
                border.color: "transparent"
                border.width: 0

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingM
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacingS

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: modelData.qualityColor
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXXS

                        StyledText {
                            text: modelData.name
                            font.pixelSize: Theme.fontSizeMedium
                            color: modelData.name === root.currentCodec ? Theme.primary : Theme.surfaceText
                            font.weight: modelData.name === root.currentCodec ? Font.Medium : Font.Normal
                        }

                        StyledText {
                            text: modelData.description
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceTextMedium
                        }
                    }
                }

                DankIcon {
                    name: "check"
                    size: Theme.iconSize - 4
                    color: Theme.primary
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacingM
                    anchors.verticalCenter: parent.verticalCenter
                    visible: modelData.name === root.currentCodec
                }

                DankRipple {
                    id: codecRipple
                    cornerRadius: parent.radius
                }

                MouseArea {
                    id: codecMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: modelData.name !== root.currentCodec && !root.isLoading
                    onPressed: mouse => codecRipple.trigger(mouse.x, mouse.y)
                    onClicked: root.selectCodec(modelData.profile)
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.mediumDuration
                easing.type: Theme.emphasizedEasing
            }
        }
    }
}
