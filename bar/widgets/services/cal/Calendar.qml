import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../../components" as Components
import qs

Item {
    id: calendarRoot

    property var categoryColors: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F"]
    property date selectedDate: Globals.date
    property bool showWeeklyView: false
    property alias calendarPopup: eventPopup

    signal dateSelected(date newDate)

    Item {
        id: viewContainer
        anchors.fill: parent
        clip: true

        // Monthly Calendar View
        Item {
            id: calendarView
            width: parent.width
            height: parent.height
            x: showWeeklyView ? -width : 0

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 12

                // Clock section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "transparent"
                    radius: 8

                    CalendarClock {
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width
                    }
                }

                // Calendar section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 320
                    color: "transparent"
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header with date and toggle button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: "transparent"

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 24
                                anchors.rightMargin: 24

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - toggleButton.width - 10
                                    text: Globals.date.toLocaleDateString()
                                    color: "#" + Globals.colors.colors.color6
                                    font.family: Globals.font
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }

                                Components.BarTooltip {
                                    relativeItem: viewToggle.containsMouse ? toggleButton : null

                                    Label {
                                        font.family: Globals.secondaryFont
                                        font.pixelSize: 13
                                        color: "white"
                                        text: "Planner View"
                                    }
                                }

                                Button {
                                    id: toggleButton
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 30
                                    height: 30
                                    text: ""


                                    background: Rectangle {
                                        color: !viewToggle.containsMouse ? "#22" + Globals.colors.colors.color0 : "#55" + Globals.colors.colors.color8
                                        radius: 4
                                    }

                                    contentItem: Text {
                                        text: toggleButton.text
                                        color: "#A0A0A0"
                                        font.family: Globals.font
                                        font.pixelSize: 10
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    MouseArea {
                                        id: viewToggle
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: showWeeklyView = true
                                    }
                                }
                            }
                        }

                        // Calendar grid
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8
                            Layout.bottomMargin: 8

                            CalendarGrid {
                                anchors.fill: parent
                                selectedDate: calendarRoot.selectedDate
                                displayDate: calendarRoot.selectedDate
                                
                                onDateClicked: function(clickedDate) {
                                    calendarRoot.selectedDate = clickedDate
                                    calendarRoot.dateSelected(clickedDate)
                                }
                                
                                onDateDoubleClicked: function(clickedDate) {
                                    if (eventPopup.visible) {
                                        eventPopup.closeWithAnimation()
                                    } else {
                                        calendarRoot.selectedDate = clickedDate
                                        calendarRoot.dateSelected(clickedDate)
                                        eventPopup.selectedDate = clickedDate
                                        eventPopup.show()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Weekly Planner View
        WeeklyView {
            id: weeklyView
            width: parent.width
            height: parent.height
            x: showWeeklyView ? 0 : width
            selectedDate: calendarRoot.selectedDate
            categoryColors: calendarRoot.categoryColors

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
            }

            onBackToCalendar: showWeeklyView = false
            
            onEventClicked: function(event, eventDate) {
                eventPopup.selectedDate = eventDate
                eventPopup.openForEdit(event)
            }
            
            onTimeSlotClicked: function(slotDate, hour) {
                eventPopup.selectedDate = slotDate
                if (eventPopup.startHourSpinBox) {
                    eventPopup.startHourSpinBox.value = hour
                }
                if (eventPopup.startMinuteSpinBox) {
                    eventPopup.startMinuteSpinBox.value = 0
                }
                eventPopup.show()
            }
        }
    }

    // Event popup
    EventPopup {
        id: eventPopup
        visible: false
        anchor.item: calendarRoot
        anchor.rect.x: 505
        categoryColors: calendarRoot.categoryColors
    }
}
