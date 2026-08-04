import QtQuick
import Quickshell.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: delegateRoot

    required property bool fileIsDir
    required property string filePath
    required property string fileName
    required property int index

    property bool weMode: false
    property var iconSizes: [80, 120, 160, 200]
    property int iconSizeIndex: 1
    property int selectedIndex: -1
    property bool keyboardNavigationActive: false

    signal itemClicked(int index, string path, string name, bool isDir)
    signal itemSelected(int index, string path, string name, bool isDir)
    signal itemContextMenuRequested(var sender, real localX, real localY, string path, string name, bool isDir)

    function getFileExtension(fileName) {
        const parts = fileName.split('.');
        if (parts.length > 1) {
            return parts[parts.length - 1].toLowerCase();
        }
        return "";
    }

    function determineFileType(fileName) {
        const ext = getFileExtension(fileName);

        const imageExts = ["png", "jpg", "jpeg", "gif", "bmp", "webp", "svg", "ico", "jxl", "avif", "heif", "exr"];
        if (imageExts.includes(ext)) {
            return "image";
        }

        const videoExts = ["mp4", "mkv", "avi", "mov", "webm", "flv", "wmv", "m4v"];
        if (videoExts.includes(ext)) {
            return "video";
        }

        const audioExts = ["mp3", "wav", "flac", "ogg", "m4a", "aac", "wma"];
        if (audioExts.includes(ext)) {
            return "audio";
        }

        const codeExts = ["js", "ts", "jsx", "tsx", "py", "go", "rs", "c", "cpp", "h", "java", "kt", "swift", "rb", "php", "html", "css", "scss", "json", "xml", "yaml", "yml", "toml", "sh", "bash", "zsh", "fish", "qml", "vue", "svelte"];
        if (codeExts.includes(ext)) {
            return "code";
        }

        const docExts = ["txt", "md", "pdf", "doc", "docx", "odt", "rtf"];
        if (docExts.includes(ext)) {
            return "document";
        }

        const archiveExts = ["zip", "tar", "gz", "bz2", "xz", "7z", "rar"];
        if (archiveExts.includes(ext)) {
            return "archive";
        }

        if (!ext || fileName.indexOf('.') === -1) {
            return "binary";
        }

        return "file";
    }

    function isImageFile(fileName) {
        if (!fileName) {
            return false;
        }
        return determineFileType(fileName) === "image";
    }

    function isVideoFile(fileName) {
        if (!fileName) {
            return false;
        }
        return determineFileType(fileName) === "video";
    }

    property bool isImage: isImageFile(delegateRoot.fileName)
    property bool isVideo: isVideoFile(delegateRoot.fileName)

    property string _xdgCacheHome: Paths.strip(Paths.xdgCache)
    property string _thumbnailSize: iconSizeIndex >= 2 ? "x-large" : "large"
    property int _thumbnailPx: iconSizeIndex >= 2 ? 512 : 256
    property string videoThumbnailPath: {
        if (!delegateRoot.fileIsDir && isVideo) {
            const hash = Qt.md5("file://" + delegateRoot.filePath);
            return _xdgCacheHome + "/thumbnails/" + _thumbnailSize + "/" + hash + ".png";
        }
        return "";
    }

    property string _videoThumb: ""
    property bool _thumbGenAttempted: false

    // Probe the thumbnail optimistically; Image.Error triggers generation
    onVideoThumbnailPathChanged: {
        _thumbGenAttempted = false;
        _videoThumb = videoThumbnailPath;
    }

    function generateVideoThumbnail() {
        if (_thumbGenAttempted)
            return;
        _thumbGenAttempted = true;
        _videoThumb = "";
        const thumbPath = videoThumbnailPath;
        const thumbDir = _xdgCacheHome + "/thumbnails/" + _thumbnailSize;
        const script = "mkdir -p \"$1\" && ffmpegthumbnailer -i \"$2\" -o \"$3\" -s " + _thumbnailPx + " -f";
        Proc.runCommand(null, ["sh", "-c", script, "thumb", thumbDir, delegateRoot.filePath, thumbPath], function (output, exitCode) {
            if (exitCode === 0)
                _videoThumb = thumbPath;
        });
    }

    function getIconForFile(fileName) {
        const lowerName = fileName.toLowerCase();
        if (lowerName.startsWith("dockerfile")) {
            return "docker";
        }
        const ext = fileName.split('.').pop();
        return ext || "";
    }

    width: weMode ? 245 : iconSizes[iconSizeIndex] + 16
    height: weMode ? 205 : iconSizes[iconSizeIndex] + 48
    radius: Style.cornerRadius
    color: {
        if (keyboardNavigationActive && delegateRoot.index === selectedIndex)
            return Style.surfacePressed;

        return mouseArea.containsMouse ? Style.withAlpha(Style.surfaceContainerHigh, Style.popupTransparency) : Style.withAlpha(Style.surfaceContainerHigh, 0);
    }
    border.color: keyboardNavigationActive && delegateRoot.index === selectedIndex ? Style.primary : Style.withAlpha(Style.primary, 0)
    border.width: (keyboardNavigationActive && delegateRoot.index === selectedIndex) ? 2 : 0

    Component.onCompleted: {
        if (keyboardNavigationActive && delegateRoot.index === selectedIndex)
            itemSelected(delegateRoot.index, delegateRoot.filePath, delegateRoot.fileName, delegateRoot.fileIsDir);
    }

    onSelectedIndexChanged: {
        if (keyboardNavigationActive && selectedIndex === delegateRoot.index)
            itemSelected(delegateRoot.index, delegateRoot.filePath, delegateRoot.fileName, delegateRoot.fileIsDir);
    }

    Column {
        anchors.centerIn: parent
        spacing: Style.spacingS

        Item {
            width: weMode ? 225 : (iconSizes[iconSizeIndex] - 8)
            height: weMode ? 165 : (iconSizes[iconSizeIndex] - 8)
            anchors.horizontalCenter: parent.horizontalCenter

            ClippingRectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: Style.cornerRadius
                color: "transparent"

                Image {
                    id: gridPreviewImage
                    anchors.fill: parent
                    property var weExtensions: [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".tga", ".jxl", ".avif", ".heif", ".exr"]
                    property int weExtIndex: 0
                    property string imagePath: {
                        if (weMode && delegateRoot.fileIsDir)
                            return delegateRoot.filePath + "/preview" + weExtensions[weExtIndex];
                        if (_videoThumb)
                            return _videoThumb;
                        return "";
                    }
                    source: imagePath ? "file://" + imagePath.split('/').map(s => encodeURIComponent(s)).join('/') : ""
                    onStatusChanged: {
                        if (status !== Image.Error)
                            return;
                        if (weMode && delegateRoot.fileIsDir) {
                            if (weExtIndex < weExtensions.length - 1) {
                                weExtIndex++;
                            } else {
                                imagePath = "";
                            }
                            return;
                        }
                        if (_videoThumb)
                            generateVideoThumbnail();
                    }
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: weMode ? 225 : iconSizes[iconSizeIndex]
                    sourceSize.height: weMode ? 225 : iconSizes[iconSizeIndex]
                    asynchronous: true
                    visible: status === Image.Ready && ((!delegateRoot.fileIsDir && isVideo) || (weMode && delegateRoot.fileIsDir))
                }

                CachingImage {
                    anchors.fill: parent
                    imagePath: !delegateRoot.fileIsDir && isImage ? delegateRoot.filePath : ""
                    maxCacheSize: 256
                    animate: false
                    visible: !delegateRoot.fileIsDir && isImage
                }
            }

            DankNFIcon {
                anchors.centerIn: parent
                name: delegateRoot.fileIsDir ? "folder" : getIconForFile(delegateRoot.fileName)
                size: iconSizes[iconSizeIndex] * 0.45
                color: delegateRoot.fileIsDir ? Style.primary : Style.surfaceText
                visible: (!delegateRoot.fileIsDir && !isImage && !(isVideo && gridPreviewImage.status === Image.Ready)) || (delegateRoot.fileIsDir && !weMode)
            }
        }

        StyledText {
            text: delegateRoot.fileName || ""
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceText
            width: delegateRoot.width - Style.spacingM
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            maximumLineCount: 2
            wrapMode: Text.Wrap
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            switch (mouse.button) {
            case Qt.LeftButton:
                itemClicked(delegateRoot.index, delegateRoot.filePath, delegateRoot.fileName, delegateRoot.fileIsDir);
                break;
            case Qt.RightButton:
                itemContextMenuRequested(delegateRoot, mouse.x, mouse.y, delegateRoot.filePath, delegateRoot.fileName, delegateRoot.fileIsDir);
                break;
            }
        }
    }
}
