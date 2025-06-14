pragma Singleton
import QtQuick
import Quickshell.Hyprland
import Quickshell

Singleton {
    id: focusManager
    property var popupWindows: []
    property alias focusGrab: grab

    function addPopup(popup) {
        if (popupWindows.indexOf(popup) === -1) {
            popupWindows.push(popup);
            focusGrab.windows = popupWindows;
        }
    }

    function removePopup(popup) {
        const index = popupWindows.indexOf(popup);
        if (index !== -1) {
            popupWindows.splice(index, 1);
            focusGrab.windows = popupWindows;
        }
    }

    function clearAllPopups() {
        for (let i = 0; i < popupWindows.length; i++) {
            if (popupWindows[i] && popupWindows[i].visible) {
                popupWindows[i].closeWithAnimation();
            }
        }

        popupWindows = [];
        focusGrab.windows = [];
    }

    function activateFocusGrab() {
        focusGrab.active = true;
    }

    HyprlandFocusGrab {
        id: grab
        windows: focusManager.popupWindows
        onCleared: {
            focusManager.clearAllPopups();
        }
    }
}
