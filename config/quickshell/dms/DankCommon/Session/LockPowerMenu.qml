pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs.DankCommon.Common
import qs.DankCommon.Widgets

Rectangle {
    id: root

    property bool isVisible: false
    property bool showLogout: true
    property int selectedIndex: 0
    property int selectedRow: 0
    property int selectedCol: 0
    property var visibleActions: []
    property int gridColumns: 3
    property int gridRows: 2
    property bool useGridLayout: false

    property string holdAction: ""
    property int holdActionIndex: -1
    property real holdProgress: 0
    property bool showHoldHint: false

    property var powerActionConfirmOverride: undefined
    property var powerActionHoldDurationOverride: undefined
    property var powerMenuActionsOverride: undefined
    property var powerMenuDefaultActionOverride: undefined
    property var powerMenuGridLayoutOverride: undefined
    property var requiredActions: []

    readonly property bool needsConfirmation: powerActionConfirmOverride !== undefined ? powerActionConfirmOverride : Style.powerActionConfirm
    readonly property int holdDurationMs: (powerActionHoldDurationOverride !== undefined ? powerActionHoldDurationOverride : Style.powerActionHoldDuration) * 1000

    signal closed

    signal switchUserRequested

    function updateVisibleActions() {
        const allActions = powerMenuActionsOverride !== undefined ? powerMenuActionsOverride : Style.powerMenuActions;
        const hibernateSupported = Host.session?.hibernateSupported ?? false;
        let filtered = allActions.filter(action => {
            if (action === "hibernate" && !hibernateSupported)
                return false;
            if (action === "lock")
                return false;
            if (action === "restart")
                return false;
            if (action === "logout" && !showLogout)
                return false;
            return true;
        });

        for (const action of requiredActions) {
            if (!filtered.includes(action))
                filtered.push(action);
        }

        visibleActions = filtered;

        useGridLayout = powerMenuGridLayoutOverride !== undefined ? powerMenuGridLayoutOverride : Style.powerMenuGridLayout;
        if (!useGridLayout)
            return;
        const count = visibleActions.length;
        if (count === 0) {
            gridColumns = 1;
            gridRows = 1;
            return;
        }

        if (count <= 3) {
            gridColumns = 1;
            gridRows = count;
            return;
        }

        if (count === 4) {
            gridColumns = 2;
            gridRows = 2;
            return;
        }

        gridColumns = 3;
        gridRows = Math.ceil(count / 3);
    }

    function getDefaultActionIndex() {
        const defaultAction = powerMenuDefaultActionOverride !== undefined ? powerMenuDefaultActionOverride : (Style.powerMenuDefaultAction || "suspend");
        const index = visibleActions.indexOf(defaultAction);
        return index >= 0 ? index : 0;
    }

    function getActionAtIndex(index) {
        if (index < 0 || index >= visibleActions.length)
            return "";
        return visibleActions[index];
    }

    function getActionData(action) {
        switch (action) {
        case "reboot":
            return {
                "icon": "restart_alt",
                "label": I18n.tr("Reboot"),
                "key": "R"
            };
        case "logout":
            return {
                "icon": "logout",
                "label": I18n.tr("Log Out"),
                "key": "X"
            };
        case "poweroff":
            return {
                "icon": "power_settings_new",
                "label": I18n.tr("Power Off"),
                "key": "P"
            };
        case "suspend":
            return {
                "icon": "bedtime",
                "label": I18n.tr("Suspend"),
                "key": "S"
            };
        case "hibernate":
            return {
                "icon": "ac_unit",
                "label": I18n.tr("Hibernate"),
                "key": "H"
            };
        case "switchuser":
            return {
                "icon": "switch_account",
                "label": I18n.tr("Switch User"),
                "key": "U"
            };
        default:
            return {
                "icon": "help",
                "label": action,
                "key": "?"
            };
        }
    }

    function actionNeedsConfirm(action) {
        return action !== "lock" && action !== "restart";
    }

    function startHold(action, actionIndex) {
        if (!needsConfirmation || !actionNeedsConfirm(action)) {
            executeAction(action);
            return;
        }
        holdAction = action;
        holdActionIndex = actionIndex;
        holdProgress = 0;
        showHoldHint = false;
        holdTimer.start();
    }

    function cancelHold() {
        if (holdAction === "")
            return;
        const wasHolding = holdProgress > 0;
        holdTimer.stop();
        if (wasHolding && holdProgress < 1) {
            showHoldHint = true;
            hintTimer.restart();
        }
        holdAction = "";
        holdActionIndex = -1;
        holdProgress = 0;
    }

    function completeHold() {
        if (holdProgress < 1) {
            cancelHold();
            return;
        }
        const action = holdAction;
        holdTimer.stop();
        holdAction = "";
        holdActionIndex = -1;
        holdProgress = 0;
        executeAction(action);
    }

    function executeAction(action) {
        if (!action)
            return;
        if (action === "switchuser") {
            hide();
            switchUserRequested();
            return;
        }
        if (!Host.session)
            return;
        hide();
        switch (action) {
        case "logout":
            Host.session.logout();
            break;
        case "suspend":
            Host.session.suspend();
            break;
        case "hibernate":
            Host.session.hibernate();
            break;
        case "reboot":
            Host.session.reboot();
            break;
        case "poweroff":
            Host.session.poweroff();
            break;
        }
    }

    function selectOption(action, actionIndex) {
        startHold(action, actionIndex !== undefined ? actionIndex : -1);
    }

    function show() {
        holdAction = "";
        holdActionIndex = -1;
        holdProgress = 0;
        showHoldHint = false;
        updateVisibleActions();
        const defaultIndex = getDefaultActionIndex();
        if (useGridLayout) {
            selectedRow = Math.floor(defaultIndex / gridColumns);
            selectedCol = defaultIndex % gridColumns;
            selectedIndex = defaultIndex;
        } else {
            selectedIndex = defaultIndex;
        }
        isVisible = true;
        Qt.callLater(() => powerMenuFocusScope.forceActiveFocus());
    }

    function hide() {
        cancelHold();
        isVisible = false;
        closed();
    }

    function handleListNavigation(event, isPressed) {
        if (!isPressed) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_R || event.key === Qt.Key_X || event.key === Qt.Key_S || event.key === Qt.Key_H || (event.key === Qt.Key_P && !(event.modifiers & Qt.ControlModifier))) {
                cancelHold();
                event.accepted = true;
            }
            return;
        }

        switch (event.key) {
        case Qt.Key_Up:
        case Qt.Key_Backtab:
            selectedIndex = (selectedIndex - 1 + visibleActions.length) % visibleActions.length;
            event.accepted = true;
            break;
        case Qt.Key_Down:
        case Qt.Key_Tab:
            selectedIndex = (selectedIndex + 1) % visibleActions.length;
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            startHold(getActionAtIndex(selectedIndex), selectedIndex);
            event.accepted = true;
            break;
        case Qt.Key_N:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex + 1) % visibleActions.length;
                event.accepted = true;
            }
            break;
        case Qt.Key_P:
            if (!(event.modifiers & Qt.ControlModifier)) {
                if (visibleActions.includes("poweroff")) {
                    const idx = visibleActions.indexOf("poweroff");
                    startHold("poweroff", idx);
                    event.accepted = true;
                }
            } else {
                selectedIndex = (selectedIndex - 1 + visibleActions.length) % visibleActions.length;
                event.accepted = true;
            }
            break;
        case Qt.Key_J:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex + 1) % visibleActions.length;
                event.accepted = true;
            }
            break;
        case Qt.Key_K:
            if (event.modifiers & Qt.ControlModifier) {
                selectedIndex = (selectedIndex - 1 + visibleActions.length) % visibleActions.length;
                event.accepted = true;
            }
            break;
        case Qt.Key_R:
            if (visibleActions.includes("reboot")) {
                startHold("reboot", visibleActions.indexOf("reboot"));
                event.accepted = true;
            }
            break;
        case Qt.Key_X:
            if (visibleActions.includes("logout")) {
                startHold("logout", visibleActions.indexOf("logout"));
                event.accepted = true;
            }
            break;
        case Qt.Key_S:
            if (visibleActions.includes("suspend")) {
                startHold("suspend", visibleActions.indexOf("suspend"));
                event.accepted = true;
            }
            break;
        case Qt.Key_H:
            if (visibleActions.includes("hibernate")) {
                startHold("hibernate", visibleActions.indexOf("hibernate"));
                event.accepted = true;
            }
            break;
        }
    }

    function handleGridNavigation(event, isPressed) {
        if (!isPressed) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_R || event.key === Qt.Key_X || event.key === Qt.Key_S || event.key === Qt.Key_H || (event.key === Qt.Key_P && !(event.modifiers & Qt.ControlModifier))) {
                cancelHold();
                event.accepted = true;
            }
            return;
        }

        switch (event.key) {
        case Qt.Key_Left:
            selectedCol = (selectedCol - 1 + gridColumns) % gridColumns;
            selectedIndex = selectedRow * gridColumns + selectedCol;
            event.accepted = true;
            break;
        case Qt.Key_Right:
            selectedCol = (selectedCol + 1) % gridColumns;
            selectedIndex = selectedRow * gridColumns + selectedCol;
            event.accepted = true;
            break;
        case Qt.Key_Up:
        case Qt.Key_Backtab:
            selectedRow = (selectedRow - 1 + gridRows) % gridRows;
            selectedIndex = selectedRow * gridColumns + selectedCol;
            event.accepted = true;
            break;
        case Qt.Key_Down:
        case Qt.Key_Tab:
            selectedRow = (selectedRow + 1) % gridRows;
            selectedIndex = selectedRow * gridColumns + selectedCol;
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            startHold(getActionAtIndex(selectedIndex), selectedIndex);
            event.accepted = true;
            break;
        case Qt.Key_N:
            if (event.modifiers & Qt.ControlModifier) {
                selectedCol = (selectedCol + 1) % gridColumns;
                selectedIndex = selectedRow * gridColumns + selectedCol;
                event.accepted = true;
            }
            break;
        case Qt.Key_P:
            if (!(event.modifiers & Qt.ControlModifier)) {
                if (visibleActions.includes("poweroff")) {
                    const idx = visibleActions.indexOf("poweroff");
                    startHold("poweroff", idx);
                    event.accepted = true;
                }
            } else {
                selectedCol = (selectedCol - 1 + gridColumns) % gridColumns;
                selectedIndex = selectedRow * gridColumns + selectedCol;
                event.accepted = true;
            }
            break;
        case Qt.Key_J:
            if (event.modifiers & Qt.ControlModifier) {
                selectedRow = (selectedRow + 1) % gridRows;
                selectedIndex = selectedRow * gridColumns + selectedCol;
                event.accepted = true;
            }
            break;
        case Qt.Key_K:
            if (event.modifiers & Qt.ControlModifier) {
                selectedRow = (selectedRow - 1 + gridRows) % gridRows;
                selectedIndex = selectedRow * gridColumns + selectedCol;
                event.accepted = true;
            }
            break;
        case Qt.Key_R:
            if (visibleActions.includes("reboot")) {
                startHold("reboot", visibleActions.indexOf("reboot"));
                event.accepted = true;
            }
            break;
        case Qt.Key_X:
            if (visibleActions.includes("logout")) {
                startHold("logout", visibleActions.indexOf("logout"));
                event.accepted = true;
            }
            break;
        case Qt.Key_S:
            if (visibleActions.includes("suspend")) {
                startHold("suspend", visibleActions.indexOf("suspend"));
                event.accepted = true;
            }
            break;
        case Qt.Key_H:
            if (visibleActions.includes("hibernate")) {
                startHold("hibernate", visibleActions.indexOf("hibernate"));
                event.accepted = true;
            }
            break;
        }
    }

    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.5)
    visible: isVisible
    z: 1000

    MouseArea {
        anchors.fill: parent
        onClicked: root.hide()
    }

    Timer {
        id: holdTimer
        interval: 16
        repeat: true
        onTriggered: {
            root.holdProgress = Math.min(1, root.holdProgress + (interval / root.holdDurationMs));
            if (root.holdProgress >= 1) {
                stop();
                root.completeHold();
            }
        }
    }

    Timer {
        id: hintTimer
        interval: 2000
        onTriggered: root.showHoldHint = false
    }

    FocusScope {
        id: powerMenuFocusScope
        anchors.fill: parent
        focus: root.isVisible

        onVisibleChanged: {
            if (visible)
                Qt.callLater(() => forceActiveFocus());
        }

        Keys.onEscapePressed: root.hide()
        Keys.onPressed: event => {
            if (event.isAutoRepeat) {
                event.accepted = true;
                return;
            }
            if (useGridLayout) {
                handleGridNavigation(event, true);
            } else {
                handleListNavigation(event, true);
            }
        }
        Keys.onReleased: event => {
            if (event.isAutoRepeat) {
                event.accepted = true;
                return;
            }
            if (useGridLayout) {
                handleGridNavigation(event, false);
            } else {
                handleListNavigation(event, false);
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: useGridLayout ? Math.min(550, gridColumns * 180 + Style.spacingS * (gridColumns - 1) + Style.spacingL * 2) : 320
            height: contentItem.implicitHeight + Style.spacingL * 2
            radius: Style.cornerRadius
            color: Style.surfaceContainer
            border.color: Style.outlineMedium
            border.width: 1

            Item {
                id: contentItem
                anchors.fill: parent
                anchors.margins: Style.spacingL
                implicitHeight: headerRow.height + Style.spacingM + (useGridLayout ? buttonGrid.implicitHeight : buttonColumn.implicitHeight) + (root.needsConfirmation ? hintRow.height + Style.spacingM : 0)

                Row {
                    id: headerRow
                    width: parent.width
                    height: 30

                    StyledText {
                        text: I18n.tr("Power Options")
                        font.pixelSize: Style.fontSizeLarge
                        color: Style.surfaceText
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Item {
                        width: parent.width - 150
                        height: 1
                    }

                    DankActionButton {
                        iconName: "close"
                        iconSize: Style.iconSize - 4
                        iconColor: Style.surfaceText
                        onClicked: root.hide()
                    }
                }

                Grid {
                    id: buttonGrid
                    visible: useGridLayout
                    anchors.top: headerRow.bottom
                    anchors.topMargin: Style.spacingM
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: root.gridColumns
                    columnSpacing: Style.spacingS
                    rowSpacing: Style.spacingS
                    width: parent.width

                    Repeater {
                        model: root.visibleActions

                        Rectangle {
                            id: gridButtonRect
                            required property int index
                            required property string modelData

                            readonly property var actionData: root.getActionData(modelData)
                            readonly property bool isSelected: root.selectedIndex === index
                            readonly property bool showWarning: modelData === "reboot" || modelData === "poweroff"
                            readonly property bool isHolding: root.holdActionIndex === index && root.holdProgress > 0

                            width: (contentItem.width - Style.spacingS * (root.gridColumns - 1)) / root.gridColumns
                            height: 100
                            radius: Style.cornerRadius
                            color: {
                                if (isSelected)
                                    return Style.primaryHover;
                                if (mouseArea.containsMouse)
                                    return Style.primaryHoverLight;
                                return Style.surfaceHover;
                            }
                            border.color: isSelected ? Style.primary : Style.withAlpha(Style.primary, 0)
                            border.width: isSelected ? 2 : 0

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                visible: gridButtonRect.isHolding

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * root.holdProgress
                                    color: {
                                        if (gridButtonRect.modelData === "poweroff")
                                            return Style.errorSelected;
                                        if (gridButtonRect.modelData === "reboot")
                                            return Style.withAlpha(Style.warning, 0.3);
                                        return Style.primarySelected;
                                    }
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: Style.spacingS

                                DankIcon {
                                    name: gridButtonRect.actionData.icon
                                    size: Style.iconSize + 8
                                    color: {
                                        if (gridButtonRect.showWarning && (mouseArea.containsMouse || gridButtonRect.isHolding)) {
                                            return gridButtonRect.modelData === "poweroff" ? Style.error : Style.warning;
                                        }
                                        return Style.surfaceText;
                                    }
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: gridButtonRect.actionData.label
                                    font.pixelSize: Style.fontSizeMedium
                                    color: {
                                        if (gridButtonRect.showWarning && (mouseArea.containsMouse || gridButtonRect.isHolding)) {
                                            return gridButtonRect.modelData === "poweroff" ? Style.error : Style.warning;
                                        }
                                        return Style.surfaceText;
                                    }
                                    font.weight: Font.Medium
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Rectangle {
                                    width: 20
                                    height: 16
                                    radius: 4
                                    color: Style.onSurface_12
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    StyledText {
                                        text: gridButtonRect.actionData.key
                                        font.pixelSize: Style.fontSizeSmall - 1
                                        color: Style.surfaceTextSecondary
                                        font.weight: Font.Medium
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: {
                                    root.selectedRow = Math.floor(index / root.gridColumns);
                                    root.selectedCol = index % root.gridColumns;
                                    root.selectedIndex = index;
                                    root.startHold(modelData, index);
                                }
                                onReleased: root.cancelHold()
                                onCanceled: root.cancelHold()
                            }
                        }
                    }
                }

                Column {
                    id: buttonColumn
                    visible: !useGridLayout
                    anchors.top: headerRow.bottom
                    anchors.topMargin: Style.spacingM
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Style.spacingS

                    Repeater {
                        model: root.visibleActions

                        Rectangle {
                            id: listButtonRect
                            required property int index
                            required property string modelData

                            readonly property var actionData: root.getActionData(modelData)
                            readonly property bool isSelected: root.selectedIndex === index
                            readonly property bool showWarning: modelData === "reboot" || modelData === "poweroff"
                            readonly property bool isHolding: root.holdActionIndex === index && root.holdProgress > 0

                            width: parent.width
                            height: 50
                            radius: Style.cornerRadius
                            color: {
                                if (isSelected)
                                    return Style.primaryHover;
                                if (listMouseArea.containsMouse)
                                    return Style.primaryHoverLight;
                                return Style.surfaceHover;
                            }
                            border.color: isSelected ? Style.primary : Style.withAlpha(Style.primary, 0)
                            border.width: isSelected ? 2 : 0

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                visible: listButtonRect.isHolding

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    width: parent.width * root.holdProgress
                                    color: {
                                        if (listButtonRect.modelData === "poweroff")
                                            return Style.errorSelected;
                                        if (listButtonRect.modelData === "reboot")
                                            return Style.withAlpha(Style.warning, 0.3);
                                        return Style.primarySelected;
                                    }
                                }
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: Style.spacingM
                                anchors.rightMargin: Style.spacingM
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: Style.spacingM

                                DankIcon {
                                    name: listButtonRect.actionData.icon
                                    size: Style.iconSize + 4
                                    color: {
                                        if (listButtonRect.showWarning && (listMouseArea.containsMouse || listButtonRect.isHolding)) {
                                            return listButtonRect.modelData === "poweroff" ? Style.error : Style.warning;
                                        }
                                        return Style.surfaceText;
                                    }
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                StyledText {
                                    text: listButtonRect.actionData.label
                                    font.pixelSize: Style.fontSizeMedium
                                    color: {
                                        if (listButtonRect.showWarning && (listMouseArea.containsMouse || listButtonRect.isHolding)) {
                                            return listButtonRect.modelData === "poweroff" ? Style.error : Style.warning;
                                        }
                                        return Style.surfaceText;
                                    }
                                    font.weight: Font.Medium
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            Rectangle {
                                width: 28
                                height: 20
                                radius: 4
                                color: Style.onSurface_12
                                anchors.right: parent.right
                                anchors.rightMargin: Style.spacingM
                                anchors.verticalCenter: parent.verticalCenter

                                StyledText {
                                    text: listButtonRect.actionData.key
                                    font.pixelSize: Style.fontSizeSmall
                                    color: Style.surfaceTextSecondary
                                    font.weight: Font.Medium
                                    anchors.centerIn: parent
                                }
                            }

                            MouseArea {
                                id: listMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: {
                                    root.selectedIndex = index;
                                    root.startHold(modelData, index);
                                }
                                onReleased: root.cancelHold()
                                onCanceled: root.cancelHold()
                            }
                        }
                    }
                }

                Row {
                    id: hintRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Style.spacingS
                    spacing: Style.spacingXS
                    visible: root.needsConfirmation
                    opacity: root.showHoldHint ? 1 : 0.5

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    DankIcon {
                        name: root.showHoldHint ? "warning" : "touch_app"
                        size: Style.fontSizeSmall
                        color: root.showHoldHint ? Style.warning : Style.surfaceTextSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        readonly property real totalMs: root.holdDurationMs
                        readonly property int remainingMs: Math.ceil(totalMs * (1 - root.holdProgress))
                        readonly property real durationSec: root.holdDurationMs / 1000
                        text: {
                            if (root.showHoldHint)
                                return I18n.tr("Hold longer to confirm");
                            if (root.holdProgress > 0) {
                                if (totalMs < 1000)
                                    return I18n.tr("Hold to confirm (%1 ms)").arg(remainingMs);
                                return I18n.tr("Hold to confirm (%1s)").arg(Math.ceil(remainingMs / 1000));
                            }
                            if (totalMs < 1000)
                                return I18n.tr("Hold to confirm (%1 ms)").arg(totalMs);
                            return I18n.tr("Hold to confirm (%1s)").arg(durationSec);
                        }
                        font.pixelSize: Style.fontSizeSmall
                        color: root.showHoldHint ? Style.warning : Style.surfaceTextSecondary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Component.onCompleted: updateVisibleActions()
}
