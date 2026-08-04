import QtQuick
import Quickshell.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Widgets

StyledRect {
    id: listDelegateRoot

    required property bool fileIsDir
    required property string filePath
    required property string fileName
    required property int index
    required property var fileModified
    required property int fileSize

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

    property bool isImage: isImageFile(listDelegateRoot.fileName)
    property bool isVideo: isVideoFile(listDelegateRoot.fileName)

    property string _xdgCacheHome: Paths.strip(Paths.xdgCache)
    property string videoThumbnailPath: {
        if (!listDelegateRoot.fileIsDir && isVideo) {
            const hash = Qt.md5("file://" + listDelegateRoot.filePath);
            return _xdgCacheHome + "/thumbnails/normal/" + hash + ".png";
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
        const thumbDir = _xdgCacheHome + "/thumbnails/normal";
        const script = "mkdir -p \"$1\" && ffmpegthumbnailer -i \"$2\" -o \"$3\" -s 128 -f";
        Proc.runCommand(null, ["sh", "-c", script, "thumb", thumbDir, listDelegateRoot.filePath, thumbPath], function (output, exitCode) {
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

    function formatFileSize(size) {
        if (size < 1024)
            return size + " B";
        if (size < 1024 * 1024)
            return (size / 1024).toFixed(1) + " KB";
        if (size < 1024 * 1024 * 1024)
            return (size / (1024 * 1024)).toFixed(1) + " MB";
        return (size / (1024 * 1024 * 1024)).toFixed(1) + " GB";
    }

    height: 44
    radius: Style.cornerRadius
    color: {
        if (keyboardNavigationActive && listDelegateRoot.index === selectedIndex)
            return Style.surfacePressed;
        return listMouseArea.containsMouse ? Style.withAlpha(Style.surfaceContainerHigh, Style.popupTransparency) : Style.withAlpha(Style.surfaceContainerHigh, 0);
    }
    border.color: keyboardNavigationActive && listDelegateRoot.index === selectedIndex ? Style.primary : Style.withAlpha(Style.primary, 0)
    border.width: (keyboardNavigationActive && listDelegateRoot.index === selectedIndex) ? 2 : 0

    Component.onCompleted: {
        if (keyboardNavigationActive && listDelegateRoot.index === selectedIndex)
            itemSelected(listDelegateRoot.index, listDelegateRoot.filePath, listDelegateRoot.fileName, listDelegateRoot.fileIsDir);
    }

    onSelectedIndexChanged: {
        if (keyboardNavigationActive && selectedIndex === listDelegateRoot.index)
            itemSelected(listDelegateRoot.index, listDelegateRoot.filePath, listDelegateRoot.fileName, listDelegateRoot.fileIsDir);
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Style.spacingS
        anchors.rightMargin: Style.spacingS
        spacing: Style.spacingS

        Item {
            width: 28
            height: 28
            anchors.verticalCenter: parent.verticalCenter

            ClippingRectangle {
                anchors.fill: parent
                radius: Style.cornerRadius
                color: "transparent"

                Image {
                    id: listPreviewImage
                    anchors.fill: parent
                    property string imagePath: _videoThumb
                    source: imagePath ? "file://" + imagePath.split('/').map(s => encodeURIComponent(s)).join('/') : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 32
                    sourceSize.height: 32
                    asynchronous: true
                    visible: status === Image.Ready && !listDelegateRoot.fileIsDir && isVideo
                    onStatusChanged: {
                        if (status === Image.Error && _videoThumb)
                            generateVideoThumbnail();
                    }
                }

                CachingImage {
                    anchors.fill: parent
                    imagePath: !listDelegateRoot.fileIsDir && isImage ? listDelegateRoot.filePath : ""
                    maxCacheSize: 256
                    animate: false
                    visible: !listDelegateRoot.fileIsDir && isImage
                }
            }

            DankNFIcon {
                anchors.centerIn: parent
                name: listDelegateRoot.fileIsDir ? "folder" : getIconForFile(listDelegateRoot.fileName)
                size: Style.iconSize - 2
                color: listDelegateRoot.fileIsDir ? Style.primary : Style.surfaceText
                visible: listDelegateRoot.fileIsDir || (!isImage && !(isVideo && listPreviewImage.status === Image.Ready))
            }
        }

        StyledText {
            text: listDelegateRoot.fileName || ""
            font.pixelSize: Style.fontSizeMedium
            color: Style.surfaceText
            width: parent.width - 280
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
            maximumLineCount: 1
            clip: true
        }

        StyledText {
            text: listDelegateRoot.fileIsDir ? "" : formatFileSize(listDelegateRoot.fileSize)
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceTextMedium
            width: 70
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: Qt.formatDateTime(listDelegateRoot.fileModified, "MMM d, yyyy h:mm AP")
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceTextMedium
            width: 140
            horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: listMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            switch (mouse.button) {
            case Qt.LeftButton:
                itemClicked(listDelegateRoot.index, listDelegateRoot.filePath, listDelegateRoot.fileName, listDelegateRoot.fileIsDir);
                break;
            case Qt.RightButton:
                itemContextMenuRequested(listDelegateRoot, mouse.x, mouse.y, listDelegateRoot.filePath, listDelegateRoot.fileName, listDelegateRoot.fileIsDir);
                break;
            }
        }
    }
}
