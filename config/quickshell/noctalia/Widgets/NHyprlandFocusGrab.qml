import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Keeps Hyprland's focus grab alive until keyboardFocus=None has committed,
// then restores the client that was active before the layer surface took focus.
HyprlandFocusGrab {
  id: root

  property bool wanted: false
  property bool restoreOnRelease: true

  property bool _held: false
  property bool _compositorCleared: false
  property bool _suppressRestore: false
  property var _restoreToplevel: null

  property Timer _releaseTimer: Timer {
    interval: 50
    repeat: false
    onTriggered: {
      const toplevel = (!root._compositorCleared && !root._suppressRestore) ? root._restoreToplevel : null;

      root._held = false;
      root.active = false;
      root._restoreToplevel = null;
      root._suppressRestore = false;

      if (toplevel) {
        Qt.callLater(() => toplevel.activate());
      }
    }
  }

  onWantedChanged: _sync()
  Component.onCompleted: _sync()

  function _sync() {
    if (!wanted) {
      if (_held) {
        // Capture this before callers reset one-shot state such as
        // PanelService.closedImmediately.
        _suppressRestore = !restoreOnRelease;
        _releaseTimer.restart();
      }
      return;
    }

    _releaseTimer.stop();
    if (!_held) {
      _restoreToplevel = typeof ToplevelManager !== 'undefined' ? ToplevelManager.activeToplevel : null;
    }
    _held = true;
    _compositorCleared = false;
    _suppressRestore = false;
    active = true;
  }

  onCleared: _compositorCleared = true
}
