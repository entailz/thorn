import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import Qt5Compat.GraphicalEffects
import qs

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root
        property int activeWorkspace: 1
        property var clientsByWorkspace: ({})
        property bool dragging: false
        property var draggedClient: null
        property int dragTargetWorkspace: -1
        property bool isHovered: false

        WlrLayershell.namespace: "thorn"

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitHeight: root.isHovered ? 110 : 10

        property var modelData

        screen: modelData

        anchors {
            bottom: true
            left: true
            right: true
        }
        DragProxy {
            id: dragProxy
            windowAnchors: root
        }

        ViewPopup {
            id: windowPreview

            function onToplevelDrag(toplevel, globalPos) {
                root.dragging = true;

                if (!dragProxy.active) {
                    dragProxy.startDrag(toplevel, this, globalPos);
                } else {
                    dragProxy.updateDragPosition(globalPos);
                }

                for (let i = 0; i < workspacesRepeater.count; i++) {
                    let workspaceItem = workspacesRepeater.itemAt(i);
                    if (workspaceItem) {
                        let workspaceGlobalRect = {
                            x: workspaceItem.mapToGlobal(0, 0).x,
                            y: workspaceItem.mapToGlobal(0, 0).y,
                            width: workspaceItem.width,
                            height: workspaceItem.height
                        };

                        if (globalPos.x >= workspaceGlobalRect.x && globalPos.x <= workspaceGlobalRect.x + workspaceGlobalRect.width && globalPos.y >= workspaceGlobalRect.y && globalPos.y <= workspaceGlobalRect.y + workspaceGlobalRect.height) {
                            dragTargetWorkspace = workspaceItem.workspaceId;
                            break;
                        } else {
                            if (root.dragTargetWorkspace === workspaceItem.workspaceId) {
                                root.dragTargetWorkspace = -1;
                            }
                        }
                    }
                }
            }

            function onToplevelDragEnd(toplevel) {
                let result = dragProxy.finishDrag();

                if (root.dragging && toplevel && root.dragTargetWorkspace > 0) {
                    let address = "";
                    let currentWorkspace = -1;

                    if (toplevel.userData) {
                        address = toplevel.userData.address || "";
                        if (toplevel.workspace && toplevel.workspace.id !== undefined) {
                            currentWorkspace = toplevel.workspace.id;
                        }
                    }

                    if (address && root.dragTargetWorkspace > 0) {
                        windowManager.moveClient(address, root.dragTargetWorkspace, currentWorkspace);
                    }
                }

                root.dragging = false;
                root.dragTargetWorkspace = -1;
            }
        }
        Rectangle {
            id: hotspotArea
            implicitWidth: dockMainContainer.width
            implicitHeight: 50
            color: "transparent"
            anchors.centerIn: dockMainContainer

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    root.isHovered = true;
                    dockMainContainer.mouseInDock = true;
                }
                propagateComposedEvents: true
            }
        }

        Item {
            id: dockMainContainer
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: Math.min(dockRow.width + 40, parent.width * 0.8)
            height: dockContainer.height

            transform: Translate {
                y: (root.isHovered || root.dragging) ? 0 : dockMainContainer.height
            }

            property bool mouseInDock: false
            MouseArea {
                id: dockAreaDetector
                anchors.fill: dockContainer
                height: 400
                hoverEnabled: true
                propagateComposedEvents: true

                onEntered: {
                    dockMainContainer.mouseInDock = true;
                    root.isHovered = true;
                    dockHideTimer.stop();
                }

                onExited: {
                    dockMainContainer.mouseInDock = false;
                    windowPreview.mouseInPopup = false;
                    dockHideTimer.restart();
                }
            }

            Item {
                id: dockHoverManager

                Timer {
                    id: dockHideTimer
                    interval: 400
                    onTriggered: {
                        if (!dockMainContainer.mouseInDock && !root.dragging) {
                            if (windowPreview && !windowPreview.mouseInPopup && !windowPreview.isDragging) {
                                root.isHovered = false;
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: dockContainer
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    bottomMargin: 15
                }
                width: parent.width
                implicitHeight: 70
                color: "#99" + Globals.colors.colors.color0
                radius: 20
                opacity: 0.95

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 8.0
                    samples: 17
                    color: "#80000000"
                }
            }

            Row {
                id: dockRow
                anchors.centerIn: dockContainer
                spacing: 2

                Rectangle {
                    width: 1
                    height: parent.height * 0.5
                    color: "#4d4d4d"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: workspacesRepeater.count > 0
                }

                Repeater {
                    id: workspacesRepeater
                    model: Hyprland.workspaces

                    delegate: Rectangle {
                        id: workspaceIndicator
                        property int workspaceId: modelData.id
                        property bool isActive: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace && Hyprland.focusedMonitor.activeWorkspace.id === workspaceId
                        property bool isHovered: false
                        property bool isDropTarget: root.dragTargetWorkspace === workspaceId
                        z: 1

                        width: 55
                        height: dockContainer.height - 12
                        color: "transparent"

                        Rectangle {
                            id: dropTargetEffect
                            anchors.fill: parent
                            radius: 10
                            color: "#5294e2"
                            opacity: workspaceIndicator.isDropTarget ? 0.3 : 0
                            visible: workspaceIndicator.isDropTarget

                            transform: Scale {
                                id: workspaceScale
                                origin.x: width / 2
                                origin.y: height / 2
                                xScale: 1.0
                                yScale: 1.0
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }
                        Timer {
                            id: workspaceScaleTimer
                            interval: 16
                            repeat: true
                            running: false
                            property real targetScale: (workspaceIndicator.isHovered || workspaceIndicator.isActive || workspaceIndicator.isDropTarget) ? 1.1 : 1.0
                            property real step: 0.01

                            onTriggered: {
                                if (Math.abs(workspaceScale.xScale - targetScale) < step) {
                                    workspaceScale.xScale = targetScale;
                                    workspaceScale.yScale = targetScale;
                                    running = false;
                                } else if (workspaceScale.xScale < targetScale) {
                                    workspaceScale.xScale += step;
                                    workspaceScale.yScale += step;
                                } else {
                                    workspaceScale.xScale -= step;
                                    workspaceScale.yScale -= step;
                                }
                            }
                        }

                        MouseArea {
                            id: workspaceMouseArea

                            cursorShape: Qt.PointingHandCursor
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                workspaceIndicator.isHovered = true;
                                workspaceScaleTimer.running = true;
                            }
                            onExited: {
                                workspaceIndicator.isHovered = false;
                                workspaceScaleTimer.running = true;
                            }
                            onClicked: {
                                Hyprland.dispatch(`workspace ${workspaceId}`);
                            }
                            propagateComposedEvents: true
                        }

                        Item {
                            anchors.centerIn: parent
                            implicitWidth: workspaceIcon.width
                            implicitHeight: workspaceIcon.height

                            Rectangle {
                                id: workspaceBackground
                                anchors.centerIn: parent
                                width: 38
                                height: 38
                                radius: 10
                                color: workspaceIndicator.isDropTarget ? "#5294e2" : workspaceIndicator.isActive ? "#33" + Globals.colors.colors.color6 : "#333333"
                                opacity: workspaceIndicator.isDropTarget ? 0.6 : (workspaceIndicator.isActive ? 1.0 : workspaceIndicator.isHovered ? 0.8 : 0.0)
                                border.width: workspaceIndicator.isDropTarget ? 2 : 0
                                border.color: "#5294e2"

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            Text {
                                id: workspaceIcon
                                text: modelData.name
                                font.pixelSize: 16
                                font.weight: Font.DemiBold
                                color: isActive ? "#ffffff" : "#dddddd"
                                anchors.centerIn: parent
                            }

                            Rectangle {
                                id: workspaceTooltip
                                visible: workspaceIndicator.isHovered && !root.dragging
                                width: workspaceTooltipText.width + 16
                                height: workspaceTooltipText.height + 10
                                color: "#99" + Globals.colors.colors.color0
                                radius: 6
                                x: (parent.width - width) / 2
                                y: -height - 20
                                z: 100

                                onXChanged: {
                                    if (x + workspaceTooltip.width > dockRow.width) {
                                        x = Math.max(0, dockRow.width - workspaceTooltip.width);
                                    }
                                    if (x < 0) {
                                        x = 0;
                                    }
                                }

                                Text {
                                    id: workspaceTooltipText
                                    anchors.centerIn: parent
                                    text: "Workspace " + modelData.name
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height * 0.5
                    color: "#4d4d4d"
                    anchors.verticalCenter: parent.verticalCenter
                    visible: workspacesRepeater.count > 0
                }

                Repeater {
                    id: allClientsRepeater

                    model: {
                        let allClients = [];
                        let seenClasses = new Set();

                        for (let workspace in clientsByWorkspace) {
                            if (clientsByWorkspace[workspace]) {
                                clientsByWorkspace[workspace].forEach(client => {
                                    if (client.class && !seenClasses.has(client.class)) {
                                        seenClasses.add(client.class);
                                        allClients.push(client);
                                    }
                                });
                            }
                        }

                        return allClients;
                    }

                    delegate: Item {
                        id: appIconItem
                        width: 56
                        height: dockContainer.height - 12

                        property bool justAppeared: true
                        property bool justFocused: false
                        property var clientData: modelData
                        property bool isRunning: true
                        property bool isActive: {
                            if (!ToplevelManager.activeToplevel || !clientData)
                                return false;

                            return (ToplevelManager.activeToplevel.appId && clientData.class && ToplevelManager.activeToplevel.appId === clientData.class) || (ToplevelManager.activeToplevel.title && clientData.title && ToplevelManager.activeToplevel.title === clientData.title);
                        }
                        property bool isHovered: false
                        SequentialAnimation {
                            id: bounceAnimation
                            running: false
                            loops: 1

                            PropertyAnimation {
                                target: iconScale
                                properties: "xScale,yScale"
                                to: 1.25
                                duration: 80
                                easing.type: Easing.OutQuad
                            }
                            PropertyAnimation {
                                target: iconScale
                                properties: "xScale,yScale"
                                to: 0.9
                                duration: 100
                                easing.type: Easing.InOutQuad
                            }
                            PropertyAnimation {
                                target: iconScale
                                properties: "xScale,yScale"
                                to: 1.0
                                duration: 120
                                easing.type: Easing.OutBounce
                            }
                        }
                        Rectangle {
                            id: appIconBackground
                            anchors.centerIn: parent
                            width: 48
                            height: 48
                            radius: 12
                            color: isActive ? "#33" + Globals.colors.colors.color6 : "transparent"
                            opacity: appIconItem.isHovered ? 0.7 : isActive ? 0.7 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                        }

                        IconImage {
                            id: appIcon
                            width: 36
                            height: 36
                            anchors.centerIn: appIconBackground
                            source: clientData && clientData.class ? Quickshell.iconPath(DesktopEntries.byId(clientData.class)?.icon) ?? "" : ""
                            implicitSize: 36

                            transform: Scale {
                                id: iconScale
                                origin.x: appIcon.width / 2
                                origin.y: appIcon.height / 2
                                xScale: 1.0
                                yScale: 1.0
                            }
                        }

                        Rectangle {
                            visible: clientData && clientData.class && (!appIcon.source || appIcon.source === "")
                            anchors.centerIn: appIconBackground
                            width: 36
                            height: 36
                            radius: 8
                            color: "#555555"

                            Text {
                                anchors.centerIn: parent
                                text: clientData && clientData.class ? clientData.class.charAt(0).toUpperCase() : "?"
                                color: "#ffffff"
                                font.pixelSize: 16
                                font.bold: true
                            }
                        }

                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            color: isActive ? "#5294e2" : "#888888"
                            visible: isRunning
                        }

                        Timer {
                            id: appScaleTimer
                            interval: 16
                            repeat: true
                            running: !bounceAnimation.running && (appIconItem.isHovered || appIconItem.isActive)
                            property real targetScale: (appIconItem.isHovered || appIconItem.isActive) ? 1.15 : 1.0
                            property real step: 0.02

                            onTriggered: {
                                if (Math.abs(iconScale.xScale - targetScale) < step) {
                                    iconScale.xScale = targetScale;
                                    iconScale.yScale = targetScale;
                                    running = false;
                                } else if (iconScale.xScale < targetScale) {
                                    iconScale.xScale += step;
                                    iconScale.yScale += step;
                                } else {
                                    iconScale.xScale -= step;
                                    iconScale.yScale -= step;
                                }
                            }
                        }

                        MouseArea {
                            id: appDragArea
                            anchors.fill: parent
                            drag.target: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onEntered: {
                                appIconItem.isHovered = true;
                                appScaleTimer.running = true;
                                draggedClient = "";

                                if (clientData) {
                                    let matchingClients = [];
                                    windowPreview.windowAnchor = root;

                                    windowPreview.show({
                                        class: clientData.class,
                                        instances: matchingClients,
                                        address: clientData.address
                                    }, appIconItem);
                                }
                            }

                            onExited: {
                                appIconItem.isHovered = false;
                                appScaleTimer.running = true;
                            }

                            onClicked: {
                                if (clientData && clientData.address) {
                                    Hyprland.dispatch(`focuswindow address:${clientData.address}`);
                                }
                            }
                        }

                        Drag.active: appDragArea.drag.active
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        states: State {
                            when: appDragArea.drag.active
                            ParentChange {
                                target: appIconItem
                                parent: dragLayer
                            }
                            PropertyChanges {
                                target: appIconItem
                                opacity: 0.8
                                z: 1000
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: dragLayer
            anchors.fill: parent
            z: 1000
        }

        Item {
            id: windowManager

            function moveClient(address, workspace, currentWorkspace) {
                if (!address || workspace < 1)
                    return false;

                if (currentWorkspace !== undefined && workspace === currentWorkspace) {
                    return false;
                }

                Hyprland.dispatch("movetoworkspacesilent " + workspace + ",address:" + address);

                return true;
            }
        }

        Timer {
            id: updateWorkspaceClientsTimer
            interval: 400
            repeat: true
            running: true
            onTriggered: {
                ClientManager.updateClients();
                root.updateWorkspaceClients();
            }
        }

        function updateWorkspaceClients() {
            let workspaceMap = {};

            for (let i = 0; i < Hyprland.workspaces.count; i++) {
                let workspace = Hyprland.workspaces.get(i);
                workspaceMap[workspace.id] = [];
            }

            for (let i = 0; i < ClientManager.clients.length; i++) {
                let client = ClientManager.clients[i];
                if (client && client.workspace && client.workspace.id !== undefined) {
                    let wsId = client.workspace.id;

                    if (!workspaceMap[wsId]) {
                        workspaceMap[wsId] = [];
                    }

                    workspaceMap[wsId].push(client);
                }
            }

            clientsByWorkspace = workspaceMap;
        }

        Component.onCompleted: {
            updateWorkspaceClients();

            if (ClientManager && ClientManager.clientsUpdated) {
                ClientManager.clientsUpdated.connect(updateWorkspaceClients);
            }

            root.isHovered = false;
        }
    }
}
