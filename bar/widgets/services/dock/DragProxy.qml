import Quickshell
import QtQuick
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

PopupWindow {
    id: proxyPopup
    property var sourceToplevel: null
    property var sourcePreviewRect: null
    property point dragOffset: Qt.point(0, 0)
    property var targetWorkspace: null
    property bool dragging: false
    property var windowAnchors: null
    property bool mouseInDragProxy: false
    property var localDraggedToplevel: null
    property var sourceWindow: null
    anchor.window: windowAnchors
    visible: false
    color: "transparent"

    implicitWidth: 200
    implicitHeight: 140
    property real targetScale: 1.0
    property real minScale: 0.6

    Timer {
        id: dropScaleTimer
        interval: 300
        repeat: false
        onTriggered: {
            proxyPopup.targetScale = proxyPopup.minScale;
        }
    }
    Rectangle {
        id: previewBackground
        anchors.fill: parent
        radius: 8
        color: "transparent"
        opacity: 0.143
        scale: proxyPopup.targetScale
        Behavior on scale {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 3
            radius: 8.0
            samples: 17
            color: "#80000000"
        }

        ScreencopyView {
            id: windowPreview
            anchors.fill: parent
            anchors.margins: 4
            live: true
            paintCursor: false
            captureSource: proxyPopup.sourceToplevel
            clip: true

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    implicitWidth: windowPreview.width
                    implicitHeight: windowPreview.height
                    radius: 6
                }
            }
        }
    }

    function isOverValidWorkspace(globalPos) {
        if (targetWorkspace && targetWorkspace.id > 0) {
            return true;
        }
        return false;
    }

    function getWorkspaceUnderPosition(globalPos) {
        if (proxyPopup.parent && proxyPopup.parent.dragTargetWorkspace > 0) {
            return {
                id: proxyPopup.parent.dragTargetWorkspace,
                name: "Workspace " + proxyPopup.parent.dragTargetWorkspace
            };
        }
        return null;
    }

    function startDrag(toplevel, sourceWindow, mousePos) {
        if (!toplevel)
            return false;
        proxyPopup.targetScale = 1.0;
        dropScaleTimer.stop();
        proxyPopup.sourceToplevel = toplevel;
        proxyPopup.sourceWindow = sourceWindow;

        if (toplevel.userData) {
            proxyPopup.sourceToplevel.userData = toplevel.userData;
        }
        proxyPopup.sourcePreviewRect = null;

        proxyPopup.dragOffset = Qt.point(100, 70);

        if (toplevel.size && toplevel.size.width > 0 && toplevel.size.height > 0) {
            let aspectRatio = toplevel.size.width / toplevel.size.height;
            proxyPopup.implicitWidth = Math.min(300, 200);
            proxyPopup.implicitHeight = proxyPopup.implicitWidth / aspectRatio;

            proxyPopup.dragOffset = Qt.point(proxyPopup.implicitWidth / 2, proxyPopup.implicitHeight / 2);
        }

        if (sourceWindow && sourceWindow.QsWindow && sourceWindow.QsWindow.window) {
            const window = sourceWindow.QsWindow.window;
            const localPos = window.contentItem.mapFromGlobal(mousePos.x, mousePos.y);
            const itemRect = window.contentItem.mapToItem(null, localPos.x, localPos.y);

            proxyPopup.anchor.rect.x = itemRect.x - proxyPopup.dragOffset.x;
            proxyPopup.anchor.rect.y = itemRect.y - proxyPopup.dragOffset.y;
        } else {
            proxyPopup.anchor.rect.x = mousePos.x - proxyPopup.dragOffset.x;
            proxyPopup.anchor.rect.y = mousePos.y - proxyPopup.dragOffset.y;
        }

        proxyPopup.dragging = true;
        proxyPopup.visible = true;

        return true;
    }

    function updateDragPosition(globalPos) {
        if (!proxyPopup.dragging)
            return;

        if (proxyPopup.sourceWindow && proxyPopup.sourceWindow.QsWindow && proxyPopup.sourceWindow.QsWindow.window) {
            const window = proxyPopup.sourceWindow.QsWindow.window;
            const localPos = window.contentItem.mapFromGlobal(globalPos.x, globalPos.y);
            const itemRect = window.contentItem.mapToItem(null, localPos.x, localPos.y);

            proxyPopup.anchor.rect.x = itemRect.x - proxyPopup.dragOffset.x;
            proxyPopup.anchor.rect.y = itemRect.y - proxyPopup.dragOffset.y;
        } else {
            proxyPopup.anchor.rect.x = globalPos.x - proxyPopup.dragOffset.x;
            proxyPopup.anchor.rect.y = globalPos.y - proxyPopup.dragOffset.y;
        }

        proxyPopup.targetWorkspace = getWorkspaceUnderPosition(globalPos);
    }

    function finishDrag() {
        if (!proxyPopup.dragging)
            return;
        proxyPopup.dragging = false;
        dropScaleTimer.restart();
        let result = {
            completed: false,
            toplevel: proxyPopup.sourceToplevel,
            workspace: proxyPopup.targetWorkspace
        };

        if (proxyPopup.sourceToplevel && proxyPopup.targetWorkspace && isOverValidWorkspace(Qt.point(proxyPopup.anchor.rect.x, proxyPopup.anchor.rect.y))) {
            result.completed = true;

            if (proxyPopup.parent && typeof proxyPopup.parent.updateWorkspaceClients === "function") {
                proxyPopup.parent.updateWorkspaceClients();
            }
        }

        proxyPopup.dragging = false;
        proxyPopup.visible = false;
        proxyPopup.sourceToplevel = null;
        proxyPopup.targetWorkspace = null;
        proxyPopup.sourceWindow = null;

        return result;
    }

    function cancelDrag() {
        proxyPopup.dragging = false;
        dropScaleTimer.restart();
        proxyPopup.dragging = false;
        proxyPopup.visible = false;
        proxyPopup.sourceToplevel = null;
        proxyPopup.targetWorkspace = null;
        proxyPopup.sourceWindow = null;
    }
}
