import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../components" as Components
import qs

Components.SlidingPopup {
    id: popup

    property date selectedDate: new Date()
    property bool isEditMode: false
    property var editingEvent: null
    property string editingEventId: ""
    property bool notesExpanded: false
    property var categoryColors: ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F"]

    implicitWidth: 400
    color: "transparent"
    direction: "right"

    implicitHeight: {
        const baseHeight = 160;
        const eventsCount = PersistentEvents.getEventsForDate(selectedDate).length;
        const eventHeight = 88;
        const maxEventsVisible = 4;
        const eventsHeight = Math.min(eventsCount, maxEventsVisible) * eventHeight;
        const addEventSectionHeight = 280;
        const notesHeight = notesExpanded ? 100 : 0;
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
                const startMinutes = (event.time.hour || 0) * 60 + (event.time.minute || 0);
                const durationMinutes = (event.duration.hours || 0) * 60 + (event.duration.minutes || 0);
                const endMinutes = startMinutes + durationMinutes;

                endHourSpinBox.value = Math.floor(endMinutes / 60) % 24;
                endMinuteSpinBox.value = endMinutes % 60;
            }
        }

        if (event.categoryColor) {
            for (let i = 0; i < categoryColors.length; i++) {
                if (categoryColors[i] === event.categoryColor) {
                    colorFlow.selectedColorIndex = i;
                    break;
                }
            }
        }

        show();
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
        border.width: 1
        border.color: "#11" + Globals.colors.colors.color6

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                Layout.fillWidth: true
                text: isEditMode ? ("Edit Event - " + selectedDate.toLocaleDateString()) : ("Events for " + selectedDate.toLocaleDateString())
                color: "#" + Globals.colors.colors.color8
                font.family: Globals.font
                font.pixelSize: 14
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
            }

            // Events list
            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: {
                    const eventsCount = PersistentEvents.getEventsForDate(selectedDate).length;
                    return eventsCount === 0 ? 40 : Math.min(eventsCount, 4) * 88;
                }
                Layout.minimumHeight: 40
                clip: true

                ListView {
                    model: PersistentEvents.getEventsForDate(selectedDate)
                    spacing: 8

                    delegate: Rectangle {
                        width: parent ? parent.width : 360
                        height: 80
                        color: "#33" + Globals.colors.colors.color1
                        border.color: "#44" + Globals.colors.colors.color2
                        border.width: 1
                        radius: 8

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
                                    font.weight: Font.Medium
                                    Layout.preferredWidth: 200
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: {
                                        if (!modelData.time)
                                            return "All Day";

                                        const hour = modelData.time.hour % 12 === 0 ? 12 : modelData.time.hour % 12;
                                        const minute = modelData.time.minute || 0;
                                        const ampm = modelData.time.hour < 12 ? "AM" : "PM";
                                        let timeStr = hour + ":" + minute.toString().padStart(2, '0') + " " + ampm;

                                        if (modelData.duration) {
                                            const startMinutes = modelData.time.hour * 60 + minute;
                                            const durationMinutes = (modelData.duration.hours || 0) * 60 + (modelData.duration.minutes || 0);
                                            const endMinutes = startMinutes + durationMinutes;
                                            const endHour = Math.floor(endMinutes / 60) % 24;
                                            const endMin = endMinutes % 60;
                                            const endHour12 = endHour % 12 === 0 ? 12 : endHour % 12;
                                            const endAmPm = endHour < 12 ? "AM" : "PM";

                                            timeStr += " - " + endHour12 + ":" + endMin.toString().padStart(2, '0') + " " + endAmPm;
                                        }

                                        return timeStr;
                                    }
                                    color: "#B0B0B0"
                                    font.family: Globals.font
                                    font.pixelSize: 12
                                }

                                Text {
                                    text: modelData.notes || ""
                                    visible: text !== ""
                                    font.pixelSize: 10
                                    font.family: Globals.secondaryFont
                                    color: "#" + Globals.colors.colors.color8
                                    elide: Text.ElideRight
                                }
                            }

                            Components.IconButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                icon: "edit_calendar"
                                useVariableFill: true
                                clickable: true
                                size: 16
                                onClicked: popup.openForEdit(modelData)
                            }

                            Components.IconButton {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                icon: "delete"
                                useVariableFill: true
                                clickable: true
                                size: 16
                                onClicked: PersistentEvents.removeEvent(selectedDate, modelData.id)
                            }
                        }
                    }
                }
            }

            // Event form
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: popup.notesExpanded ? 380 : 280
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
                        text: isEditMode ? "Edit Event" : "New Appointment"
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

                    // Time selection
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

                    // Color selection
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
                            width: parent.width
                            spacing: 8
                            property int selectedColorIndex: 0

                            Repeater {
                                model: popup.categoryColors

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 14
                                    color: modelData
                                    border.color: colorFlow.selectedColorIndex === index ? "#FFFFFF" : "transparent"
                                    border.width: colorFlow.selectedColorIndex === index ? 2 : 0

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: colorFlow.selectedColorIndex = index
                                    }
                                }
                            }
                        }
                    }

                    // Notes section
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
                                color: popup.notesExpanded ? "#50" + Globals.colors.colors.color9 : "#30" + Globals.colors.colors.color8
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
                                    x: popup.notesExpanded ? parent.width - width - 2 : 2

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
                                    onClicked: popup.notesExpanded = !popup.notesExpanded
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: popup.notesExpanded ? 80 : 2
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
                                anchors.margins: popup.notesExpanded ? 8 : 0
                                clip: true
                                visible: popup.notesExpanded

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

                    // Action buttons
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        Button {
                            text: isEditMode ? "Update Event" : "Save Event"
                            enabled: titleField.text.trim() !== ""

                            background: Rectangle {
                                color: parent.enabled ? "#50" + Globals.colors.colors.color9 : "#20" + Globals.colors.colors.color8
                                radius: 6
                                border.width: 1
                                border.color: "#20" + Globals.colors.colors.color6
                            }

                            contentItem: Text {
                                text: parent.text
                                color: parent.enabled ? "#FFFFFF" : "#808080"
                                font.family: Globals.font
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (titleField.text.trim() !== "") {
                                    const startMinutes = startHourSpinBox.value * 60 + startMinuteSpinBox.value;
                                    const endMinutes = endHourSpinBox.value * 60 + endMinuteSpinBox.value;
                                    const durationMinutes = endMinutes >= startMinutes ? endMinutes - startMinutes : (24 * 60) - startMinutes + endMinutes;

                                    const event = {
                                        id: isEditMode ? editingEventId : Date.now().toString(),
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
                                        category: colorFlow.selectedColorIndex,
                                        categoryColor: categoryColors[colorFlow.selectedColorIndex],
                                        created: isEditMode ? editingEvent.created : new Date()
                                    };

                                    if (isEditMode) {
                                        PersistentEvents.removeEvent(selectedDate, editingEventId);
                                    }

                                    PersistentEvents.addEvent(selectedDate, event);
                                    resetEditMode();
                                }
                            }
                        }

                        Button {
                            text: isEditMode ? "Cancel Edit" : "Close"

                            background: Rectangle {
                                color: "#20" + Globals.colors.colors.color8
                                radius: 6
                                border.width: 1
                                border.color: "#20" + Globals.colors.colors.color6
                            }

                            contentItem: Text {
                                text: parent.text
                                color: "#FFFFFF"
                                font.family: Globals.secondaryFont
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (isEditMode) {
                                    resetEditMode();
                                } else {
                                    titleField.text = "";
                                    colorFlow.selectedColorIndex = 0;
                                    closeWithAnimation();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
