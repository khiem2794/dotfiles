import "../Common/fzf.js" as Fzf
import QtQuick
import QtQuick.Controls
import Quickshell
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Item {
    id: root

    LayoutMirroring.enabled: I18n.isRtl
    LayoutMirroring.childrenInherit: true

    function checkParentDisablesTransparency() {
        let p = parent;
        while (p) {
            if (p.disablePopupTransparency === true)
                return true;
            p = p.parent;
        }
        return false;
    }

    property string text: ""
    property string description: ""
    property string currentValue: ""
    property var options: []
    property var optionIcons: []
    property bool enableFuzzySearch: false
    property var optionIconMap: ({})
    property var optionColorMap: ({})

    function rebuildIconMap() {
        const map = {};
        for (let i = 0; i < options.length; i++) {
            if (optionIcons.length > i)
                map[options[i]] = optionIcons[i];
        }
        optionIconMap = map;
    }

    onOptionsChanged: rebuildIconMap()
    onOptionIconsChanged: rebuildIconMap()

    property int popupWidthOffset: 0
    property int maxPopupHeight: 400
    property bool openUpwards: false
    property int popupWidth: 0
    property bool alignPopupRight: false
    property int dropdownWidth: 200
    property bool compactMode: text === "" && description === ""
    property bool showTrigger: true
    property Item popupAnchorItem: null
    property bool addHorizontalPadding: false
    property string emptyText: ""
    property bool usePopupTransparency: !checkParentDisablesTransparency()
    property var transientSurfaceTracker: null

    signal valueChanged(string value)

    property bool menuOpen: false

    onMenuOpenChanged: transientSurfaceTracker?.setActive(root, menuOpen, null)

    function closeDropdownMenu() {
        if (!root.menuOpen && !dropdownMenu.opened && !dropdownMenu.visible)
            return;
        root.menuOpen = false;
        dropdownMenu.close();
    }

    function positionDropdownMenu() {
        let currentIndex = root.options.indexOf(root.currentValue);
        listView.positionViewAtIndex(currentIndex >= 0 ? currentIndex : 0, ListView.Beginning);

        const anchorItem = root.popupAnchorItem || dropdown;
        const pos = anchorItem.mapToItem(Overlay.overlay, 0, 0);
        const popupW = dropdownMenu.width;
        const popupH = dropdownMenu.height;
        const overlayH = Overlay.overlay.height;
        const goUp = root.openUpwards || pos.y + anchorItem.height + popupH + 4 > overlayH;
        dropdownMenu.x = root.alignPopupRight ? pos.x + anchorItem.width - popupW : pos.x - (root.popupWidthOffset / 2);
        dropdownMenu.y = goUp ? pos.y - popupH - 4 : pos.y + anchorItem.height + 4;
    }

    function showDropdownMenu() {
        if (root.options.length === 0)
            return;
        if (root.menuOpen)
            return;

        root.menuOpen = true;
        dropdownMenu.open();
        positionDropdownMenu();

        if (root.enableFuzzySearch)
            searchField.forceActiveFocus();
    }

    function openDropdownMenu() {
        if (root.menuOpen) {
            closeDropdownMenu();
            return;
        }
        showDropdownMenu();
    }

    function resetSearch() {
        searchField.text = "";
        dropdownMenu.fzfFinder = null;
        dropdownMenu.searchQuery = "";
        dropdownMenu.selectedIndex = -1;
    }

    width: !showTrigger ? 0 : (compactMode ? dropdownWidth : parent.width)
    implicitHeight: !showTrigger ? 0 : (compactMode ? 40 : Math.max(60, labelColumn.implicitHeight + Style.spacingM))

    Component.onDestruction: {
        transientSurfaceTracker?.unregister(root);
        if (root.menuOpen || dropdownMenu.opened || dropdownMenu.visible)
            dropdownMenu.close();
    }

    Connections {
        target: root.transientSurfaceTracker
        ignoreUnknownSignals: true

        function onCloseRequested() {
            root.closeDropdownMenu();
        }
    }

    Column {
        id: labelColumn

        anchors.left: parent.left
        anchors.right: dropdown.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: root.addHorizontalPadding ? Style.spacingM : 0
        anchors.rightMargin: Style.spacingL
        spacing: Style.spacingXS
        visible: !root.compactMode && root.showTrigger

        StyledText {
            text: root.text
            font.pixelSize: Style.fontSizeMedium
            color: Style.surfaceText
            font.weight: Font.Medium
            width: parent.width
            horizontalAlignment: Text.AlignLeft
        }

        StyledText {
            text: root.description
            font.pixelSize: Style.fontSizeSmall
            color: Style.surfaceVariantText
            visible: description.length > 0
            wrapMode: Text.WordWrap
            width: parent.width
            horizontalAlignment: Text.AlignLeft
        }
    }

    Rectangle {
        id: dropdown

        visible: root.showTrigger
        width: root.compactMode ? parent.width : (root.popupWidth === -1 ? undefined : (root.popupWidth > 0 ? root.popupWidth : root.dropdownWidth))
        height: 40
        anchors.right: parent.right
        anchors.rightMargin: root.addHorizontalPadding && !root.compactMode ? Style.spacingM : 0
        anchors.verticalCenter: parent.verticalCenter
        radius: Style.cornerRadius
        color: dropdownArea.containsMouse || dropdownMenu.visible ? Style.surfaceContainerHigh : (root.usePopupTransparency ? Style.withAlpha(Style.surfaceContainer, Style.popupTransparency) : Style.surfaceContainer)
        border.color: dropdownMenu.visible ? Style.primary : Style.outlineHeavy
        border.width: dropdownMenu.visible ? 2 : 1

        MouseArea {
            id: dropdownArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openDropdownMenu()
        }

        Row {
            id: contentRow

            anchors.left: parent.left
            anchors.right: expandIcon.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.spacingM
            anchors.rightMargin: Style.spacingS
            spacing: Style.spacingS

            DankColorSwatch {
                id: triggerSwatch

                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter
                visible: root.optionColorMap[root.currentValue] !== undefined
                swatchColor: visible ? root.optionColorMap[root.currentValue] : "transparent"
            }

            DankIcon {
                id: triggerIcon

                name: root.optionIconMap[root.currentValue] ?? ""
                size: 18
                color: Style.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: name !== ""
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentValue !== "" ? root.currentValue : root.emptyText
                font.pixelSize: Style.fontSizeMedium
                color: root.currentValue !== "" ? Style.surfaceText : Style.outline
                width: contentRow.width - (triggerSwatch.visible ? triggerSwatch.width + contentRow.spacing : 0) - (triggerIcon.visible ? triggerIcon.width + contentRow.spacing : 0)
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                horizontalAlignment: Text.AlignLeft
            }
        }

        DankIcon {
            id: expandIcon

            name: dropdownMenu.visible ? "expand_less" : "expand_more"
            size: 20
            color: Style.surfaceText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Style.spacingS

            Behavior on rotation {
                NumberAnimation {
                    duration: Style.shortDuration
                    easing.type: Style.standardEasing
                }
            }
        }
    }

    Popup {
        id: dropdownMenu

        property string searchQuery: ""
        property var filteredOptions: {
            if (!root.enableFuzzySearch || searchQuery.length === 0)
                return root.options;
            if (!fzfFinder)
                return root.options;
            return fzfFinder.find(searchQuery).map(r => r.item);
        }
        property int selectedIndex: -1
        property var fzfFinder: null

        function initFinder() {
            fzfFinder = new Fzf.Finder(root.options, {
                "selector": option => option,
                "limit": 50,
                "casing": "case-insensitive",
                "sort": true,
                "tiebreakers": [(a, b, selector) => selector(a.item).length - selector(b.item).length]
            });
        }

        function selectNext() {
            if (filteredOptions.length === 0)
                return;
            selectedIndex = (selectedIndex + 1) % filteredOptions.length;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }

        function selectPrevious() {
            if (filteredOptions.length === 0)
                return;
            selectedIndex = selectedIndex <= 0 ? filteredOptions.length - 1 : selectedIndex - 1;
            listView.positionViewAtIndex(selectedIndex, ListView.Contain);
        }

        function selectCurrent() {
            if (selectedIndex < 0 || selectedIndex >= filteredOptions.length)
                return;
            root.currentValue = filteredOptions[selectedIndex];
            root.valueChanged(filteredOptions[selectedIndex]);
            close();
        }

        onOpened: {
            root.menuOpen = true;
            selectedIndex = -1;
            if (searchField.text.length > 0) {
                initFinder();
                searchQuery = searchField.text;
            } else {
                fzfFinder = null;
                searchQuery = "";
            }
        }

        onClosed: root.menuOpen = false

        parent: root.Overlay.overlay
        width: root.popupWidth === -1 ? undefined : (root.popupWidth > 0 ? root.popupWidth : (dropdown.width + root.popupWidthOffset))
        height: {
            let h = root.enableFuzzySearch ? 54 : 0;
            if (root.options.length === 0 && root.emptyText !== "")
                h += 32;
            else
                h += Math.min(filteredOptions.length, 10) * 36;
            return Math.min(root.maxPopupHeight, h + 16);
        }
        padding: 0
        modal: true
        dim: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        enter: Transition {
            NumberAnimation {
                property: "scale"
                from: 0.9
                to: 1
                duration: Style.shortDuration
                easing.type: Style.emphasizedEasing
            }
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Style.shortDuration
                easing.type: Style.standardEasing
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "scale"
                from: 1
                to: 0.9
                duration: Style.shortDuration
                easing.type: Style.emphasizedEasing
            }
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Style.shortDuration
                easing.type: Style.standardEasing
            }
        }

        background: Rectangle {
            color: "transparent"
        }

        contentItem: Rectangle {
            id: contentSurface

            LayoutMirroring.enabled: I18n.isRtl
            LayoutMirroring.childrenInherit: true
            color: Style.withAlpha(Style.surfaceContainer, 1)
            border.color: Style.primary
            border.width: 2
            radius: Style.cornerRadius

            ElevationShadow {
                id: shadowLayer
                anchors.fill: parent
                z: -1
                level: Style.elevationLevel2
                fallbackOffset: 4
                targetRadius: contentSurface.radius
                targetColor: contentSurface.color
                borderColor: contentSurface.border.color
                borderWidth: contentSurface.border.width
                shadowEnabled: Style.elevationEnabled && Style.popoutElevationEnabled
            }

            Column {
                anchors.fill: parent
                anchors.margins: Style.spacingS

                Rectangle {
                    id: searchContainer

                    width: parent.width
                    height: 42
                    visible: root.enableFuzzySearch
                    radius: Style.cornerRadius
                    color: root.usePopupTransparency ? Style.withAlpha(Style.surfaceContainerHigh, Style.popupTransparency) : Style.surfaceContainerHigh

                    DankTextField {
                        id: searchField

                        anchors.fill: parent
                        anchors.margins: 1
                        placeholderText: I18n.tr("Search...")
                        topPadding: Style.spacingS
                        bottomPadding: Style.spacingS
                        onTextChanged: searchDebounce.restart()
                        Keys.onDownPressed: dropdownMenu.selectNext()
                        Keys.onUpPressed: dropdownMenu.selectPrevious()
                        Keys.onReturnPressed: dropdownMenu.selectCurrent()
                        Keys.onEnterPressed: dropdownMenu.selectCurrent()
                        Keys.onPressed: event => {
                            if (!(event.modifiers & Qt.ControlModifier))
                                return;
                            switch (event.key) {
                            case Qt.Key_N:
                            case Qt.Key_J:
                                dropdownMenu.selectNext();
                                event.accepted = true;
                                break;
                            case Qt.Key_P:
                            case Qt.Key_K:
                                dropdownMenu.selectPrevious();
                                event.accepted = true;
                                break;
                            }
                        }

                        Timer {
                            id: searchDebounce
                            interval: 50
                            onTriggered: {
                                if (!dropdownMenu.fzfFinder)
                                    dropdownMenu.initFinder();
                                dropdownMenu.searchQuery = searchField.text;
                                dropdownMenu.selectedIndex = -1;
                            }
                        }
                    }
                }

                Item {
                    width: 1
                    height: Style.spacingXS
                    visible: root.enableFuzzySearch
                }

                Item {
                    width: parent.width
                    height: 32
                    visible: root.options.length === 0 && root.emptyText !== ""

                    StyledText {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.spacingS
                        anchors.rightMargin: Style.spacingS
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.emptyText
                        font.pixelSize: Style.fontSizeMedium
                        color: Style.surfaceVariantText
                        horizontalAlignment: Text.AlignLeft
                    }
                }

                DankListView {
                    id: listView

                    width: parent.width
                    height: parent.height - (root.enableFuzzySearch ? searchContainer.height + Style.spacingXS : 0) - (root.options.length === 0 && root.emptyText !== "" ? 32 : 0)
                    clip: true
                    visible: root.options.length > 0
                    model: ScriptModel {
                        values: dropdownMenu.filteredOptions
                    }
                    spacing: Style.spacingXXS

                    interactive: true
                    flickDeceleration: 1500
                    maximumFlickVelocity: 2000
                    boundsBehavior: Flickable.DragAndOvershootBounds
                    boundsMovement: Flickable.FollowBoundsBehavior
                    pressDelay: 0
                    flickableDirection: Flickable.VerticalFlick

                    delegate: Rectangle {
                        id: delegateRoot

                        required property var modelData
                        required property int index
                        property bool isSelected: dropdownMenu.selectedIndex === index
                        property bool isCurrentValue: root.currentValue === modelData
                        property string iconName: root.optionIconMap[modelData] ?? ""
                        property var swatchColor: root.optionColorMap[modelData]

                        width: ListView.view.width
                        height: 32
                        radius: Style.cornerRadius
                        color: isSelected ? Style.primaryHover : optionArea.containsMouse ? Style.primaryHoverLight : Style.withAlpha(Style.primaryHoverLight, 0)

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.spacingS
                            anchors.rightMargin: Style.spacingS
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Style.spacingS

                            DankColorSwatch {
                                id: optionSwatch

                                width: 16
                                height: 16
                                anchors.verticalCenter: parent.verticalCenter
                                visible: delegateRoot.swatchColor !== undefined
                                swatchColor: visible ? delegateRoot.swatchColor : Style.withAlpha(delegateRoot.swatchColor, 0)
                                ringColor: delegateRoot.isCurrentValue ? Style.primary : Style.outline
                            }

                            DankIcon {
                                name: delegateRoot.iconName
                                size: 18
                                color: delegateRoot.isCurrentValue ? Style.primary : Style.surfaceText
                                visible: name !== ""
                            }

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: delegateRoot.modelData
                                font.pixelSize: Style.fontSizeMedium
                                color: delegateRoot.isCurrentValue ? Style.primary : Style.surfaceText
                                font.weight: delegateRoot.isCurrentValue ? Font.Medium : Font.Normal
                                width: root.popupWidth > 0 ? undefined : (delegateRoot.width - parent.x - Style.spacingS * 2 - (optionSwatch.visible ? optionSwatch.width + parent.spacing : 0))
                                elide: root.popupWidth > 0 ? Text.ElideNone : Text.ElideRight
                                wrapMode: Text.NoWrap
                                horizontalAlignment: Text.AlignLeft
                            }
                        }

                        MouseArea {
                            id: optionArea

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.currentValue = delegateRoot.modelData;
                                root.valueChanged(delegateRoot.modelData);
                                root.closeDropdownMenu();
                            }
                        }
                    }
                }
            }
        }
    }
}
