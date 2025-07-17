import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import "../components" as Components
import qs

Item {
    id: dropdown
    height: currentSelectionLayout.implicitHeight + 10

    property var focusManager: FocusManager
    property bool expanded: false
    property var currentNode: null
    property bool isSink: true
    property var onNodeSelected: function (node) {}
    implicitWidth: root.width - 20
    implicitHeight: 20

    Rectangle {
        id: currentSelection
        anchors.left: parent.left
        anchors.right: parent.right
        height: currentSelectionLayout.implicitHeight + 10
        color: "#50" + Globals.colors.colors.color0
        radius: 4

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (dropdown.expanded) {
                    dropdownPopup.closeWithAnimation();
                    dropdown.expanded = false;
                    focusManager.removePopup(dropdownPopup);
                } else {
                    dropdownPopup.anchor.rect.y = currentSelection.height - 4;

                    dropdownPopup.show();
                    dropdown.expanded = true;
                    focusManager.addPopup(dropdownPopup);
                    focusManager.activateFocusGrab();
                }
            }
        }

        RowLayout {
            id: currentSelectionLayout
            anchors.fill: parent
            anchors.margins: 5
            spacing: 8

            Components.ColorIcon {
                source: dropdown.isSink ? Quickshell.iconPath("audio-headphones-symbolic") : Quickshell.iconPath("audio-input-microphone-symbolic")
                implicitSize: 14
            }

            Text {
                Layout.fillWidth: true
                text: dropdown.currentNode ? (dropdown.currentNode.description || dropdown.currentNode.name) : (dropdown.isSink ? "Select output" : "Select input")
                color: "#E5D4C8"
                font.family: root.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Components.ColorIcon {
                source: Quickshell.iconPath(dropdown.expanded ? "go-up-symbolic" : "go-down-symbolic")
                implicitSize: 16
            }
        }
    }

    Components.SlidingPopup {
        id: dropdownPopup
        anchor.item: dropdown
        implicitWidth: Math.max(dropdown.width, 200)
        implicitHeight: Math.min(deviceListColumn.implicitHeight + 20, 220)
        color: "transparent"
        visible: false
        onVisibleChanged: {
            if (!visible) {
                dropdown.expanded = false;
                focusManager.removePopup(dropdownPopup);
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                dropdownPopup.show();
                dropdown.expanded = false;
                // FocusManager.focusGrab.active = !FocusManager.focusGrab.active;
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: "#99" + Globals.colors.colors.color0
            border.color: "#333"
            border.width: 1

            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.margins: 5
                clip: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    id: deviceListColumn
                    width: scrollView.width
                    spacing: 2

                    Repeater {
                        id: deviceRepeater
                        model: Pipewire.nodes

                        delegate: Rectangle {
                            id: deviceItem
                            visible: modelData.audio !== null && (dropdown.isSink ? modelData.isSink === true : modelData.isSink === false)

                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 35 : 0
                            Layout.bottomMargin: 10

                            color: deviceMouseArea.containsMouse ? "#2A2A2A" : "transparent"
                            radius: 3

                            MouseArea {
                                id: deviceMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    dropdownPopup.visible = false;
                                    dropdown.expanded = false;
                                    focusManager.removePopup(dropdownPopup);
                                    dropdown.currentNode = modelData;
                                    dropdown.onNodeSelected(modelData);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                Components.ColorIcon {
                                    source: dropdown.isSink ? Quickshell.iconPath("audio-headphones-symbolic") : Quickshell.iconPath("audio-input-microphone-symbolic")
                                    implicitSize: 16
                                    // color: "#C5B4A8"
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.description || modelData.name
                                    color: "white"
                                    font.family: root.fontFamily
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Text {
                                    visible: modelData === dropdown.currentNode
                                    text: "✓"
                                    color: "#" + Globals.colors.colors.color11
                                    font.pixelSize: 12
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        visible: deviceRepeater.count === 0 || !Pipewire.ready

                        Text {
                            anchors.centerIn: parent
                            text: !Pipewire.ready ? "Loading devices..." : "No devices available"
                            color: "#80C5B4A8"
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            font.italic: true
                        }
                    }
                }
            }
        }
    }
}
