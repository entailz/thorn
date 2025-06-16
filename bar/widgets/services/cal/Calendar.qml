import QtQuick
import Quickshell
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import "../../components" as Components
import "root:/"

Item {
    id: calendarRoot

    property var categoryColors: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F"]
    property date selectedDate: Globals.date
    property var colors: ({})
    property bool showWeeklyView: false
    property var calendarPopup: datePopup

    signal dateSelected(date newDate)

    Item {
        id: viewContainer
        anchors.fill: parent
        clip: true

        Item {
            id: calendarView
            width: parent.width
            height: parent.height - 100
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "transparent"
                    radius: 8

                    Item {
                        id: clock
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            spacing: 2

                            Text {
                                id: timeText
                                color: "#" + Globals.colors.colors.color6
                                font.family: Globals.font
                                font.pixelSize: 37
                                font.weight: Font.Medium

                                text: {
                                    const now = new Date();
                                    const hours = now.getHours();
                                    const minutes = now.getMinutes();

                                    const displayHours = hours % 12 === 0 ? 12 : hours % 12;
                                    const formattedHours = displayHours < 10 ? "0" + displayHours : displayHours;
                                    const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;

                                    return formattedHours + "." + formattedMinutes;
                                }
                            }

                            Text {
                                id: ampmText
                                color: "#A0A0A0"
                                font.family: Globals.font
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                anchors.baseline: timeText.baseline

                                text: {
                                    const now = new Date();
                                    const hours = now.getHours();
                                    return hours < 12 ? "AM" : "PM";
                                }
                            }

                            Timer {
                                interval: 1000
                                running: true
                                repeat: true
                                onTriggered: {
                                    timeText.text = Qt.binding(function () {
                                        const now = new Date();
                                        const hours = now.getHours();
                                        const minutes = now.getMinutes();

                                        const displayHours = hours % 12 === 0 ? 12 : hours % 12;
                                        const formattedHours = displayHours < 10 ? "0" + displayHours : displayHours;
                                        const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;

                                        return formattedHours + "." + formattedMinutes;
                                    });

                                    ampmText.text = Qt.binding(function () {
                                        const now = new Date();
                                        const hours = now.getHours();
                                        return hours < 12 ? "AM" : "PM";
                                    });
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 320
                    color: "transparent"
                    radius: 8

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

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

                                        onClicked: {
                                            showWeeklyView = true;
                                        }
                                    }
                                }
                            }
                        }

                        Row {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8

                            Repeater {
                                model: ["S", "M", "T", "W", "T", "F", "S"]
                                delegate: Rectangle {
                                    width: parent.width / 7
                                    height: 36
                                    color: "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: index === 0 || index === 6 ? "#" + Globals.colors.colors.color6 : "#909090"
                                        font.family: Globals.font
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8
                            Layout.bottomMargin: 8

                            Grid {
                                anchors.fill: parent
                                columns: 7
                                rows: 6

                                property real cellWidth: width / 7
                                property real cellHeight: height / 6

                                Repeater {
                                    model: {
                                        const currentDate = new Date(calendarRoot.selectedDate);
                                        const year = currentDate.getFullYear();
                                        const month = currentDate.getMonth();

                                        const firstDayOfMonth = new Date(year, month, 1);
                                        const daysInMonth = new Date(year, month + 1, 0).getDate();
                                        const firstDay = firstDayOfMonth.getDay();
                                        const days = [];

                                        for (let i = 0; i < firstDay; i++) {
                                            days.push({
                                                day: "",
                                                isCurrentMonth: false,
                                                isSelected: false,
                                                isToday: false
                                            });
                                        }

                                        for (let i = 1; i <= daysInMonth; i++) {
                                            const dateObj = new Date(year, month, i);
                                            days.push({
                                                day: i,
                                                date: dateObj,
                                                isCurrentMonth: true,
                                                isToday: i === new Date().getDate() && month === new Date().getMonth() && year === new Date().getFullYear(),
                                                isSelected: i === calendarRoot.selectedDate.getDate() && month === calendarRoot.selectedDate.getMonth() && year === calendarRoot.selectedDate.getFullYear(),
                                                hasEvents: PersistentEvents.getEventsForDate(dateObj).length > 0
                                            });
                                        }
                                        while (days.length < 32) {
                                            days.push({
                                                day: "",
                                                isCurrentMonth: false,
                                                isSelected: false,
                                                isToday: false,
                                                hasEvents: false
                                            });
                                        }

                                        return days;
                                    }

                                    delegate: Rectangle {
                                        width: parent.cellWidth
                                        height: parent.cellHeight
                                        color: "transparent"

                                        Rectangle {
                                            visible: modelData.isSelected
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, parent.height) * 0.8
                                            height: width
                                            bottomRightRadius: 4
                                            topRightRadius: 12
                                            topLeftRadius: 12
                                            bottomLeftRadius: 4
                                            color: "#505050"
                                        }

                                        Rectangle {
                                            visible: modelData.isToday && !modelData.isSelected
                                            anchors.centerIn: parent
                                            width: Math.min(parent.width, parent.height) * 0.8
                                            height: width
                                            radius: width / 2
                                            color: "transparent"
                                            border.color: "#707070"
                                            border.width: 1
                                        }

                                        Rectangle {
                                            visible: modelData.hasEvents && modelData.isCurrentMonth
                                            anchors.bottom: parent.bottom
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.bottomMargin: 4
                                            width: 6
                                            height: 6
                                            radius: 3
                                            color: "#" + Globals.colors.colors.color11
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.day
                                            color: {
                                                if (!modelData.isCurrentMonth)
                                                    return "#404040";
                                                if (modelData.isSelected)
                                                    return "#FFFFFF";
                                                const dayOfWeek = (index % 7);
                                                if (dayOfWeek === 0 || dayOfWeek === 6)
                                                    return "#" + Globals.colors.colors.color11;
                                                return "#C0C0C0";
                                            }
                                            font.family: Globals.font
                                            font.pixelSize: 14
                                            font.weight: modelData.isToday || modelData.isSelected ? Font.Medium : Font.Normal
                                        }

                                        MouseArea {
                                            cursorShape: Qt.PointingHandCursor
                                            anchors.fill: parent

                                            onDoubleClicked: {
                                                if (datePopup.visible) {
                                                    datePopup.closeWithAnimation();
                                                } else {
                                                    if (modelData && modelData.isCurrentMonth) {
                                                        calendarRoot.selectedDate = modelData.date;
                                                        calendarRoot.dateSelected(modelData.date);
                                                        datePopup.selectedDate = modelData.date;
                                                        datePopup.show();
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

        Rectangle {
            id: plannerContainer
            width: parent.width
            height: parent.height
            x: showWeeklyView ? 0 : width
            color: "transparent"

            Behavior on x {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }
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

            function getAppointmentsForDateAndHour(date, hour) {
                return getEventsForDateInTimeRange(date, hour, hour + 1).filter(event => event.type === "appointment");
            }

            function calculateEventPosition(event, slotHour) {
                if (!event.time || !event.duration) {
                    return {
                        top: 0,
                        height: 43
                    };
                }

                const eventStartMinutes = event.time.hour * 60 + (event.time.minute || 0);
                const eventDurationMinutes = (event.duration.hours || 0) * 60 + (event.duration.minutes || 0);
                const eventEndMinutes = eventStartMinutes + eventDurationMinutes;

                const slotStartMinutes = slotHour * 60;
                const slotEndMinutes = (slotHour + 1) * 60;

                const visibleStartMinutes = Math.max(eventStartMinutes, slotStartMinutes);
                const visibleEndMinutes = Math.min(eventEndMinutes, slotEndMinutes);
                const visibleDurationMinutes = visibleEndMinutes - visibleStartMinutes;

                const slotHeight = 43;
                const minutesPerPixel = 60 / slotHeight;

                const topOffset = (visibleStartMinutes - slotStartMinutes) / minutesPerPixel;
                const height = visibleDurationMinutes / minutesPerPixel;

                return {
                    top: Math.max(0, topOffset),
                    height: Math.max(5, height)
                };
            }

            function getWeekStart(date) {
                const d = new Date(date);
                const day = d.getDay();
                const diff = d.getDate() - day;
                return new Date(d.setDate(diff));
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

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
                                const weekStart = plannerContainer.getWeekStart(selectedDate);
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
                            id: rightArrow
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    color: "transparent"
                    border.color: "#44" + Globals.colors.colors.color2
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        clip: true

                        ScrollBar.vertical.background: null
                        ScrollBar.vertical.contentItem: null

                        contentWidth: plannerContainer.width - 32
                        contentHeight: 24 * 45 + 70

                        Item {
                            width: plannerContainer.width - 32
                            height: Math.max(24 * 45 + 70, plannerContainer.height - 120)

                            Row {
                                id: daysHeader
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 70

                                Rectangle {
                                    width: 70
                                    height: parent.height
                                    color: "transparent"
                                    // color: "#44" + Globals.colors.colors.color2
                                    border.color: "#55" + Globals.colors.colors.color3
                                    border.width: 1
                                    // radius: 4

                                    Components.IconButton {
                                        icon: "calendar-symbolic"
                                        anchors.centerIn: parent
                                        padding: 10
                                        size: 16
                                        clickable: true
                                        // MouseArea {
                                        //     id: plannerView
                                        //     anchors.fill: parent
                                        //     hoverEnabled: true
                                        //     cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            showWeeklyView = false;
                                        }
                                    }
                                }

                                Repeater {
                                    model: 7
                                    delegate: Rectangle {
                                        width: (parent.width - 38) / 7
                                        height: parent.height
                                        color: "transparent"
                                        // color: "#44" + Globals.colors.colors.color2
                                        border.color: "#55" + Globals.colors.colors.color3
                                        border.width: 1

                                        property date dayDate: {
                                            const weekStart = plannerContainer.getWeekStart(selectedDate);
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
                            Item {
                                anchors.top: daysHeader.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 24 * 45

                                Column {
                                    id: contentColumn
                                    width: parent.width

                                    Repeater {
                                        model: 24 // 24 hours
                                        delegate: Row {
                                            width: parent.width
                                            height: 45

                                            property int hour: index

                                            Rectangle {
                                                width: 70
                                                height: parent.height
                                                color: "transparent"
                                                // color: "#33" + Globals.colors.colors.color1
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

                                            Repeater {
                                                model: 7
                                                delegate: Rectangle {
                                                    width: (contentColumn.width - 38) / 7
                                                    height: parent.height
                                                    color: "transparent"
                                                    border.color: "#33" + Globals.colors.colors.color2
                                                    border.width: 1

                                                    property date cellDate: {
                                                        const weekStart = plannerContainer.getWeekStart(selectedDate);
                                                        const day = new Date(weekStart);
                                                        day.setDate(day.getDate() + index);
                                                        return day;
                                                    }

                                                    property int cellHour: parent.hour
                                                    property var hourEvents: plannerContainer.getEventsForDateInTimeRange(cellDate, parent.hour, parent.hour + 1)

                                                    Rectangle {
                                                        id: hourSlotBackground
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
                                                        id: addApptMouseArea
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        acceptedButtons: Qt.LeftButton
                                                        hoverEnabled: true
                                                        enabled: hourEvents.length === 0
                                                        z: 1

                                                        onEntered: {
                                                            if (hourEvents.length === 0) {
                                                                hourSlotBackground.color = "#22" + Globals.colors.colors.color3;
                                                            }
                                                        }

                                                        onExited: {
                                                            if (hourEvents.length === 0) {
                                                                const now = new Date();
                                                                const isCurrentHour = cellDate.toDateString() === now.toDateString() && cellHour === now.getHours();
                                                                if (isCurrentHour) {
                                                                    hourSlotBackground.color = "#55" + Globals.colors.colors.color11;
                                                                } else if (cellHour % 2 === 0) {
                                                                    hourSlotBackground.color = "#11" + Globals.colors.colors.color1;
                                                                } else {
                                                                    hourSlotBackground.color = "transparent";
                                                                }
                                                            }
                                                        }

                                                        onClicked: {
                                                            if (hourEvents.length === 0) {
                                                                datePopup.selectedDate = cellDate;

                                                                if (datePopup.hourSpinBox) {
                                                                    datePopup.hourSpinBox.value = cellHour;
                                                                }
                                                                if (datePopup.minuteSpinBox) {
                                                                    datePopup.minuteSpinBox.value = 0;
                                                                }

                                                                datePopup.show();

                                                                if (datePopup.titleField) {
                                                                    datePopup.titleField.focus = true;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    id: overlayBlock
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    height: parent.height
                                    z: 10

                                    function getEventsForDateWithSegments(date) {
                                        let allEvents = [];

                                        const directEvents = PersistentEvents.getEventsForDate(date);

                                        for (let i = 0; i < directEvents.length; i++) {
                                            const event = directEvents[i];

                                            if (!event.time || !event.duration) {
                                                allEvents.push(event);
                                                continue;
                                            }

                                            const eventStart = new Date(date);
                                            eventStart.setHours(event.time.hour, event.time.minute || 0, 0, 0);

                                            const eventEnd = new Date(eventStart);
                                            eventEnd.setHours(eventEnd.getHours() + (event.duration.hours || 0));
                                            eventEnd.setMinutes(eventEnd.getMinutes() + (event.duration.minutes || 0));

                                            if (eventEnd.getDate() !== eventStart.getDate() || eventEnd.getMonth() !== eventStart.getMonth() || eventEnd.getFullYear() !== eventStart.getFullYear()) {
                                                const endOfDay = new Date(date);
                                                endOfDay.setHours(23, 59, 59, 999);

                                                const segmentEnd = new Date(Math.min(eventEnd.getTime(), endOfDay.getTime()));
                                                const segmentDurationMs = segmentEnd.getTime() - eventStart.getTime();
                                                const segmentDurationHours = Math.floor(segmentDurationMs / (1000 * 60 * 60));
                                                const segmentDurationMinutes = Math.floor((segmentDurationMs % (1000 * 60 * 60)) / (1000 * 60));

                                                const segmentEvent = {
                                                    id: event.id,
                                                    title: event.title,
                                                    type: event.type,
                                                    categoryColor: event.categoryColor,
                                                    category: event.category,
                                                    time: {
                                                        hour: event.time.hour,
                                                        minute: event.time.minute || 0
                                                    },
                                                    duration: {
                                                        hours: segmentDurationHours,
                                                        minutes: segmentDurationMinutes
                                                    },
                                                    isMultiDaySegment: true,
                                                    isFirstSegment: true
                                                };

                                                allEvents.push(segmentEvent);
                                            } else {
                                                allEvents.push(event);
                                            }
                                        }

                                        const previousDay = new Date(date);
                                        previousDay.setDate(previousDay.getDate() - 1);
                                        const previousDayEvents = PersistentEvents.getEventsForDate(previousDay);

                                        for (let i = 0; i < previousDayEvents.length; i++) {
                                            const event = previousDayEvents[i];

                                            if (!event.time || !event.duration) {
                                                continue;
                                            }

                                            const eventStart = new Date(previousDay);
                                            eventStart.setHours(event.time.hour, event.time.minute || 0, 0, 0);

                                            const eventEnd = new Date(eventStart);
                                            eventEnd.setHours(eventEnd.getHours() + (event.duration.hours || 0));
                                            eventEnd.setMinutes(eventEnd.getMinutes() + (event.duration.minutes || 0));

                                            if (eventEnd.getDate() === date.getDate() && eventEnd.getMonth() === date.getMonth() && eventEnd.getFullYear() === date.getFullYear()) {
                                                const startOfDay = new Date(date);
                                                startOfDay.setHours(0, 0, 0, 0);

                                                const segmentDurationMs = eventEnd.getTime() - startOfDay.getTime();
                                                const segmentDurationHours = Math.floor(segmentDurationMs / (1000 * 60 * 60));
                                                const segmentDurationMinutes = Math.floor((segmentDurationMs % (1000 * 60 * 60)) / (1000 * 60));

                                                const continuationEvent = {
                                                    id: event.id + "_cont",
                                                    title: event.title,
                                                    type: event.type,
                                                    categoryColor: event.categoryColor,
                                                    category: event.category,
                                                    time: {
                                                        hour: 0,
                                                        minute: 0
                                                    },
                                                    duration: {
                                                        hours: segmentDurationHours,
                                                        minutes: segmentDurationMinutes
                                                    },
                                                    isMultiDaySegment: true,
                                                    isFirstSegment: false,
                                                    originalEventId: event.id
                                                };

                                                allEvents.push(continuationEvent);
                                            }
                                        }

                                        return allEvents;
                                    }

                                    Repeater {
                                        model: 7
                                        delegate: Item {
                                            id: eventsDay
                                            x: 70 + index * ((parent.width - 38) / 7)
                                            width: (parent.width - 40) / 7
                                            height: parent.height

                                            property date columnDate: {
                                                const weekStart = plannerContainer.getWeekStart(selectedDate);
                                                const day = new Date(weekStart);
                                                day.setDate(day.getDate() + index);
                                                return day;
                                            }

                                            property var dayEvents: overlayBlock.getEventsForDateWithSegments(columnDate)

                                            Repeater {
                                                model: dayEvents
                                                delegate: Rectangle {
                                                    id: eventBlock

                                                    property real startHour: modelData.time ? (modelData.time.hour + (modelData.time.minute || 0) / 60) : 0
                                                    property real durationHours: modelData.duration ? (modelData.duration.hours + (modelData.duration.minutes || 0) / 60) : 1
                                                    property real endHour: startHour + durationHours

                                                    x: 2
                                                    width: parent.width - 4
                                                    y: startHour * 45
                                                    height: Math.max(20, durationHours * 45)

                                                    color: modelData.categoryColor || "#66" + Globals.colors.colors.color6
                                                    radius: 6
                                                    opacity: 0.95
                                                    border.color: Qt.darker(modelData.categoryColor || "#66" + Globals.colors.colors.color6, 1.2)
                                                    border.width: 1

                                                    Rectangle {
                                                        visible: modelData.isMultiDaySegment || false
                                                        anchors.right: parent.right
                                                        anchors.top: parent.top
                                                        anchors.bottom: parent.bottom
                                                        width: 3
                                                        color: Qt.lighter(parent.color, 1.3)
                                                        radius: 1
                                                    }

                                                    Rectangle {
                                                        anchors.fill: parent
                                                        anchors.topMargin: 2
                                                        anchors.leftMargin: 2
                                                        color: "#40000000"
                                                        radius: parent.radius
                                                        z: -1
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
                                                            maximumLineCount: eventBlock.height < 40 ? 1 : 3
                                                        }

                                                        Text {
                                                            width: parent.width
                                                            visible: eventBlock.height > 30
                                                            text: {
                                                                if (!modelData.time)
                                                                    return "";
                                                                const startHour = modelData.time.hour % 12 === 0 ? 12 : modelData.time.hour % 12;
                                                                const startMinute = modelData.time.minute || 0;
                                                                const startAmpm = modelData.time.hour < 12 ? "AM" : "PM";

                                                                let endTime = "";
                                                                if (modelData.duration) {
                                                                    const totalMinutes = (modelData.time.hour * 60) + (modelData.time.minute || 0) + (modelData.duration.hours * 60) + (modelData.duration.minutes || 0);
                                                                    const endHourRaw = Math.floor(totalMinutes / 60) % 24;
                                                                    const endMinuteRaw = totalMinutes % 60;
                                                                    const endHour = endHourRaw % 12 === 0 ? 12 : endHourRaw % 12;
                                                                    const endAmpm = endHourRaw < 12 ? "AM" : "PM";
                                                                    endTime = " - " + endHour + ":" + endMinuteRaw.toString().padStart(2, '0') + " " + endAmpm;
                                                                }

                                                                return startHour + ":" + startMinute.toString().padStart(2, '0') + " " + startAmpm + endTime;
                                                            }
                                                            color: "#E0E0E0"
                                                            font.family: Globals.font
                                                            font.pixelSize: Math.min(10, Math.max(8, eventBlock.height / 6))
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
                                                            let eventDate = eventsDay.columnDate;
                                                            if (modelData.isMultiDaySegment && !modelData.isFirstSegment) {
                                                                eventDate = new Date(eventsDay.columnDate);
                                                                eventDate.setDate(eventDate.getDate() - 1);
                                                            }

                                                            datePopup.selectedDate = eventDate;
                                                            datePopup.show();
                                                        }

                                                        onDoubleClicked: {
                                                            let eventDate = eventsDay.columnDate;
                                                            if (modelData.isMultiDaySegment && !modelData.isFirstSegment) {
                                                                eventDate = new Date(eventsDay.columnDate);
                                                                eventDate.setDate(eventDate.getDate() - 1);
                                                            }

                                                            datePopup.selectedDate = eventDate;
                                                            datePopup.show();
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
                    Components.SlidingPopup {
                        id: datePopup
                        visible: false
                        implicitWidth: 400
                        anchor.item: calendarRoot
                        color: "transparent"
                        anchor.rect.x: 505
                        direction: "right"
                        // anchor.rect.y: 50
                        property bool isEditMode: false
                        property var editingEvent: null
                        property string editingEventId: ""
                        property bool notesExpanded: false

                        property int easingType: Easing.OutCubic

                        property date selectedDate: new Date()

                        implicitHeight: {
                            const baseHeight = 160;
                            const eventsCount = PersistentEvents.getEventsForDate(selectedDate).length;
                            const eventHeight = 88;
                            const maxEventsVisible = 4;
                            const eventsHeight = Math.min(eventsCount, maxEventsVisible) * eventHeight;
                            const addEventSectionHeight = datePopup.isEditMode ? 280 : 280;
                            const notesHeight = datePopup.notesExpanded ? 100 : 0;

                            return baseHeight + eventsHeight + addEventSectionHeight + notesHeight;
                        }

                        Behavior on implicitHeight {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutQuad
                            }
                        }

                        function openForEdit(event) {
                            isEditMode = true;
                            editingEvent = event;
                            editingEventId = event.id;

                            titleField.text = event.title || "";
                            notesField.text = event.notes || "";
                            notesExpanded = event.notes && event.notes.trim() !== "";

                            if (event.time) {
                                startHourSpinBox.value = event.time.hour || 0;
                                startMinuteSpinBox.value = event.time.minute || 0;

                                if (event.duration) {
                                    const startTotalMinutes = (event.time.hour || 0) * 60 + (event.time.minute || 0);
                                    const durationMinutes = (event.duration.hours || 0) * 60 + (event.duration.minutes || 0);
                                    const endTotalMinutes = startTotalMinutes + durationMinutes;

                                    endHourSpinBox.value = Math.floor(endTotalMinutes / 60) % 24;
                                    endMinuteSpinBox.value = endTotalMinutes % 60;
                                } else {
                                    const endTotalMinutes = ((event.time.hour || 0) * 60 + (event.time.minute || 0)) + 60;
                                    endHourSpinBox.value = Math.floor(endTotalMinutes / 60) % 24;
                                    endMinuteSpinBox.value = endTotalMinutes % 60;
                                }
                            }

                            if (event.categoryColor) {
                                for (let i = 0; i < calendarRoot.categoryColors.length; i++) {
                                    if (calendarRoot.categoryColors[i] === event.categoryColor) {
                                        colorFlow.selectedColorIndex = i;
                                        break;
                                    }
                                }
                            }

                            datePopup.show();
                            titleField.focus = true;
                        }

                        function resetEditMode() {
                            isEditMode = false;
                            editingEvent = null;
                            editingEventId = "";
                            notesExpanded = false;

                            titleField.text = "";
                            notesField.text = "";
                            startHourSpinBox.value = 9;
                            startMinuteSpinBox.value = 0;
                            endHourSpinBox.value = 10;
                            endMinuteSpinBox.value = 0;

                            colorFlow.selectedColorIndex = 0;
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "#99" + Globals.colors.colors.color0
                            radius: 12
                            border {
                                width: 1
                                color: "#11" + Globals.colors.colors.color6
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 16

                                Text {
                                    Layout.fillWidth: true
                                    text: datePopup.isEditMode ? ("Edit Event - " + datePopup.selectedDate.toLocaleDateString()) : ("Events for " + datePopup.selectedDate.toLocaleDateString())
                                    color: "#" + Globals.colors.colors.color8
                                    font.family: Globals.font
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: {
                                        const eventsCount = PersistentEvents.getEventsForDate(datePopup.selectedDate).length;
                                        if (eventsCount === 0)
                                            return 40;
                                        const eventHeight = 88;
                                        const maxEventsVisible = 4;
                                        return Math.min(eventsCount, maxEventsVisible) * eventHeight;
                                    }
                                    Layout.minimumHeight: 40
                                    clip: true

                                    ListView {
                                        model: PersistentEvents.getEventsForDate(datePopup.selectedDate)
                                        spacing: 8

                                        delegate: ClippingRectangle {
                                            width: parent ? parent.width : 360
                                            contentUnderBorder: true
                                            height: 80
                                            color: "#33" + Globals.colors.colors.color1
                                            border.color: "#44" + Globals.colors.colors.color2
                                            border.width: 1
                                            radius: 8

                                            layer.enabled: true
                                            layer.effect: DropShadow {
                                                transparentBorder: true
                                                smooth: true
                                                antialiasing: true
                                                radius: 16
                                                spread: 0.01
                                                cached: true
                                                samples: 20
                                                color: "#20000000"
                                            }

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 12
                                                spacing: 12

                                                Rectangle {
                                                    Layout.preferredWidth: 4
                                                    Layout.fillHeight: true
                                                    color: modelData.categoryColor || "#" + Globals.colors.colors.color6
                                                    radius: 2
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 4

                                                    Text {
                                                        text: modelData.title || "Untitled Event"
                                                        color: "#FFFFFF"
                                                        font.family: Globals.font
                                                        font.pixelSize: 14

                                                        Layout.preferredWidth: 200
                                                        elide: Text.ElideRight
                                                        font.weight: Font.Medium
                                                    }

                                                    Text {
                                                        text: {
                                                            if (modelData.time) {
                                                                const hour = modelData.time.hour % 12 === 0 ? 12 : modelData.time.hour % 12;
                                                                const minute = modelData.time.minute || 0;
                                                                const ampm = modelData.time.hour < 12 ? "AM" : "PM";
                                                                let timeStr = hour + ":" + minute.toString().padStart(2, '0') + " " + ampm;

                                                                if (modelData.duration) {
                                                                    const totalStartMinutes = modelData.time.hour * 60 + minute;
                                                                    const durationMinutes = (modelData.duration.hours || 0) * 60 + (modelData.duration.minutes || 0);
                                                                    const totalEndMinutes = totalStartMinutes + durationMinutes;
                                                                    const endHour = Math.floor(totalEndMinutes / 60) % 24;
                                                                    const endMinute = totalEndMinutes % 60;
                                                                    const endHour12 = endHour % 12 === 0 ? 12 : endHour % 12;
                                                                    const endAmPm = endHour < 12 ? "AM" : "PM";

                                                                    timeStr += " - " + endHour12 + ":" + endMinute.toString().padStart(2, '0') + " " + endAmPm;
                                                                }

                                                                return timeStr;
                                                            }
                                                            return "All Day";
                                                        }
                                                        color: "#B0B0B0"
                                                        font.family: Globals.font
                                                        font.pixelSize: 12
                                                    }
                                                    Text {
                                                        text: modelData.notes
                                                        visible: modelData.notes != ""
                                                        font.pixelSize: 10
                                                        font.family: Globals.secondaryFont
                                                        color: "#" + Globals.colors.colors.color8
                                                        Layout.preferredWidth: 200
                                                        elide: Text.ElideRight
                                                        wrapMode: Text.NoWrap
                                                    }
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Components.IconButton {
                                                    Layout.preferredWidth: 30
                                                    Layout.preferredHeight: 30
                                                    icon: "edit_calendar"
                                                    useVariableFill: true
                                                    clickable: true
                                                    size: 16
                                                    onClicked: {
                                                        datePopup.openForEdit(modelData);
                                                    }
                                                }

                                                Components.IconButton {
                                                    Layout.preferredWidth: 30
                                                    Layout.preferredHeight: 30
                                                    icon: "delete"
                                                    useVariableFill: true
                                                    clickable: true
                                                    size: 16
                                                    onClicked: {
                                                        PersistentEvents.removeEvent(datePopup.selectedDate, modelData.id);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 300
                                    Layout.preferredHeight: datePopup.notesExpanded ? 380 : 280
                                    color: "#15" + Globals.colors.colors.color1

                                    radius: 12
                                    border.width: 1
                                    border.color: "#20" + Globals.colors.colors.color6

                                    Behavior on Layout.preferredHeight {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutQuad
                                        }
                                    }

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        Text {
                                            text: datePopup.isEditMode ? "Edit Event" : "New Appointment"
                                            color: "#" + Globals.colors.colors.color6
                                            font.family: Globals.font
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }

                                        TextField {
                                            id: titleField
                                            Layout.fillWidth: true
                                            placeholderText: "Event title..."
                                            color: "#FFFFFF"
                                            font.family: Globals.font
                                            font.pixelSize: 12

                                            background: Rectangle {
                                                color: "#04" + Globals.colors.colors.color9
                                                radius: 4
                                                border.color: parent.focus ? "#" + Globals.colors.colors.color6 : "#606060"
                                                border.width: 1
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 24

                                            Column {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                Text {
                                                    text: "Start Time:"
                                                    color: "#" + Globals.colors.colors.color7
                                                    font.family: Globals.secondaryFont
                                                    font.pixelSize: 12
                                                }

                                                Row {
                                                    spacing: 12

                                                    SpinBox {
                                                        id: startHourSpinBox
                                                        from: 0
                                                        to: 23
                                                        value: 9

                                                        contentItem: TextInput {
                                                            text: {
                                                                const hour = parent.value % 12 === 0 ? 12 : parent.value % 12;
                                                                const ampm = parent.value < 12 ? " AM" : " PM";
                                                                return hour.toString().padStart(2, '0') + ampm;
                                                            }
                                                            color: "#FFFFFF"
                                                            font.family: Globals.font
                                                            font.pixelSize: 12
                                                            horizontalAlignment: Qt.AlignHCenter
                                                            verticalAlignment: Qt.AlignVCenter
                                                            readOnly: true
                                                        }

                                                        background: Rectangle {
                                                            color: "#40404040"
                                                            radius: 4
                                                            border.color: "#606060"
                                                            border.width: 1
                                                        }
                                                    }

                                                    Text {
                                                        text: ":"
                                                        color: "#A0A0A0"
                                                        font.family: Globals.secondaryFont
                                                        font.pixelSize: 16
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    SpinBox {
                                                        id: startMinuteSpinBox
                                                        from: 0
                                                        to: 59
                                                        value: 0
                                                        stepSize: 15

                                                        contentItem: TextInput {
                                                            text: parent.value.toString().padStart(2, '0')
                                                            color: "#FFFFFF"
                                                            font.family: Globals.font
                                                            font.pixelSize: 12
                                                            horizontalAlignment: Qt.AlignHCenter
                                                            verticalAlignment: Qt.AlignVCenter
                                                            readOnly: true
                                                        }

                                                        background: Rectangle {
                                                            color: "#40404040"
                                                            radius: 4
                                                            border.color: "#606060"
                                                            border.width: 1
                                                        }
                                                    }
                                                }
                                            }

                                            Column {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                Text {
                                                    text: "End Time:"
                                                    color: "#" + Globals.colors.colors.color7
                                                    font.family: Globals.secondaryFont
                                                    font.pixelSize: 12
                                                }

                                                Row {
                                                    spacing: 12

                                                    SpinBox {
                                                        id: endHourSpinBox
                                                        from: 0
                                                        to: 23
                                                        value: 10

                                                        contentItem: TextInput {
                                                            text: {
                                                                const hour = parent.value % 12 === 0 ? 12 : parent.value % 12;
                                                                const ampm = parent.value < 12 ? " AM" : " PM";
                                                                return hour.toString().padStart(2, '0') + ampm;
                                                            }
                                                            color: "#FFFFFF"
                                                            font.family: Globals.font
                                                            font.pixelSize: 12
                                                            horizontalAlignment: Qt.AlignHCenter
                                                            verticalAlignment: Qt.AlignVCenter
                                                            readOnly: true
                                                        }

                                                        background: Rectangle {
                                                            color: "#40404040"
                                                            radius: 4
                                                            border.color: "#606060"
                                                            border.width: 1
                                                        }
                                                    }

                                                    Text {
                                                        text: ":"
                                                        color: "#A0A0A0"
                                                        font.family: Globals.secondaryFont
                                                        font.pixelSize: 16
                                                        verticalAlignment: Text.AlignVCenter
                                                    }

                                                    SpinBox {
                                                        id: endMinuteSpinBox
                                                        from: 0
                                                        to: 59
                                                        value: 0
                                                        stepSize: 15

                                                        contentItem: TextInput {
                                                            text: parent.value.toString().padStart(2, '0')
                                                            color: "#FFFFFF"
                                                            font.family: Globals.font
                                                            font.pixelSize: 12
                                                            horizontalAlignment: Qt.AlignHCenter
                                                            verticalAlignment: Qt.AlignVCenter
                                                            readOnly: true
                                                        }

                                                        background: Rectangle {
                                                            color: "#40404040"
                                                            radius: 4
                                                            border.color: "#606060"
                                                            border.width: 1
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            Text {
                                                text: "Color:"
                                                color: "#B0B0B0"
                                                font.family: Globals.font
                                                font.pixelSize: 12
                                            }

                                            Flow {
                                                id: colorFlow
                                                Layout.fillWidth: true
                                                width: parent.width
                                                spacing: 8

                                                property int selectedColorIndex: 0

                                                Repeater {
                                                    model: calendarRoot.categoryColors

                                                    Rectangle {
                                                        width: 16
                                                        height: 16
                                                        radius: 14
                                                        color: modelData
                                                        border.color: colorFlow.selectedColorIndex === index ? "#FFFFFF" : "transparent"
                                                        border.width: colorFlow.selectedColorIndex === index ? 2 : 0

                                                        Rectangle {
                                                            anchors.centerIn: parent
                                                            width: 12
                                                            height: 12
                                                            radius: 6
                                                            color: "transparent"
                                                            border.color: "#FFFFFF"
                                                            border.width: 2
                                                            visible: colorFlow.selectedColorIndex === index
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: {
                                                                colorFlow.selectedColorIndex = index;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            spacing: 8

                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 12

                                                Text {
                                                    text: "Add Note:"
                                                    color: "#B0B0B0"
                                                    font.family: Globals.font
                                                    font.pixelSize: 12
                                                }

                                                Item {
                                                    Layout.fillWidth: true
                                                }

                                                Rectangle {
                                                    width: 40
                                                    height: 20
                                                    radius: 10
                                                    color: datePopup.notesExpanded ? "#50" + Globals.colors.colors.color9 : "#30" + Globals.colors.colors.color8
                                                    border.width: 1
                                                    border.color: "#40" + Globals.colors.colors.color6

                                                    Behavior on color {
                                                        ColorAnimation {
                                                            duration: 200
                                                        }
                                                    }

                                                    Rectangle {
                                                        width: 16
                                                        height: 16
                                                        radius: 8
                                                        color: "#FFFFFF"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        x: datePopup.notesExpanded ? parent.width - width - 2 : 2

                                                        Behavior on x {
                                                            NumberAnimation {
                                                                duration: 200
                                                                easing.type: Easing.OutQuad
                                                            }
                                                        }
                                                    }

                                                    MouseArea {
                                                        anchors.fill: parent
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            datePopup.notesExpanded = !datePopup.notesExpanded;
                                                        }
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                Layout.fillWidth: true
                                                implicitWidth: parent.width
                                                implicitHeight: datePopup.notesExpanded ? 80 : 2
                                                color: "#04" + Globals.colors.colors.color9
                                                radius: 4
                                                border.color: notesField.focus ? "#" + Globals.colors.colors.color6 : "#606060"
                                                border.width: 1
                                                clip: true

                                                Behavior on height {
                                                    NumberAnimation {
                                                        duration: 250
                                                        easing.type: Easing.OutQuad
                                                    }
                                                }

                                                ScrollView {
                                                    anchors.fill: parent
                                                    anchors.margins: 8
                                                    clip: true

                                                    TextArea {
                                                        id: notesField
                                                        placeholderText: "Optional notes..."
                                                        color: "#FFFFFF"
                                                        font.family: Globals.font
                                                        font.pixelSize: 12
                                                        wrapMode: Text.Wrap
                                                        selectByMouse: true
                                                        background: Rectangle {
                                                            color: "transparent"
                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            spacing: 12

                                            Button {
                                                text: datePopup.isEditMode ? "Update Event" : "Save Event"
                                                enabled: titleField.text.trim() !== ""

                                                background: Rectangle {
                                                    color: parent.enabled ? "#50" + Globals.colors.colors.color9 : "#20" + Globals.colors.colors.color8
                                                    radius: 6
                                                    border.width: 1
                                                    border.color: saveButton.containsMouse ? "#40" + Globals.colors.colors.color9 : "#20" + Globals.colors.colors.color6
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    color: parent.enabled ? "#FFFFFF" : "#808080"
                                                    font.family: Globals.font
                                                    font.pixelSize: 12
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                MouseArea {
                                                    id: saveButton
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        if (titleField.text.trim() !== "") {
                                                            const selectedIndex = colorFlow.selectedColorIndex;

                                                            const startTotalMinutes = startHourSpinBox.value * 60 + startMinuteSpinBox.value;
                                                            const endTotalMinutes = endHourSpinBox.value * 60 + endMinuteSpinBox.value;

                                                            let durationMinutes;
                                                            if (endTotalMinutes >= startTotalMinutes) {
                                                                durationMinutes = endTotalMinutes - startTotalMinutes;
                                                            } else {
                                                                durationMinutes = (24 * 60) - startTotalMinutes + endTotalMinutes;
                                                            }

                                                            const event = {
                                                                id: datePopup.isEditMode ? datePopup.editingEventId : Date.now().toString(),
                                                                type: "appointment",
                                                                title: titleField.text.trim(),
                                                                notes: notesField.text.trim(),
                                                                time: {
                                                                    hour: startHourSpinBox.value,
                                                                    minute: startMinuteSpinBox.value
                                                                },
                                                                duration: {
                                                                    hours: Math.floor(durationMinutes / 60),
                                                                    minutes: durationMinutes % 60
                                                                },
                                                                category: selectedIndex,
                                                                categoryColor: calendarRoot.categoryColors[selectedIndex],
                                                                created: datePopup.isEditMode ? datePopup.editingEvent.created : new Date()
                                                            };

                                                            if (datePopup.isEditMode) {
                                                                PersistentEvents.removeEvent(datePopup.selectedDate, datePopup.editingEventId);
                                                            }

                                                            PersistentEvents.addEvent(datePopup.selectedDate, event);
                                                            datePopup.resetEditMode();
                                                        }
                                                    }
                                                }
                                            }

                                            Button {
                                                text: datePopup.isEditMode ? "Cancel Edit" : "Close"

                                                background: Rectangle {
                                                    color: closeButton.containsMouse ? "#50" + Globals.colors.colors.color9 : "#20" + Globals.colors.colors.color8
                                                    radius: 6
                                                    border.width: 1
                                                    border.color: closeButton.containsMouse ? "#40" + Globals.colors.colors.color9 : "#20" + Globals.colors.colors.color6
                                                }

                                                contentItem: Text {
                                                    text: parent.text
                                                    color: "#FFFFFF"
                                                    font.family: Globals.secondaryFont
                                                    font.pixelSize: 13
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignVCenter
                                                }

                                                MouseArea {
                                                    id: closeButton
                                                    cursorShape: Qt.PointingHandCursor
                                                    anchors.fill: parent
                                                    hoverEnabled: true

                                                    onClicked: {
                                                        if (datePopup.isEditMode) {
                                                            datePopup.resetEditMode();
                                                        } else {
                                                            titleField.text = "";
                                                            colorFlow.selectedColorIndex = 0;
                                                            datePopup.closeWithAnimation();
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
    }
}
