import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components
import qs

Item {
    id: weeklyRoot

    property date selectedDate: new Date()
    property var categoryColors: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F"]

    signal backToCalendar
    signal eventClicked(var event, date eventDate)
    signal timeSlotClicked(date slotDate, int hour)

    function getWeekStart(date) {
        const d = new Date(date);
        const day = d.getDay();
        const diff = d.getDate() - day;
        return new Date(d.setDate(diff));
    }

    function getEventsForDateInTimeRange(date, startHour, endHour) {
        const events = PersistentEvents.getEventsForDate(date);
        return events.filter(event => {
            if (!event.time)
                return false;

            const eventStartHour = event.time.hour;
            const eventStartMinute = event.time.minute || 0;
            const eventStartTotalMinutes = eventStartHour * 60 + eventStartMinute;

            const durationHours = (event.duration && event.duration.hours) || 1;
            const durationMinutes = (event.duration && event.duration.minutes) || 0;
            const eventDurationTotalMinutes = durationHours * 60 + durationMinutes;
            const eventEndTotalMinutes = eventStartTotalMinutes + eventDurationTotalMinutes;

            const slotStartMinutes = startHour * 60;
            const slotEndMinutes = endHour * 60;

            return eventStartTotalMinutes < slotEndMinutes && eventEndTotalMinutes > slotStartMinutes;
        });
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Header with navigation
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "transparent"

            RowLayout {
                anchors.fill: parent

                Components.IconButton {
                    icon: "arrow-left-double"
                    padding: 10
                    size: 20
                    clickable: true
                    onClicked: {
                        const newDate = new Date(selectedDate);
                        newDate.setDate(newDate.getDate() - 7);
                        selectedDate = newDate;
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: {
                        const weekStart = weeklyRoot.getWeekStart(selectedDate);
                        const weekEnd = new Date(weekStart);
                        weekEnd.setDate(weekEnd.getDate() + 6);

                        return weekStart.toLocaleDateString('en-US', {
                            month: 'long',
                            day: 'numeric'
                        }) + " - " + weekEnd.toLocaleDateString('en-US', {
                            month: 'long',
                            day: 'numeric',
                            year: 'numeric'
                        });
                    }
                    color: "#" + Globals.colors.colors.color6
                    font.family: Globals.secondaryFont
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Components.IconButton {
                    icon: "arrow-right-double"
                    clickable: true
                    size: 20
                    padding: 10
                    onClicked: {
                        const newDate = new Date(selectedDate);
                        newDate.setDate(newDate.getDate() + 7);
                        selectedDate = newDate;
                    }
                }
            }
        }

        // Weekly calendar grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            border.color: "#44" + Globals.colors.colors.color2
            border.width: 1

            ScrollView {
                anchors.fill: parent
                clip: true
                contentWidth: parent.width
                contentHeight: 24 * 45 + 70

                Item {
                    width: parent.parent.width
                    height: Math.max(24 * 45 + 70, parent.parent.height)

                    // Days header
                    Row {
                        id: daysHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 70

                        // Time column header
                        Rectangle {
                            width: 70
                            height: parent.height
                            color: "transparent"
                            border.color: "#55" + Globals.colors.colors.color3
                            border.width: 1

                            Components.IconButton {
                                icon: "calendar-symbolic"
                                anchors.centerIn: parent
                                padding: 10
                                size: 16
                                clickable: true
                                onClicked: weeklyRoot.backToCalendar()
                            }
                        }

                        // Day headers
                        Repeater {
                            model: 7
                            delegate: Rectangle {
                                width: (parent.width - 70) / 7
                                height: parent.height
                                color: "transparent"
                                border.color: "#55" + Globals.colors.colors.color3
                                border.width: 1

                                property date dayDate: {
                                    const weekStart = weeklyRoot.getWeekStart(selectedDate);
                                    const day = new Date(weekStart);
                                    day.setDate(day.getDate() + index);
                                    return day;
                                }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index]
                                        color: "#" + Globals.colors.colors.color6
                                        font.family: Globals.secondaryFont
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: dayDate.getDate()
                                        color: {
                                            const today = new Date();
                                            const isToday = dayDate.toDateString() === today.toDateString();
                                            return isToday ? "#" + Globals.colors.colors.color11 : "#" + Globals.colors.colors.color5;
                                        }
                                        font.family: Globals.secondaryFont
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                    }

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: 20
                                        height: 16
                                        radius: 8
                                        color: "#66" + Globals.colors.colors.color11
                                        visible: PersistentEvents.getEventsForDate(dayDate).length > 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: PersistentEvents.getEventsForDate(dayDate).length
                                            color: "#FFFFFF"
                                            font.family: Globals.font
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Time slots
                    Item {
                        anchors.top: daysHeader.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 24 * 45

                        Column {
                            width: parent.width

                            Repeater {
                                model: 24 // 24 hours
                                delegate: Row {
                                    width: parent.width
                                    height: 45
                                    property int hour: index

                                    // Time label
                                    Rectangle {
                                        width: 70
                                        height: parent.height
                                        color: "transparent"
                                        border.color: "#44" + Globals.colors.colors.color2
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: {
                                                const displayHour = index % 12 === 0 ? 12 : index % 12;
                                                const ampm = index < 12 ? "AM" : "PM";
                                                return displayHour + ":00 " + ampm;
                                            }
                                            color: "#" + Globals.colors.colors.color5
                                            font.family: Globals.font
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                        }
                                    }

                                    // Day columns
                                    Repeater {
                                        model: 7
                                        delegate: Rectangle {
                                            width: (parent.parent.width - 70) / 7
                                            height: parent.height
                                            color: "transparent"
                                            border.color: "#33" + Globals.colors.colors.color2
                                            border.width: 1

                                            property date cellDate: {
                                                const weekStart = weeklyRoot.getWeekStart(selectedDate);
                                                const day = new Date(weekStart);
                                                day.setDate(day.getDate() + index);
                                                return day;
                                            }

                                            property int cellHour: parent.hour
                                            property var hourEvents: weeklyRoot.getEventsForDateInTimeRange(cellDate, parent.hour, parent.hour + 1)

                                            Rectangle {
                                                anchors.fill: parent
                                                anchors.margins: 1
                                                color: {
                                                    const now = new Date();
                                                    const isCurrentHour = cellDate.toDateString() === now.toDateString() && cellHour === now.getHours();
                                                    if (isCurrentHour)
                                                        return "#55" + Globals.colors.colors.color11;
                                                    if (cellHour % 2 === 0)
                                                        return "#11" + Globals.colors.colors.color1;
                                                    return "transparent";
                                                }
                                                radius: 0
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                enabled: hourEvents.length === 0

                                                onClicked: {
                                                    if (hourEvents.length === 0) {
                                                        weeklyRoot.timeSlotClicked(cellDate, cellHour);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Event overlay
                        Item {
                            anchors.fill: parent
                            z: 10

                            Repeater {
                                model: 7
                                delegate: Item {
                                    x: 70 + index * ((parent.width - 70) / 7)
                                    width: (parent.width - 70) / 7
                                    height: parent.height

                                    property date columnDate: {
                                        const weekStart = weeklyRoot.getWeekStart(selectedDate);
                                        const day = new Date(weekStart);
                                        day.setDate(day.getDate() + index);
                                        return day;
                                    }

                                    // Get events for this day and handle multi-day events
                                    property var dayEvents: {
                                        // Get regular events for this day
                                        let events = PersistentEvents.getEventsForDate(columnDate);

                                        // Check for multi-day events that started on previous days
                                        // and should continue into this day
                                        const prevDayIndex = index - 1;
                                        if (prevDayIndex >= 0) {
                                            const prevDay = new Date(columnDate);
                                            prevDay.setDate(prevDay.getDate() - 1);

                                            const prevDayEvents = PersistentEvents.getEventsForDate(prevDay);
                                            for (let i = 0; i < prevDayEvents.length; i++) {
                                                const event = prevDayEvents[i];
                                                if (event.time && event.duration) {
                                                    const startHour = event.time.hour;
                                                    const startMinute = event.time.minute || 0;
                                                    const durationHours = event.duration.hours || 0;
                                                    const durationMinutes = event.duration.minutes || 0;

                                                    // Calculate if this event extends to the next day
                                                    const totalMinutes = startHour * 60 + startMinute + durationHours * 60 + durationMinutes;
                                                    if (totalMinutes > 24 * 60) {
                                                        // Create a continuation event for this day
                                                        const continuationEvent = JSON.parse(JSON.stringify(event)); // Deep copy

                                                        // Set as continuation segment
                                                        continuationEvent.isMultiDaySegment = true;
                                                        continuationEvent.isFirstSegment = false;

                                                        // Start at beginning of day
                                                        continuationEvent.time = {
                                                            hour: 0,
                                                            minute: 0
                                                        };

                                                        // Calculate remaining duration
                                                        const remainingMinutes = totalMinutes - 24 * 60;
                                                        continuationEvent.duration = {
                                                            hours: Math.floor(remainingMinutes / 60),
                                                            minutes: remainingMinutes % 60
                                                        };

                                                        events.push(continuationEvent);
                                                    }
                                                }
                                            }
                                        }

                                        return events;
                                    }

                                    // Sort events by duration (longest first) to ensure shorter events are on top
                                    property var sortedEvents: {
                                        // Create a copy of the events array to sort
                                        let events = [...dayEvents];

                                        // Process multi-day events that start on this day
                                        for (let i = 0; i < events.length; i++) {
                                            const event = events[i];
                                            if (event.time && event.duration && !event.isMultiDaySegment) {
                                                const startHour = event.time.hour;
                                                const startMinute = event.time.minute || 0;
                                                const durationHours = event.duration.hours || 0;
                                                const durationMinutes = event.duration.minutes || 0;

                                                // Calculate if this event extends to the next day
                                                const totalMinutes = startHour * 60 + startMinute + durationHours * 60 + durationMinutes;
                                                if (totalMinutes > 24 * 60) {
                                                    // Mark as first segment of multi-day event
                                                    event.isMultiDaySegment = true;
                                                    event.isFirstSegment = true;
                                                }
                                            }
                                        }

                                        // Sort by duration (longest first)
                                        events.sort((a, b) => {
                                            const aDuration = a.duration ? (a.duration.hours + (a.duration.minutes || 0) / 60) : 1;
                                            const bDuration = b.duration ? (b.duration.hours + (b.duration.minutes || 0) / 60) : 1;
                                            return bDuration - aDuration; // Descending order
                                        });

                                        return events;
                                    }

                                    Repeater {
                                        model: sortedEvents
                                        delegate: Rectangle {
                                            id: eventBlock
                                            property real startHour: modelData.time ? (modelData.time.hour + (modelData.time.minute || 0) / 60) : 0
                                            property real durationHours: modelData.duration ? (modelData.duration.hours + (modelData.duration.minutes || 0) / 60) : 1
                                            property bool isMultiDay: durationHours > 24 - startHour

                                            x: 2
                                            width: parent.width - 4
                                            y: startHour * 45
                                            height: isMultiDay ? (24 - startHour) * 45 : Math.max(20, durationHours * 45)
                                            z: index // Higher z-index for shorter events (which are later in the sorted array)

                                            color: modelData.categoryColor || "#66" + Globals.colors.colors.color6
                                            radius: 6
                                            opacity: 0.95
                                            border.color: Qt.darker(color, 1.2)
                                            border.width: 1

                                            Column {
                                                anchors.fill: parent
                                                anchors.margins: 6
                                                spacing: 2

                                                Text {
                                                    width: parent.width
                                                    text: {
                                                        let title = modelData.title || "";
                                                        if (modelData.isMultiDaySegment) {
                                                            if (modelData.isFirstSegment) {
                                                                title += " →";
                                                            } else {
                                                                title = "→ " + title;
                                                            }
                                                        }
                                                        return title;
                                                    }
                                                    color: "#FFFFFF"
                                                    font.family: Globals.font
                                                    font.pixelSize: Math.min(12, Math.max(9, eventBlock.height / 4))
                                                    font.weight: Font.Bold
                                                    maximumLineCount: parent.parent.height < 40 ? 1 : 3
                                                }

                                                Text {
                                                    width: parent.width
                                                    visible: parent.parent.height > 30
                                                    text: {
                                                        if (!modelData.time)
                                                            return "";
                                                        const startHour = modelData.time.hour % 12 === 0 ? 12 : modelData.time.hour % 12;
                                                        const startMinute = modelData.time.minute || 0;
                                                        const startAmpm = modelData.time.hour < 12 ? "AM" : "PM";
                                                        return startHour + ":" + startMinute.toString().padStart(2, '0') + " " + startAmpm;
                                                    }
                                                    color: "#E0E0E0"
                                                    font.family: Globals.font
                                                    font.pixelSize: Math.min(10, Math.max(8, parent.parent.height / 6))
                                                }
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true

                                                onEntered: {
                                                    parent.opacity = 1.0;
                                                    parent.scale = 1.02;
                                                }
                                                onExited: {
                                                    parent.opacity = 0.95;
                                                    parent.scale = 1.0;
                                                }

                                                onClicked: {
                                                    weeklyRoot.eventClicked(modelData, parent.parent.columnDate);
                                                }
                                            }

                                            Behavior on opacity {
                                                NumberAnimation {
                                                    duration: 150
                                                }
                                            }
                                            Behavior on scale {
                                                NumberAnimation {
                                                    duration: 150
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
        }
    }
}
