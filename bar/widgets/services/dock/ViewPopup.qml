import Quickshell
import QtQuick
import Quickshell.Wayland
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs

PopupWindow {
    id: root
    property var toplevels: []
    property string windowTitle: ""
    property var windowAnchor: null
    property string appClass: ""
    property bool isDragging: false
    property var draggedToplevel: null
    property int autoHideDelay: 300
    property bool mouseInPopup: false
    property bool mouseInDock: false
    property int animationDuration: 100
    property bool isAnimatingHide: false

    visible: false
    color: "transparent"

    anchor.window: root.windowAnchor

    Timer {
        id: hideTimer
        interval: root.autoHideDelay
        repeat: false
        onTriggered: {
            if (!root.mouseInPopup && !root.isDragging && !root.isAnimatingHide) {
                var dockState = false;
                if (root.windowAnchor && root.windowAnchor.dockMainContainer) {
                    dockState = root.windowAnchor.dockMainContainer.mouseInDock;
                }

                if (!dockState) {
                    root.hide();
                }
            }
        }
    }

    Rectangle {
        id: previewBackground
        anchors.centerIn: parent
        radius: 14
        color: "#99" + Globals.colors.colors.color0
        opacity: 0.95
        anchors.margins: 9

        Behavior on width {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }

        width: Math.max(previewContainer.width + 12)
        height: previewContainer.height + titleBar.height + 14

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 3
            radius: 8.0
            samples: 17
            spread: 0.02
            color: "#80000000"
        }

        PropertyAnimation {
            id: hideAnimation
            target: previewBackground
            property: "scale"
            from: 1.0
            to: 0.8
            duration: root.animationDuration
            easing.type: Easing.InBack

            onFinished: {
                opacityHideAnimation.start();
            }
        }

        PropertyAnimation {
            id: opacityHideAnimation
            target: previewBackground
            property: "opacity"
            from: 0.95
            to: 0.0
            duration: root.animationDuration / 2
            easing.type: Easing.InQuad

            onFinished: {
                root.visible = false;
                root.isAnimatingHide = false;
                previewBackground.scale = 1.0;
                previewBackground.opacity = 0.95;
            }
        }

        PropertyAnimation {
            id: showScaleAnimation
            target: previewBackground
            property: "scale"
            from: 0.8
            to: 1.0
            duration: root.animationDuration
            easing.type: Easing.OutBack
        }

        PropertyAnimation {
            id: showOpacityAnimation
            target: previewBackground
            property: "opacity"
            from: 0.0
            to: 0.95
            duration: root.animationDuration / 2
            easing.type: Easing.OutQuad
        }
    }

    Item {
        id: previewContainer
        anchors.centerIn: previewBackground
        anchors.verticalCenterOffset: -titleBar.height / 2
        width: root.toplevels.length <= 3 ? previewRow.width : previewGrid.width
        height: root.toplevels.length <= 3 ? 140 : previewGrid.height

        Flickable {
            id: previewFlickable
            anchors.fill: parent
            contentWidth: previewRow.width
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: root.toplevels.length <= 3

            ScrollBar.horizontal: ScrollBar {
                active: previewRow.width > previewFlickable.width
                visible: active
                policy: ScrollBar.AsNeeded
            }

            Row {
                id: previewRow
                height: parent.height
                spacing: 10

                Repeater {
                    id: windowRepeater
                    model: root.toplevels.length <= 3 ? root.toplevels : []

                    delegate: PreviewItem {
                        id: delegatePreviewRow
                        onItemHovered: function (hovered) {
                            if (hovered) {
                                root.mouseInPopup = true;
                                hideTimer.stop();
                            } else {
                                root.mouseInPopup = false;
                                if (!root.mouseInDock && !root.isDragging && root.visible) {
                                    hideTimer.restart();
                                }
                            }
                        }
                    }
                }
            }
        }

        Flickable {
            id: previewGridFlickable
            anchors.fill: parent
            contentWidth: previewGrid.width
            contentHeight: previewGrid.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            visible: root.toplevels.length > 3

            ScrollBar.horizontal: ScrollBar {
                active: previewGrid.width > previewGridFlickable.width
                visible: active
                policy: ScrollBar.AsNeeded
            }

            ScrollBar.vertical: ScrollBar {
                active: previewGrid.height > previewGridFlickable.height
                visible: active
                policy: ScrollBar.AsNeeded
            }

            Grid {
                id: previewGrid
                columns: 3
                columnSpacing: 10
                rowSpacing: 10

                property real itemWidth: 150
                property real itemHeight: 120

                width: columns * itemWidth + (columns - 1) * columnSpacing
                height: Math.ceil(gridRepeater.count / columns) * itemHeight + (Math.ceil(gridRepeater.count / columns) - 1) * rowSpacing
                Behavior on width {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutCubic
                    }
                }

                Repeater {
                    id: gridRepeater
                    model: root.toplevels.length > 3 ? root.toplevels : []

                    delegate: PreviewItem {
                        implicitWidth: previewGrid.itemWidth - 2
                        implicitHeight: previewGrid.itemHeight + 20
                        onItemHovered: function (hovered) {
                            if (hovered) {
                                root.mouseInPopup = true;
                                hideTimer.stop();
                            } else {
                                root.mouseInPopup = false;
                                if (!root.mouseInDock && !root.isDragging && root.visible) {
                                    hideTimer.restart();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: titleBar
        anchors.bottom: previewBackground.bottom
        anchors.horizontalCenter: previewBackground.horizontalCenter
        anchors.margins: 6
        width: Math.min(previewContainer.width, previewBackground.width - 12)
        height: mainTitleText.contentHeight + 10
        color: "transparent"
        clip: true
        radius: 4

        Text {
            id: mainTitleText
            anchors.fill: parent
            anchors.margins: 5
            elide: Text.ElideRight
            color: "white"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            text: root.windowTitle + (root.toplevels.length > 1 ? " (" + root.toplevels.length + " windows)" : "")
        }
    }

    function findMatchingClient(toplevel) {
        if (!ClientManager || !toplevel)
            return null;

        for (let i = 0; i < ClientManager.clients.length; i++) {
            const client = ClientManager.clients[i];
            if (client.class === toplevel.appId && client.title === toplevel.title) {
                return client;
            }
        }

        if (toplevel.title) {
            let matchingClients = [];
            for (let i = 0; i < ClientManager.clients.length; i++) {
                const client = ClientManager.clients[i];
                if (client.class === toplevel.appId && client.title === toplevel.title) {
                    matchingClients.push(client);
                }
            }

            if (matchingClients.length === 1) {
                return matchingClients[0];
            }
        }

        const classMatches = ClientManager.clients.filter(client => client.class === toplevel.appId);
        if (classMatches.length === 1) {
            return classMatches[0];
        }

        if (toplevel.title && classMatches.length > 0) {
            for (const client of classMatches) {
                if (client.title && toplevel.title && (client.title.includes(toplevel.title) || toplevel.title.includes(client.title))) {
                    return client;
                }
            }
        }

        return null;
    }

    function show(clientData, sourceItem) {
        if (!clientData) {
            hide();
            return;
        }

        ClientManager.updateClients();

        root.appClass = clientData.class || "";
        root.windowTitle = clientData.class || "Window";

        let matchingToplevels = [];

        if (ToplevelManager && ToplevelManager.toplevels) {
            const toplevels = [...ToplevelManager.toplevels.values];

            for (let i = 0; i < toplevels.length; i++) {
                const toplevel = toplevels[i];

                if (!toplevel.userData) {
                    toplevel.userData = {};
                }

                if (toplevel.appId === clientData.class) {
                    const matchedClient = findMatchingClient(toplevel);

                    if (matchedClient) {
                        toplevel.userData.address = matchedClient.address;
                        toplevel.userData.title = toplevel.title;
                        toplevel.userData.class = toplevel.appId;
                        toplevel.userData.instanceIndex = matchingToplevels.length;
                    } else if (clientData.address) {
                        toplevel.userData.address = clientData.address;
                    }

                    if (ToplevelManager.activeToplevel === toplevel) {
                        toplevel.active = true;
                    }

                    matchingToplevels.push(toplevel);
                }
            }
        }

        root.toplevels = matchingToplevels;

        if (matchingToplevels.length === 0) {
            hide();
            return;
        }

        if (matchingToplevels.length <= 3) {
            if (matchingToplevels.length === 1) {
                let toplevel = matchingToplevels[0];
                let aspectRatio = 1.5;

                if (toplevel.size && toplevel.size.width > 0 && toplevel.size.height > 0) {
                    aspectRatio = toplevel.size.width / toplevel.size.height;
                }

                root.implicitWidth = Math.min(360, Math.max(240, 160 * aspectRatio)) + 12;
                root.implicitHeight = 160 + 40;
            } else {
                let totalWidth = matchingToplevels.length * 200 + (matchingToplevels.length - 1) * 10;
                root.implicitWidth = Math.min(800, totalWidth) + 12;
                root.implicitHeight = 160 + 40;
            }
        } else {
            const columns = 3;
            const rows = Math.ceil(matchingToplevels.length / columns);
            const itemWidth = 150;
            const itemHeight = 120;

            root.implicitWidth = Math.min(800, columns * itemWidth + (columns - 1) * 10) + 12;
            root.implicitHeight = Math.min(600, rows * itemHeight + (rows - 1) * 10) + 40 + 12;
        }

        if (sourceItem) {
            const window = sourceItem.QsWindow ? sourceItem.QsWindow.window : null;
            if (window) {
                const itemRect = window.contentItem.mapFromItem(sourceItem, 0, 0);

                root.anchor.rect.x = itemRect.x - (root.implicitWidth / 2) + (sourceItem.width / 2);
                root.anchor.rect.y = itemRect.y - root.implicitHeight - 6;
            }
        }

        root.visible = true;
    }

    function hide() {
        root.visible = false;
        root.toplevels = [];
        root.appClass = "";
        root.isDragging = false;
        root.draggedToplevel = null;
        root.mouseInDock = false;
        root.mouseInPopup = false;
    }

    function onToplevelDrag(toplevel, globalPos) {
    }

    function onToplevelDragEnd(toplevel) {
    }
}
