pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "runner" as Run
import "services" as Service

PanelWindow {
    id: root

    property int currentIndex: 0
    property int itemsPerRow: 4
    property bool gridView: false
    property int animationDuration: 150
    property bool sparklesEnabled: false

    implicitWidth: 300
    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "thornrun"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    function toggleViewMode() {
        root.gridView = !root.gridView;
        root.currentIndex = 0;
        if (root.gridView) {
            gridView.currentIndex = 0;
        } else {
            listView.currentIndex = 0;
            listView.positionViewAtIndex(0, ListView.Beginning);
        }
    }

    function toggleSortMode() {
        if (Service.RunnerAppModel.sortMode === "name") {
            Service.RunnerAppModel.sortMode = "category";
        } else if (Service.RunnerAppModel.sortMode === "category") {
            Service.RunnerAppModel.sortMode = "websearch";
        } else if (Service.RunnerAppModel.sortMode === "frequency") {
            Service.RunnerAppModel.sortMode = "name";
        } else {
            Service.RunnerAppModel.sortMode = "frequency";
        }
        root.currentIndex = 0;
        if (root.gridView) {
            gridView.currentIndex = 0;
        } else {
            listView.currentIndex = 0;
            listView.positionViewAtIndex(0, ListView.Beginning);
        }
    }

    function executeApp(entry) {
        Service.Frequency.trackApp(entry.name || entry.id);
        entry.execute();
        root.currentIndex = 0;
        root.visible = false;
        searchBar.clearSearch();
        Service.RunnerAppModel.filterText = "";
    }

    function executeAction(action) {
        action.execute();
        root.currentIndex = 0;
        root.visible = false;
        searchBar.clearSearch();
        Service.RunnerAppModel.filterText = "";
    }

    function calculateContentHeight() {
        if (Service.RunnerAppModel.sortMode === "websearch") {
            return 80;
        }

        if (root.gridView) {
            var itemCount = Service.RunnerAppModel.appModel.count;
            if (itemCount === 0)
                return 150;

            var rows = Math.ceil(itemCount / root.itemsPerRow);
            var gridItemHeight = 80;
            var calculatedHeight = 80 + (rows * gridItemHeight) + 32;

            return Math.max(150, Math.min(calculatedHeight, 600));
        } else {
            var totalHeight = 70;
            var itemCount = Service.RunnerAppModel.appModel.count;

            if (itemCount === 0)
                return 85;

            for (var i = 0; i < itemCount; i++) {
                var item = Service.RunnerAppModel.appModel.values[i];
                if (item && item.isHeader) {
                    totalHeight += 35;
                } else if (item) {
                    var hasActions = item.actions && item.actions.length > 0;
                    totalHeight += hasActions ? (48 + 32 + 8) : 48;
                }
                totalHeight += 2;
            }

            totalHeight += 20;

            return Math.max(150, Math.min(totalHeight, 600));
        }
    }

    Item {
        id: mainContainer
        anchors.fill: parent

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.visible = false;
                searchBar.clearSearch();
                Service.RunnerAppModel.filterText = "";
                root.currentIndex = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                if (root.gridView) {
                    var row = Math.floor(root.currentIndex / root.itemsPerRow);
                    var col = root.currentIndex % root.itemsPerRow;

                    if (row > 0) {
                        var newIndex = (row - 1) * root.itemsPerRow + col;
                        if (newIndex < Service.RunnerAppModel.appModel.count) {
                            root.currentIndex = newIndex;
                            gridView.currentIndex = root.currentIndex;
                        }
                    }
                } else {
                    if (root.currentIndex > 0) {
                        root.currentIndex--;
                        listView.currentIndex = root.currentIndex;
                        listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
                    }
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                if (root.gridView) {
                    var row = Math.floor(root.currentIndex / root.itemsPerRow);
                    var col = root.currentIndex % root.itemsPerRow;

                    var newIndex = (row + 1) * root.itemsPerRow + col;
                    if (newIndex < Service.RunnerAppModel.appModel.count) {
                        root.currentIndex = newIndex;
                        gridView.currentIndex = root.currentIndex;
                    }
                } else {
                    if (root.currentIndex < Service.RunnerAppModel.appModel.count - 1) {
                        root.currentIndex++;
                        listView.currentIndex = root.currentIndex;
                        listView.positionViewAtIndex(root.currentIndex, ListView.Contain);
                    }
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Left) {
                if (root.gridView) {
                    if (root.currentIndex % root.itemsPerRow > 0) {
                        root.currentIndex--;
                        gridView.currentIndex = root.currentIndex;
                    }
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Right) {
                if (root.gridView) {
                    if (root.currentIndex % root.itemsPerRow < root.itemsPerRow - 1 && root.currentIndex < Service.RunnerAppModel.appModel.count - 1) {
                        root.currentIndex++;
                        gridView.currentIndex = root.currentIndex;
                    }
                }
                event.accepted = true;
            } else if (event.key === Qt.Key_Tab) {
                root.toggleSortMode();
                event.accepted = true;
            } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && Service.RunnerAppModel.sortMode === "websearch") {
                Service.Search.searchTerm = Service.RunnerAppModel.filterText;
                root.visible = false;
                searchBar.clearSearch();
                Service.RunnerAppModel.filterText = "";
                root.currentIndex = 0;
                event.accepted = true;
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (root.currentIndex >= 0 && root.currentIndex < Service.RunnerAppModel.appModel.count) {
                    var entry = Service.RunnerAppModel.appModel.values[root.currentIndex];
                    root.executeApp(entry.entry);
                }
                event.accepted = true;
            }
        }

        Rectangle {
            id: contentRect
            clip: true

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 16
            implicitWidth: 600

            implicitHeight: root.calculateContentHeight()

            color: Globals.backgroundColor
            border.width: 1
            border.color: "#44" + Globals.colors.colors.color4

            Behavior on width {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on implicitHeight {
                NumberAnimation {
                    duration: root.animationDuration + 50
                    easing.type: Easing.OutQuad
                }
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12.0
                samples: 16
                color: "#80000000"
            }

            Run.SearchBar {
                id: searchBar
                onToggleSortMode: root.toggleSortMode()
                onToggleViewMode: root.toggleViewMode()
            }

            Run.AppListView {
                id: listView
                anchors {
                    top: searchBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 16
                    topMargin: 10
                }
                visible: !root.gridView && Service.RunnerAppModel.sortMode != "websearch"
                currentIndex: root.currentIndex
                onExecuteApp: entry => root.executeApp(entry)
                onExecuteAction: action => root.executeAction(action)
                onIndexChanged: index => root.currentIndex = index
            }

            Run.AppGridView {
                id: gridView
                anchors {
                    top: searchBar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 16
                    topMargin: 10
                }
                visible: root.gridView
                currentIndex: root.currentIndex
                itemsPerRow: root.itemsPerRow
                onExecuteApp: entry => root.executeApp(entry)
                onIndexChanged: index => root.currentIndex = index
            }

            Run.WebSearchView {
                anchors.centerIn: parent
                visible: Service.RunnerAppModel.sortMode === "websearch"
            }
        }
    }

    GlobalShortcut {
        appid: "shell"
        name: "runner"
        onPressed: {
            var wasVisible = root.visible;
            root.visible = !root.visible;
            focusGrab.active = !focusGrab.active;

            if (root.visible) {
                searchBar.clearSearch();
                Service.RunnerAppModel.filterText = "";

                listView.currentIndex = 0;
                contentRect.opacity = 0;
                contentRect.scale = 0.95;
                showAnimation.start();
            }
        }
    }

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: contentRect
            property: "opacity"
            from: 0
            to: 1
            duration: root.animationDuration
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: contentRect
            property: "scale"
            from: 0.95
            to: 1.0
            duration: root.animationDuration
            easing.type: Easing.OutQuad
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        windows: [root]
        onCleared: {
            root.visible = false;
            searchBar.clearSearch();
            Service.RunnerAppModel.filterText = "";
            active = false;
        }
    }
}
