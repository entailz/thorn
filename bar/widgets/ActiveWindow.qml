import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import "components" as Components
import "services/osd" as OSDInterface
import "services/notis" as Notis
import "services/cal" as Cal
import qs

Components.BarWidget {
    id: roots
    implicitWidth: notiSparkle.visible ? notiSparkle.implicitWidth + buttonWrapper.width + row.spacing + 20 : buttonWrapper.width + 20
    color: "transparent"
    property date selectedDate: Globals.date
    property color backgroundColor: Globals.backgroundColor

    property var todaysEvents: Cal.PersistentEvents.getEventsForDate(new Date())

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Item {
            id: buttonWrapper
            width: button.implicitWidth + notiSparkle.width + 10
            height: button.implicitHeight

            Rectangle {
                id: hoverBackground
                anchors.centerIn: button
                width: button.width + 8
                height: button.height
                color: mouseAreaButton.containsMouse ? "#11c1c1c1" : "transparent"
                radius: 6
                z: -1
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }

            Button {
                id: button
                anchors.centerIn: parent
                hoverEnabled: true
                background: null
                implicitWidth: Math.min(titleText.implicitWidth + 20, 250)
                implicitHeight: 27

                contentItem: Item {
                    anchors.fill: parent
                    Text {
                        id: titleText
                        anchors.fill: parent
                        anchors.margins: 4
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        text: ToplevelManager.activeToplevel?.title ?? "󱨱 "
                        color: "#" + Globals.colors.colors.color6
                        font.family: Globals.font
                        font.pixelSize: 13
                        font.styleName: "Bold"
                    }
                }

                MouseArea {
                    id: mouseAreaButton
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        const window = roots.QsWindow.window;
                        const itemRect = window.contentItem.mapFromItem(roots, 0, roots.height);
                        dashboardPopup.anchor.rect.x = itemRect.x - (dashboardPopup.width / 2) + (roots.width / 2);
                        dashboardPopup.anchor.rect.y = itemRect.y - 6;
                        dashboardPopup.show();
                        grab.active = true;
                    }
                }
            }
        }
        RowLayout {

            Notis.NotificationIndicator {
                id: notiSparkle
                visible: hasNotification
                Layout.topMargin: 5
                implicitWidth: 20
                implicitHeight: 20
            }
        }
    }
    Connections {
        target: Notis.NotiServer.notificationServer
        function onNotification(n) {
            if (!n.transient) {
                n.tracked = true;
                notiSparkle.hasNotification = true;
                n.closed.connect(() => notiSparkle.hasNotification = false);
            }
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Components.BarTooltip {
        id: recentEvents
        relativeItem: mouseAreaButton.containsMouse ? button : null
        offset: 2

        Column {
            spacing: 8
            width: Math.max(100, childrenRect.width)

            Rectangle {
                width: 100
                height: 20
                color: "#88" + Globals.colors.colors.color2
                radius: 8
                anchors.horizontalCenter: parent.horizontalCenter
                visible: todaysEvents.length > 0

                Label {
                    font.family: Globals.font
                    font.pixelSize: 11
                    width: 78
                    anchors.centerIn: parent
                    font.weight: 600
                    font.hintingPreference: Font.PreferFullHinting
                    color: "#ffffff"
                    text: "Today's Events"
                    visible: todaysEvents.length > 0
                }
            }

            Repeater {
                model: todaysEvents

                Row {
                    spacing: 8

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        anchors.verticalCenter: parent.verticalCenter
                        color: modelData.categoryColor || "#" + Globals.colors.colors.color6
                        border.width: 1
                        border.color: Qt.darker(color, 1.2)
                    }

                    Column {
                        spacing: 2

                        Label {
                            font.family: Globals.secondaryFont
                            font.pixelSize: 11
                            color: "white"
                            text: modelData.title || "Untitled Event"
                            font.hintingPreference: Font.PreferFullHinting
                            width: 80
                            elide: Text.ElideRight
                        }

                        Label {
                            font.family: Globals.secondaryFont
                            font.pixelSize: 11
                            color: "#cccccc"
                            text: formatEventTime(modelData)
                            visible: text !== ""
                        }

                        Label {
                            font.family: Globals.secondaryFont
                            font.pixelSize: 11
                            color: "#aaaaaa"
                            text: modelData.description || ""
                            visible: text !== ""
                            wrapMode: Text.WordWrap
                            width: Math.min(implicitWidth, 250)
                        }
                    }
                }
            }
            Item {
                width: parent.width
                visible: todaysEvents.length === 0

                height: 14

                Label {
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: Globals.secondaryFont
                    font.pixelSize: 11
                    color: "#888888"
                    text: "No events today"

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    visible: todaysEvents.length === 0
                }
            }
        }
    }

    function formatEventTime(event) {
        if (!event.time)
            return "";

        let timeStr = "";
        if (event.time.hour !== undefined) {
            const hour = event.time.hour;
            const minute = event.time.minute || 0;
            const ampm = hour >= 12 ? "PM" : "AM";
            const displayHour = hour === 0 ? 12 : (hour > 12 ? hour - 12 : hour);
            timeStr = displayHour + ":" + String(minute).padStart(2, '0') + " " + ampm;
        }

        if (event.endTime && event.endTime.hour !== undefined) {
            const endHour = event.endTime.hour;
            const endMinute = event.endTime.minute || 0;
            const endAmpm = endHour >= 12 ? "PM" : "AM";
            const displayEndHour = endHour === 0 ? 12 : (endHour > 12 ? endHour - 12 : endHour);
            timeStr += " - " + displayEndHour + ":" + String(endMinute).padStart(2, '0') + " " + endAmpm;
        }

        return timeStr;
    }
    RowLayout {
        spacing: 8
        Layout.fillWidth: true
        Layout.fillHeight: true

        OSDInterface.OSD {
            id: osd
            parentQsWindow: parent.QsWindow.window
        }
        Notis.NotificationPopup {
            id: notificationPopupManager
            notificationServer: Notis.NotiServer.notificationServer
            parentQsWindow: parent.QsWindow.window
            silenced: !notiView.notificationsEnabled
            offset: 40
        }

        Components.SlidingPopup {
            id: dashboardPopup
            anchor.window: roots.QsWindow.window
            anchor.margins.top: -2
            implicitWidth: 550
            implicitHeight: 800

            property date displayMonth: selectedDate

            ClippingRectangle {
                id: activeWindowRect
                anchors.fill: parent
                color: roots.backgroundColor
                radius: 16
                layer.smooth: true
                layer.samples: 8
                layer.enabled: true
                contentInsideBorder: true

                z: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.centerIn: parent
                    anchors.margins: 12
                    spacing: 12

                    Cal.Calendar {
                        id: calendarComponent
                        Layout.preferredWidth: 500
                        Layout.preferredHeight: 350
                        selectedDate: roots.selectedDate
                    }

                    Notis.NotificationView {
                        id: notiView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        isVisible: dashboardPopup.visible
                        notificationServer: Notis.NotiServer.notificationServer
                    }
                }
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [dashboardPopup, calendarComponent.calendarPopup]
            onCleared: {
                dashboardPopup.closeWithAnimation();
                calendarComponent.calendarPopup.closeWithAnimation();
            }
        }
    }
}
