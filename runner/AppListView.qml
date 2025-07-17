pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import QtQuick.Layouts
import qs
import "../services" as Service

ListView {
    id: listView

    signal executeApp(var entry)
    signal executeAction(var action)
    signal indexChanged(int index)

    clip: true
    spacing: 2
    model: Service.RunnerAppModel.appModel
    currentIndex: 0

    highlight: Rectangle {
        color: "#40" + Globals.colors.colors.color2
        radius: 8
    }

    highlightMoveDuration: 100
    highlightResizeDuration: 0

    onCurrentIndexChanged: indexChanged(currentIndex)

    delegate: Item {
        id: listViewDelegate
        required property var modelData
        required property int index
        width: listView.width
        height: modelData.isHeader ? 35 : (hasActions ? 48 + actionsRow.height + 8 : 48)

        property bool hasActions: !modelData.isHeader && modelData.actions && modelData.actions.length > 0
        property bool showActions: true
        opacity: 0
        x: -20
        Component.onCompleted: {
            entranceAnimation.start();
        }
        ParallelAnimation {
            id: entranceAnimation
            NumberAnimation {
                target: listViewDelegate
                property: "opacity"
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: listViewDelegate
                property: "x"
                to: 0
                duration: 250
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: modelData.isHeader
            color: "transparent"

            scale: appMouseArea.containsMouse ? 1.02 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                text: modelData.name || "Other"
                font.family: Globals.font
                renderType: Text.NativeRendering
                font.pointSize: 12
                antialiasing: true
                color: "#A0A0A0"
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            radius: 8
            color: "transparent"
            visible: !modelData.isHeader

            Column {
                anchors.fill: parent
                anchors.margins: 5

                Rectangle {
                    width: parent.width
                    height: 38
                    color: "transparent"

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Image {
                            source: Quickshell.iconPath(listViewDelegate.modelData.icon, "system-help")
                            sourceSize.width: 34
                            sourceSize.height: 34
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            scale: appMouseArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutBack
                                    easing.overshoot: 1.2
                                }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                width: parent.width
                                text: listViewDelegate.modelData.highlightedName
                                font.family: Globals.font
                                renderType: Text.NativeRendering
                                font.pointSize: 11
                                color: "#" + Globals.colors.colors.color7
                                elide: Text.ElideRight
                                textFormat: TextEdit.RichText
                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                text: listViewDelegate.modelData.genericName || listViewDelegate.modelData.comment
                                font.family: Globals.font

                                renderType: Text.NativeRendering
                                font.pointSize: 8
                                color: "#66" + Globals.colors.colors.color7
                                elide: Text.ElideRight
                                visible: text.length > 0
                                opacity: 0.7
                            }
                        }

                        Image {
                            source: Quickshell.iconPath("go-next-symbolic")
                            sourceSize.width: 16
                            sourceSize.height: 16
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            opacity: 0.5
                            visible: listViewDelegate.hasActions
                        }
                    }

                    MouseArea {
                        id: appMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            if (!listViewDelegate.modelData.isHeader) {
                                listView.currentIndex = index;
                            }
                        }
                        onClicked: {
                            if (!listViewDelegate.modelData.isHeader) {
                                listView.executeApp(listViewDelegate.modelData.entry);
                            }
                        }
                    }
                }

                Row {
                    id: actionsRow
                    width: parent.width
                    height: listViewDelegate.hasActions ? 32 : 0
                    spacing: 8
                    leftPadding: 46
                    visible: listViewDelegate.hasActions && listViewDelegate.showActions

                    Repeater {
                        model: listViewDelegate.modelData.actions || []
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: actionText.width + 16
                            height: 24
                            radius: 12
                            color: "#33" + Globals.colors.colors.color2
                            border.width: 1
                            border.color: "#22" + Globals.colors.colors.color4

                            Text {
                                id: actionText
                                anchors.centerIn: parent
                                text: modelData.name
                                font.family: Globals.font
                                renderType: Text.NativeRendering
                                font.pointSize: 8
                                color: "#" + Globals.colors.colors.color7
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    listView.executeAction(modelData);
                                }
                                hoverEnabled: true
                                onEntered: {
                                    parent.scale = 1.05;
                                    parent.color = "#55" + Globals.colors.colors.color2;
                                }
                                onExited: {
                                    parent.color = "#33" + Globals.colors.colors.color2;
                                    parent.scale = 1.0;
                                }

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
