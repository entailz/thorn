//@ pragma UseQApplication
//@ pragma Env QTQUICKCONTROLS_STYLE=org.kde.desktop
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "components" as Components
import qs

Components.BarWidget {
    id: sysTray
    color: "transparent"
    property date selectedDate: Globals.date
    property bool trayExpanded: false

    property color backgroundColor: Globals.backgroundColor
    widgetAnchors {
        margins: 0
        leftMargin: Globals.vertical ? 3 : 0
        topMargin: Globals.vertical ? 5 : 0
    }

    implicitWidth: Globals.vertical ? 28 : (trayExpanded ? contentLayout.implicitWidth + 5 : toggleBtn.width)
    implicitHeight: Globals.vertical ? (Globals.vertical ? 28 : (trayExpanded ? contentLayout.implicitHeight + 5 : toggleBtn.height)) : 22

    QsMenuOpener {
        id: menuOpener
        property SystemTrayItem currentItem: null
        menu: currentItem ? currentItem.menu : null
    }

    HyprlandFocusGrab {
        id: grab
        windows: [trayPopup]
        onCleared: {
            trayPopup.closeWithAnimation();
        }
    }

    RowLayout {
        id: contentLayout
        anchors.fill: parent
        spacing: 2
        layoutDirection: Qt.RightToLeft

        Rectangle {
            id: toggleBtn
            Layout.preferredWidth: 20
            Layout.preferredHeight: parent.height - 14
            Layout.bottomMargin: 3
            color: toggleBtnMouseArea.containsMouse ? "#11c1c1c1" : "transparent"
            radius: 5

            MouseArea {
                id: toggleBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sysTray.trayExpanded = !sysTray.trayExpanded;
                }
            }

            Text {
                id: arrowIcon
                anchors.centerIn: parent
                text: "◀"
                color: "#" + Globals.colors.colors.color6
                font.pixelSize: 8
                rotation: sysTray.trayExpanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Components.BarTooltip {
                relativeItem: toggleBtnMouseArea.containsMouse ? toggleBtn : null
                offset: 6

                Label {
                    font.family: Globals.secondaryFont
                    font.hintingPreference: Font.PreferFullHinting
                    font.pixelSize: 11
                    color: "white"
                    text: sysTray.trayExpanded ? "Hide System Tray" : "Show System Tray"
                }
            }
        }

        Item {
            id: trayItemsContainer
            clip: true
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: trayMask.width
            Layout.minimumWidth: 1
            Layout.minimumHeight: 20

            Item {
                id: trayMask
                width: sysTray.trayExpanded ? trayRow.implicitWidth + 10 : 2
                height: parent.height

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                Row {
                    id: trayRow
                    anchors.fill: parent
                    height: 24
                    spacing: 7

                    Repeater {
                        id: trayRepeater
                        model: SystemTray.items

                        MouseArea {
                            id: delegate
                            required property SystemTrayItem modelData
                            property alias item: delegate.modelData
                            width: icon.implicitWidth + 12
                            height: parent.height - 8
                            anchors.top: parent.top
                            anchors.topMargin: 3
                            enabled: sysTray.trayExpanded

                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true

                            onClicked: {
                                menuOpener.currentItem = item;
                                trayPopup.currentAnchorItem = delegate;
                                trayPopup.show();
                                trayPopup.anchor.updateAnchor();
                                grab.active = true;
                            }
                            Rectangle {
                                id: hoverBackground
                                anchors.fill: parent
                                color: delegate.containsMouse ? "#11c1c1c1" : "transparent"
                                radius: 5

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            IconImage {
                                id: icon
                                anchors.centerIn: parent
                                source: Qt.resolvedUrl(item.icon)
                                implicitSize: 16
                            }

                            // Components.BarTooltip {
                            //     relativeItem: delegate.containsMouse && !trayPopup.visible ? delegate : null
                            //     offset: 2
                            //
                            //     Label {
                            //         font.hintingPreference: Font.PreferFullHinting
                            //         font.family: Globals.secondaryFont
                            //         font.pixelSize: 11
                            //         color: "white"
                            //         text: delegate.item.tooltipTitle || delegate.item.id
                            //     }
                            // }
                        }
                    }

                    Picker {}
                    Pomodoro {
                        id: pomodoroTimer
                    }
                }
            }
        }
    }

    Components.SlidingPopup {
        id: trayPopup
        property Item currentAnchorItem: null
        anchor {
            item: currentAnchorItem
            margins.top: -5
            gravity: Edges.Bottom
            edges: Edges.Bottom
        }
        color: "transparent"
        implicitWidth: menuItemsColumn.implicitWidth + 20
        implicitHeight: menuItemsColumn.implicitHeight + 42
        visible: false

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: trayPopup.closeWithAnimation()
        }

        Rectangle {
            anchors.fill: parent
            color: sysTray.backgroundColor
            radius: 8

            ColumnLayout {
                id: menuItemsColumn
                anchors.centerIn: parent
                spacing: 4

                Repeater {
                    id: menuItemsRepeater
                    model: menuOpener.children

                    delegate: Item {
                        Layout.topMargin: modelData.isSeparator ? 18 : 0
                        implicitHeight: modelData.isSeparator ? 12 : 18
                        implicitWidth: modelData.isSeparator ? parent.width : contentRow.implicitWidth + 20

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: 20
                                rightMargin: 20
                            }
                            height: 1
                            visible: modelData.isSeparator
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        Item {
                            visible: !modelData.isSeparator
                            anchors.fill: parent

                            Row {
                                id: contentRow
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 5

                                Image {
                                    id: modelIcon
                                    source: modelData.icon ?? Quickshell.iconPath(modelData.icon)
                                    width: 14
                                    height: width
                                    visible: modelData.icon
                                }

                                Text {
                                    id: textItem
                                    text: modelData.text
                                    font.pixelSize: 12
                                    font.family: Globals.secondaryFont
                                    color: someMouse.containsMouse ? "#" + Globals.colors.colors.color11 : "#" + Globals.colors.colors.color6
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: someMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: {
                                    trayPopup.closeWithAnimation();
                                    modelData.triggered();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
