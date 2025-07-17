pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Controls
import "../services" as Service
import qs

Rectangle {
    id: searchBar

    property alias searchText: searchField.text
    property alias searchField: searchField

    signal toggleSortMode
    signal toggleViewMode

    function clearSearch() {
        searchField.clear();
    }

    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 16
    }
    height: 50
    radius: 10
    color: Qt.rgba(parseInt(Globals.colors.colors.color0.substring(0, 2), 16) / 255, parseInt(Globals.colors.colors.color0.substring(2, 4), 16) / 255, parseInt(Globals.colors.colors.color0.substring(4, 6), 16) / 255, 0.7)
    border.width: 1
    border.color: "#33" + Globals.colors.colors.color2

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        IconImage {
            source: Quickshell.iconPath("search-icon")
            implicitSize: 24
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
        }

        TextInput {
            id: searchField
            focus: true
            Layout.fillWidth: true
            color: "#" + Globals.colors.colors.color7
            font.family: Globals.font
            font.pointSize: 13
            selectionColor: "#" + Globals.colors.colors.color5
            selectedTextColor: "#" + Globals.colors.colors.color0
            onTextChanged: {
                Service.RunnerAppModel.filterText = text;
            }
            function clear() {
                text = "";
            }
        }

        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Image {
                id: sortIcon
                source: {
                    if (Service.RunnerAppModel.sortMode === "name")
                        return Quickshell.iconPath("view-sort-ascending-symbolic");
                    if (Service.RunnerAppModel.sortMode === "category")
                        return Quickshell.iconPath("folder-symbolic");
                    if (Service.RunnerAppModel.sortMode === "websearch")
                        return "";
                    return Quickshell.iconPath("document-open-recent-symbolic");
                }
                sourceSize.width: 24
                sourceSize.height: 24
                anchors.fill: parent
                opacity: 0.7
            }
            MouseArea {
                anchors.fill: parent
                onClicked: searchBar.toggleSortMode()
                hoverEnabled: true
                onEntered: sortIcon.opacity = 1.0
                onExited: sortIcon.opacity = 0.7
            }
        }

        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Image {
                id: viewToggleIcon
                source: root.gridView ? Quickshell.iconPath("view-list-symbolic") : Quickshell.iconPath("view-grid-symbolic")
                sourceSize.width: 24
                sourceSize.height: 24
                anchors.fill: parent
                opacity: 0.7
            }
            MouseArea {
                anchors.fill: parent
                onClicked: searchBar.toggleViewMode()
                hoverEnabled: true
                onEntered: viewToggleIcon.opacity = 1.0
                onExited: viewToggleIcon.opacity = 0.7
            }
        }
    }
}
