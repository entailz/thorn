import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import "pw" as Pw
import "visualizer" as Viz
import qs

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right

    property color backgroundColor: Globals.backgroundColor
    property string fontFamily: Globals.secondaryFont

    height: mainContainer.height
    implicitHeight: mainContainer.height

    Rectangle {
        id: mainContainer
        anchors.left: parent.left
        anchors.right: parent.right
        color: root.backgroundColor
        radius: 16

        height: {
            let contentHeight = tabContent.children[tabBar.currentIndex].implicitHeight + 50;
            return contentHeight + contentColumn.anchors.margins * 2 + cava.cavaHeight + 20;
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }
            spacing: 8

            Viz.Thorn {
                id: cava
                cavaHeight: visible ? 100 : 0
                cavaWidth: 450
                count: 4
                visualizerMode: "wave" // wave or bars
            }

            Row {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 4

                TabButton {
                    width: parent.width / 2 - 2
                    height: parent.height
                    text: "Output Devices"
                    isActive: tabBar.currentIndex === 0
                    onClicked: tabBar.currentIndex = 0
                }

                TabButton {
                    width: parent.width / 2 - 2
                    height: parent.height
                    text: "Input Devices"
                    isActive: tabBar.currentIndex === 1
                    onClicked: tabBar.currentIndex = 1
                }
            }

            TabBar {
                id: tabBar
                visible: false
                currentIndex: 0
            }

            Component {
                id: customDropdownComponent
                Dropdown {
                    id: dropdown
                }
            }

            StackLayout {
                id: tabContent
                Layout.fillWidth: true
                currentIndex: tabBar.currentIndex

                OutputDevicesTab {
                    id: outputTab
                }

                InputDevicesTab {
                    id: inputTab
                }
            }
        }
    }

    component TabButton: Rectangle {
        property string text: ""
        property bool isActive: false
        signal clicked

        color: isActive ? "#60" + Globals.colors.colors.color6 : "transparent"
        radius: 8

        Text {
            anchors.centerIn: parent
            text: parent.text
            color: parent.isActive ? "#DEDEDE" : "#" + Globals.colors.colors.color8
            font.family: root.fontFamily
            font.pixelSize: 13
            font.bold: parent.isActive
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component OutputDevicesTab: Item {
        implicitHeight: outputLayout.implicitHeight

        PwNodeLinkTracker {
            id: linkTracker
            node: Pipewire.defaultAudioSink
        }

        ColumnLayout {
            id: outputLayout
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Loader {
                Layout.fillWidth: true
                sourceComponent: customDropdownComponent
                onLoaded: {
                    item.isSink = true;
                    item.currentNode = Pipewire.defaultAudioSink;
                    item.onNodeSelected = function (node) {
                        if (node) {
                            Pipewire.preferredDefaultAudioSink = node;
                        }
                    };
                }
            }

            Pw.AudioMixerEntry {
                Layout.fillWidth: true
                audioNode: Pipewire.defaultAudioSink
                isMicrophone: false
                showBackground: true
                title: ""
            }

            Text {
                Layout.fillWidth: true
                text: "Connected Applications"
                color: "#" + Globals.colors.colors.color8
                font.family: root.fontFamily
                font.pixelSize: 12
                font.bold: true
                visible: connectedAppsView.count > 0
                leftPadding: 5
            }

            ListView {
                id: connectedAppsView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                clip: true
                spacing: 4

                model: linkTracker.linkGroups.filter(g => g.source && g.source.isStream && g.source.audio)

                delegate: Pw.AppStreamEntry {
                    required property var modelData
                    width: connectedAppsView.width
                    stream: modelData.source
                }

                Text {
                    anchors.centerIn: parent
                    visible: connectedAppsView.count === 0
                    text: "No connected audio streams"
                    color: "#80C5B4A8"
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.italic: true
                }
            }
        }
    }

    component InputDevicesTab: Item {
        implicitHeight: inputLayout.implicitHeight

        ColumnLayout {
            id: inputLayout
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            Loader {
                Layout.fillWidth: true
                sourceComponent: customDropdownComponent
                onLoaded: {
                    item.isSink = false;
                    item.currentNode = Pipewire.defaultAudioSource;
                    item.onNodeSelected = function (node) {
                        if (node) {
                            Pipewire.preferredDefaultAudioSource = node;
                        }
                    };
                }
            }

            Pw.AudioMixerEntry {
                Layout.fillWidth: true
                audioNode: Pipewire.defaultAudioSource
                isMicrophone: true
                showBackground: true
                title: ""
            }
        }
    }
}
