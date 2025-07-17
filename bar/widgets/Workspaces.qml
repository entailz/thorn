import QtQuick
import Quickshell.Hyprland
import qs
import "components" as Components

Components.BarWidget {
    id: root
    // property var japaneseNumerals: ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    function calculateDynamicWidth() {
        if (Globals.vertical)
            return 26;

        const count = workspaceListView.count;

        if (count === 0)
            return 180;

        const baseWidth = 175 / (count + 2.5);
        const totalWorkspaceWidth = baseWidth * (count + 1.5);
        const spacing = Math.max(2, 10 - count) * (count - 1);
        const padding = 10;

        return Math.ceil(totalWorkspaceWidth + spacing + padding);
    }

    implicitWidth: calculateDynamicWidth()
    implicitHeight: Globals.vertical ? 180 : 23

    color: "transparent"
    radius: 8

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
        Hyprland.refreshMonitors();
    }

    ListView {
        id: workspaceListView
        width: 180

        anchors {
            fill: parent
            // leftMargin: Globals.vertical ? 0 : 10
            topMargin: Globals.vertical ? 18 : 0
        }

        orientation: Globals.vertical ? ListView.Vertical : ListView.Horizontal
        model: Hyprland.workspaces
        spacing: Math.max(2, 10 - count)
        clip: true

        delegate: Item {
            id: workspaceContainer

            property bool isValid: modelData.id > 0
            visible: isValid

            width: isValid ? (Globals.vertical ? workspaceListView.width : workspaceRect.width) : 0
            height: isValid ? (Globals.vertical ? workspaceRect.height : workspaceListView.height) : 0

            Rectangle {
                id: workspaceRect
                visible: workspaceContainer.isValid

                property bool isActive: Hyprland.focusedMonitor && Hyprland.focusedMonitor.activeWorkspace && Hyprland.focusedMonitor.activeWorkspace.id === modelData.id

                width: calculateWidth()
                height: calculateHeight() + 1
                anchors.centerIn: parent

                radius: 10
                color: isActive ? "#" + Globals.colors.colors.color6 : "#33" + Globals.colors.colors.color7

                function calculateWidth() {
                    if (Globals.vertical) {
                        return workspaceListView.width * 0.8;
                    } else {
                        const totalWorkspaces = workspaceListView.count;
                        const availableWidth = 175;
                        const baseWidth = availableWidth / (totalWorkspaces + 2.5);
                        return isActive ? baseWidth * 2.5 : baseWidth;
                    }
                }

                function calculateHeight() {
                    if (Globals.vertical) {
                        const totalWorkspaces = workspaceListView.count;
                        const availableHeight = workspaceListView.height;
                        const baseHeight = availableHeight / (totalWorkspaces + 2.5);
                        return isActive ? baseHeight * 2.5 : baseHeight;
                    } else {
                        return workspaceListView.height * 0.8;
                    }
                }

                // Text {
                //     id: workspaceId
                //     text: root.japaneseNumerals[modelData.id] || modelData.id
                //     color: "#" + Globals.colors.colors.color6
                //     font {
                //         family: Globals.secondaryFont
                //         pixelSize: 10
                //         // pixelSize: Math.max(8, Math.min(8, Globals.vertical ? parent.height * 0.3 : parent.width * 0.3))
                //         bold: true
                //     }
                //     anchors.centerIn: parent
                // }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
