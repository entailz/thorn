pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import "components" as Components
import "root:/"
import "faces" as Mark

Components.BarWidget {
    id: root
    Layout.fillHeight: true

    property date selectedDate: Globals.date
    property int interval: 1000
    property int index: 0
    property var symbols: ["｡◕  ‿  ◕｡", "｡◑  ‿  ◑｡", "｡◒  ‿  ◒｡", "｡◔  ‿  ◔｡", "｡◓  ‿  ◓｡", "｡◐  ‿  ◐｡", "｡◠  ‿  ◠｡"]

    property color backgroundColor: Globals.backgroundColor
    color: "transparent"

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: {
            index = (root.index + 1) % root.symbols.length;
            label.text = root.symbols[root.index];
        }
    }
    Components.SlidingPopup {
        id: profilePopup

        property date displayMonth: root.selectedDate

        anchor.window: root.QsWindow.window
        implicitWidth: 600
        implicitHeight: 400
        anchor.margins.top: -2
        cornerRadius: 16
        Behavior on implicitHeight {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        ClippingRectangle {
            id: mainRect
            anchors.fill: parent
            color: root.backgroundColor
            radius: 16
            z: 1
            // antialiasing: true
            border {
                width: 12
                color: "#02" + Globals.colors.colors.color0
            }
            contentUnderBorder: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                ClippingRectangle {
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.fillHeight: true
                    color: "#33" + Globals.colors.colors.color0
                    radius: 8
                    contentInsideBorder: true
                    // antialiasing: true
                    Mark.UserProfileCard {
                        implicitHeight: 200
                        implicitWidth: parent.width
                        // anchors.fill: parent
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Mark.NoteEditor {
                        id: noteEditor
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        // anchors.fill: parent
                        implicitHeight: 200
                        implicitWidth: 200
                        Layout.bottomMargin: 6
                    }
                }
            }
            Rectangle {
                id: resizeHandle
                height: 18
                width: parent.width
                anchors.bottom: parent.bottom
                color: "transparent"

                MouseArea {
                    id: resizeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    property real startY: 0
                    property real startHeight: 0

                    onPressed: mouse => {
                        startY = mouse.y;
                        startHeight = profilePopup.implicitHeight;
                    }

                    onPositionChanged: mouse => {
                        if (mouse.buttons & Qt.LeftButton) {
                            let dy = mouse.y;
                            profilePopup.implicitHeight = Math.max(200, startHeight + dy);
                        }
                    }
                }

                Rectangle {
                    width: 40
                    height: 4
                    radius: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    // color: "#" + Globals.colors.colors.color8

                    color: resizeArea.containsMouse ? "#" + Globals.colors.colors.color9 : "#" + Globals.colors.colors.color8

                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                        }
                    }
                }
            }
        }
    }

    Components.SlidingPopup {
        id: saveNotificationPopup
        implicitWidth: 620
        implicitHeight: 40
        anchor.rect.x: parent.width / 2 - saveNotificationPopup.width / 2
        anchor.window: root.QsWindow.window
        anchor.rect.y: 0
        visible: false

        Rectangle {
            id: saveNotification
            property string text: ""
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: notificationText.width + 32
            height: 20
            radius: 8
            color: "#2E4B2E"
            visible: false
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            Text {
                id: notificationText
                anchors.centerIn: parent
                color: "#EEEEEE"
                font.family: Globals.font
                font.pixelSize: 14
                text: saveNotification.text
            }

            Timer {
                id: notificationTimer
                interval: 3000
                onTriggered: {
                    saveNotification.visible = false;
                    saveNotificationPopup.closeWithAnimation();
                }
            }
        }
    }
    Item {
        width: label.implicitWidth + 8
        height: label.implicitHeight + 8

        Rectangle {
            id: hoverBackground
            anchors.fill: parent
            color: mouseAreaButton.containsMouse ? "#11c1c1c1" : "transparent"
            radius: 6
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        Text {
            id: label
            text: root.symbols[root.index]

            font.pixelSize: 14
            font.family: "Readex Pro"
            color: "#" + Globals.colors.colors.color6
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseAreaButton
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                const window = root.QsWindow.window;
                const itemRect = window.contentItem.mapFromItem(root, 0, root.height);

                profilePopup.anchor.rect.x = itemRect.x - (profilePopup.width / 2) + (root.width / 2);
                profilePopup.anchor.rect.y = itemRect.y - 4;
                profilePopup.show();

                // profilePopup.visible = !profilePopup.visible;
                grab.active = !grab.active;
            }
        }
    }

    Components.BarTooltip {
        relativeItem: mouseAreaButton.containsMouse ? hoverBackground : null
        offset: 3

        Label {
            font.hintingPreference: Font.PreferFullHinting
            font.family: Globals.secondaryFont
            font.pixelSize: 11
            color: "white"
            text: "Markdown Editor"
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [profilePopup]
        onCleared: {
            profilePopup.closeWithAnimation();
        }
    }
}
