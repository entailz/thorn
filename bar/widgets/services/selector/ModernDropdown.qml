import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../components" as Components
import qs

Control {
    id: dropdown
    property alias model: repeater.model
    property string placeholder: ""
    property var currentItem: null

    signal selectionChanged(var item)

    implicitHeight: 40

    background: Rectangle {
        radius: 10
        color: dropdown.hovered ? "#30" + Globals.colors.colors.color8 : "#20" + Globals.colors.colors.color8
        border.width: 1
        border.color: dropdown.hovered ? "#40" + Globals.colors.colors.color6 : "#20" + Globals.colors.colors.color6

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
    property var popupWindow: popup

    contentItem: RowLayout {
        anchors {
            left: parent.left
            leftMargin: 16
        }

        Components.IconButton {
            icon: currentItem?.icon || ""
            fillNormal: 0.0
            highlight: false
            fillHover: 1.0
            size: 15
            clickable: true
            useVariableFill: true
        }

        Text {
            // Layout.fillWidth: true
            text: currentItem?.name || placeholder
            font {
                family: Globals.font
                pixelSize: 13
                weight: Font.Medium
            }
            Layout.preferredWidth: 20
            color: "#" + Globals.colors.colors.color6
            // elide: Text.ElideRight
        }

        Item {
            Layout.fillWidth: true
        }
        // Text {
        //     text: ""
        //     Layout.preferredWidth: 20
        //     font.pixelSize: 12
        //     color: "#" + Globals.colors.colors.color7
        // }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.visible ? popup.closeWithAnimation() : popup.show()
    }

    Components.SlidingPopup {
        id: popup
        anchor.item: dropdown
        anchor.rect.y: 32
        anchor.rect.x: -9
        implicitWidth: parent.width + 20
        implicitHeight: Math.min(contentColumn.implicitHeight + 40, 300)
        color: "transparent"

        Rectangle {
            color: "#90" + Globals.colors.colors.color0
            radius: 8
            border.width: 1
            anchors.fill: parent
            border.color: "#30" + Globals.colors.colors.color6

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                color: "#40000000"
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 3
                clip: true

                Column {
                    id: contentColumn
                    width: parent.width
                    spacing: 2

                    Repeater {
                        id: repeater

                        delegate: ItemDelegate {
                            required property var modelData
                            required property int index

                            width: parent.width
                            height: 36

                            background: Rectangle {
                                radius: 6
                                color: parent.hovered ? "#30" + Globals.colors.colors.color4 : "transparent"
                            }

                            contentItem: RowLayout {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    margins: 8
                                }
                                spacing: 8

                                Components.IconButton {
                                    icon: modelData.icon || ""
                                    highlight: false
                                    fillNormal: 0.0
                                    fillHover: 1.0
                                    size: 18
                                    clickable: true
                                    useVariableFill: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font {
                                        family: Globals.font
                                        pixelSize: 13
                                    }
                                    color: "#" + Globals.colors.colors.color7
                                }
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    dropdown.currentItem = modelData;
                                    dropdown.selectionChanged(modelData);
                                    popup.closeWithAnimation();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
