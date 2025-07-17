import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick.Controls
import "components" as Components
import "services/power" as Log
import qs

Components.BarWidget {
    id: root
    color: "transparent"
    implicitHeight: 24
    implicitWidth: 24

    property color backgroundColor: Globals.backgroundColor
    HyprlandFocusGrab {
        id: grab
        windows: [slidingPopup]
        onCleared: {
            slidingPopup.closeWithAnimation();
        }
    }

    property var powerButtons: [lockButton, logoutButton, suspendButton, hibernateButton, shutdownButton, rebootButton]

    Log.LogoutButton {
        id: lockButton
        command: "loginctl lock-session"
        text: "Lock"
        icon: "system-lock-screen-symbolic"
    }

    Log.LogoutButton {
        id: logoutButton
        command: "loginctl terminate-user $USER"
        text: "Logout"
        icon: "system-log-out-symbolic"
    }

    Log.LogoutButton {
        id: suspendButton
        command: "systemctl suspend"
        text: "Suspend"
        icon: "system-suspend"
    }

    Log.LogoutButton {
        id: hibernateButton
        command: "systemctl hibernate"
        text: "Hibernate"
        icon: "system-suspend-hibernate"
    }

    Log.LogoutButton {
        id: shutdownButton
        command: "systemctl poweroff"
        text: "Shutdown"
        icon: "system-shutdown-symbolic"
    }

    Log.LogoutButton {
        id: rebootButton
        command: "systemctl reboot"
        text: "Reboot"
        icon: "system-reboot-symbolic"
    }

    Components.BarTooltip {
        relativeItem: powerIcon.containsMouse ? powerIcon : null
        offset: 3

        Label {
            font.hintingPreference: Font.PreferFullHinting
            font.family: Globals.secondaryFont
            font.pixelSize: 11
            color: "white"
            text: "Power"
        }
    }

    Components.IconButton {
        id: powerIcon
        anchors.centerIn: parent
        icon: "power_settings_new"

        size: 16
        outerSize: 20
        fillNormal: 0.0
        fillHover: 1.0
        useVariableFill: true
        buttonRadius: 12
        clickable: true
        onClicked: {
            // if (mouse.button === Qt.LeftButton) {
            slidingPopup.show();
            grab.active = true;
            // } else if (mouse.button === Qt.RightButton) {
            //     shutdownButton.exec();
            // }
        }
    }

    Components.SlidingPopup {
        id: slidingPopup

        direction: "right"
        anchor {
            item: root
            margins.top: -14
            edges: Edges.Right
            gravity: Edges.Bottom
        }
        implicitWidth: 250
        implicitHeight: 200
        visible: open
        property bool open: false
        color: "transparent"

        contentItem: ClippingRectangle {
            anchors.centerIn: parent
            color: root.backgroundColor
            implicitWidth: powerGrid.implicitWidth + 30
            implicitHeight: powerGrid.implicitHeight + 16
            radius: 15
            contentInsideBorder: true
            antialiasing: true
            layer.samples: 4

            Grid {
                id: powerGrid
                anchors.centerIn: parent
                columns: 3
                spacing: 8

                Repeater {
                    model: root.powerButtons

                    Rectangle {
                        width: 64
                        height: 64
                        color: powerMouseArea.containsMouse ? "#55" + Globals.colors.colors.color1 : "#" + Globals.colors.colors.color0
                        border.width: 1
                        border.color: powerMouseArea.containsMouse ? "#44" + Globals.colors.colors.color13 : "transparent"
                        radius: 8

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Components.IconButton {
                                anchors.horizontalCenter: parent.horizontalCenter
                                icon: modelData.icon
                                size: 24
                                scale: powerMouseArea.containsMouse ? 1.1 : 1.0

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.text
                                font.pixelSize: 10
                                font.family: "Rubik"
                                color: "#ffffff"
                                opacity: powerMouseArea.containsMouse ? 1.0 : 0.8

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 150
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: powerMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                modelData.exec();
                                slidingPopup.closeWithAnimation();
                            }
                        }
                    }
                }
            }
        }
    }
}
