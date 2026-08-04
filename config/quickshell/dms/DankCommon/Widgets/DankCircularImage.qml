import QtQuick
import QtQuick.Window
import Quickshell.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property string imageSource: ""
    property string fallbackIcon: "notifications"
    property string fallbackText: ""
    property bool cacheImages: true
    property bool hasImage: imageSource !== ""
    readonly property bool shouldProbe: imageSource !== "" && !imageSource.startsWith("image://")
    readonly property bool isAnimated: shouldProbe && probe.status === Image.Ready && probe.frameCount > 1
    readonly property bool probeSettled: probe.status === Image.Ready || probe.status === Image.Error
    readonly property var activeImage: {
        if (isAnimated)
            return probe;
        if (staticImage.status === Image.Ready)
            return staticImage;
        if (probe.status === Image.Ready && probe.source !== "")
            return probe;
        return staticImage;
    }
    property int imageStatus: activeImage.status

    signal imageSaved(string filePath)

    property string _pendingSavePath: ""
    property var _attachedWindow: root.Window.window

    on_AttachedWindowChanged: {
        if (_attachedWindow && _pendingSavePath !== "") {
            Qt.callLater(function () {
                if (root._pendingSavePath !== "") {
                    let path = root._pendingSavePath;
                    root._pendingSavePath = "";
                    root.saveImageToFile(path);
                }
            });
        }
    }

    function saveImageToFile(filePath) {
        if (activeImage.status !== Image.Ready)
            return false;

        if (!activeImage.Window.window) {
            _pendingSavePath = filePath;
            return true;
        }

        activeImage.grabToImage(function (result) {
            if (result && result.saveToFile(filePath)) {
                root.imageSaved(filePath);
            }
        });
        return true;
    }

    radius: width / 2
    color: Style.primaryHover
    border.color: "transparent"
    border.width: 0

    ClippingRectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: Math.min(width, height) / 2
        color: "transparent"

        // Probes as AnimatedImage to read frameCount; retires once staticImage is ready.
        AnimatedImage {
            id: probe
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            cache: root.cacheImages
            visible: root.activeImage === probe && probe.status === Image.Ready && root.imageSource !== ""
            source: root.shouldProbe && (root.isAnimated || staticImage.status !== Image.Ready) ? root.imageSource : ""
        }

        // Takes over once the probe settles on a non-animated image, then latches.
        Image {
            id: staticImage
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            cache: root.cacheImages
            visible: root.activeImage === staticImage && staticImage.status === Image.Ready && root.imageSource !== ""
            sourceSize.width: Math.max(width * 2, 128)
            sourceSize.height: Math.max(height * 2, 128)
            source: {
                if (!root.shouldProbe)
                    return root.imageSource;
                if ((root.probeSettled && !root.isAnimated) || staticImage.status !== Image.Null)
                    return root.imageSource;
                return "";
            }
        }
    }

    AppIconRenderer {
        anchors.centerIn: parent
        width: Math.round(parent.width * 0.75)
        height: width
        visible: (root.activeImage.status !== Image.Ready || root.imageSource === "") && root.fallbackIcon !== ""
        iconValue: root.fallbackIcon
        iconSize: width
        iconColor: Style.surfaceVariantText
        materialIconSizeAdjustment: 0
        fallbackText: root.fallbackText
        fallbackBackgroundColor: "transparent"
        fallbackTextColor: Style.surfaceVariantText
    }

    StyledText {
        anchors.centerIn: parent
        visible: root.imageSource === "" && root.fallbackIcon === "" && root.fallbackText !== ""
        text: root.fallbackText
        font.pixelSize: Math.max(12, parent.width * 0.5)
        font.weight: Font.Bold
        color: Style.surfaceVariantText
    }
}
