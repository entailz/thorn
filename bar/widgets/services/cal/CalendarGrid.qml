import QtQuick
import qs

Item {
    id: gridRoot

    property date selectedDate: new Date()
    property date displayDate: selectedDate

    signal dateClicked(date clickedDate)
    signal dateDoubleClicked(date clickedDate)

    readonly property var monthData: {
        const year = displayDate.getFullYear();
        const month = displayDate.getMonth();
        const firstDay = new Date(year, month, 1);
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const startDay = firstDay.getDay();
        const today = new Date();

        let days = [];

        // Empty cells for previous month
        for (let i = 0; i < startDay; i++) {
            days.push({
                day: "",
                isCurrentMonth: false,
                isToday: false,
                isSelected: false
            });
        }

        // Days of current month
        for (let i = 1; i <= daysInMonth; i++) {
            const date = new Date(year, month, i);
            const events = PersistentEvents ? PersistentEvents.getEventsForDate(date) : [];
            days.push({
                day: i,
                date: date,
                isCurrentMonth: true,
                isToday: date.toDateString() === today.toDateString(),
                isSelected: date.toDateString() === selectedDate.toDateString(),
                hasEvents: events && events.length > 0
            });
        }

        // Fill remaining cells
        while (days.length < 42) {
            days.push({
                day: "",
                isCurrentMonth: false,
                isToday: false,
                isSelected: false
            });
        }

        return days;
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // Day headers
        Row {
            width: parent.width
            height: 36

            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                delegate: Rectangle {
                    width: parent.width / 7
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: (index === 0 || index === 6) ? "#909090" : "#909090"
                        font.family: Globals.font
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                }
            }
        }

        // Calendar grid
        Grid {
            width: parent.width
            height: parent.height - 36
            columns: 7
            rows: 6

            Repeater {
                model: gridRoot.monthData
                delegate: Rectangle {
                    width: parent.width / 7
                    height: parent.height / 6
                    color: "transparent"

                    // Selection highlight
                    Rectangle {
                        visible: modelData.isSelected
                        anchors.centerIn: parent
                        width: Math.min(parent.width, parent.height) * 0.8
                        height: width
                        radius: 8
                        color: "#505050"
                    }

                    // Today indicator
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

                    // Event indicator
                    Rectangle {
                        visible: modelData.hasEvents === true
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: 4
                        width: 6
                        height: 6
                        radius: 3
                        color: "#909090"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        color: {
                            if (!modelData.isCurrentMonth)
                                return "#404040";
                            if (modelData.isSelected)
                                return "#FFFFFF";
                            const dayOfWeek = index % 7;
                            if (dayOfWeek === 0 || dayOfWeek === 6)
                                return "#909090";
                            return "#C0C0C0";
                        }
                        font.family: Globals.font
                        font.pixelSize: 14
                        font.weight: (modelData.isToday || modelData.isSelected) ? Font.Medium : Font.Normal
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            if (modelData.isCurrentMonth) {
                                gridRoot.dateClicked(modelData.date);
                            }
                        }

                        onDoubleClicked: {
                            if (modelData.isCurrentMonth) {
                                gridRoot.dateDoubleClicked(modelData.date);
                            }
                        }
                    }
                }
            }
        }
    }
}
