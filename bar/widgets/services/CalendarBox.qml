import QtQuick
import QtQuick.Layouts
import qs // for Globals

Item {
    id: calendarRoot

    property date displayMonth: new Date()
    property date selectedDate: new Date()
    property var colors: ({})

    signal dateSelected(date newDate)

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
                    // Layout.margins: 30
                    color: "transparent"
                    // color: "#" + Globals.colors.colors.color1
                    // radius: 20

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        verticalAlignment: Text.AlignVCenter
                        // horizontalAlignment: Text.AlignHCenter

                        textFormat: Text.RichText
                        text: {
                            Globals.date.toLocaleDateString();
                        }

                        color: "#" + Globals.colors.colors.color6
                        font.family: Globals.font
                        font.pixelSize: 12
                        font.weight: Font.Medium
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
                                const currentDate = new Date(calendarRoot.displayMonth);
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
                                    days.push({
                                        day: i,
                                        date: new Date(year, month, i),
                                        isCurrentMonth: true,
                                        isToday: i === new Date().getDate() && month === new Date().getMonth() && year === new Date().getFullYear(),
                                        isSelected: i === calendarRoot.selectedDate.getDate() && month === calendarRoot.selectedDate.getMonth() && year === calendarRoot.selectedDate.getFullYear()
                                    });
                                }
                                while (days.length < 42) {
                                    days.push({
                                        day: "",
                                        isCurrentMonth: false,
                                        isSelected: false,
                                        isToday: false
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
                                    // radius: width / 2
                                    // bottom.border: 1
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
                                            return "#" + Globals.colors.colors.color11; // weekend color
                                        return "#C0C0C0";
                                    }
                                    font.family: Globals.font
                                    font.pixelSize: 14
                                    font.weight: modelData.isToday || modelData.isSelected ? Font.Medium : Font.Normal
                                }

                                MouseArea {

                                    cursorShape: Qt.PointingHandCursor
                                    anchors.fill: parent
                                    onClicked: {
                                        if (modelData.isCurrentMonth) {
                                            calendarRoot.selectedDate = modelData.date;
                                            calendarRoot.dateSelected(modelData.date);
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
