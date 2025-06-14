pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string cacheDir: Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")
    property var eventData: ({})
    property bool isReady: false

    FileView {
        id: plannerFile
        path: root.cacheDir + "/qs/planner-data.json"
        adapter: JsonAdapter {}

        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (data && typeof data === 'object') {
                    eventData = data;
                } else {
                    eventData = {};
                }
            } catch (e) {
                eventData = {};
            }
            isReady = true;
        }

        onLoadFailed: function (error) {
            eventData = {};
            isReady = true;
        }
    }

    function getDateKey(date) {
        if (!date)
            return "invalid-date";
        return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, '0') + "-" + String(date.getDate()).padStart(2, '0');
    }

    function removeEvent(date, eventId) {
        if (!isReady)
            return;

        const key = getDateKey(date);
        if (eventData[key]) {
            eventData[key] = eventData[key].filter(event => event.id !== eventId);
            if (eventData[key].length === 0) {
                delete eventData[key];
            }
            eventData = Object.assign({}, eventData);
            saveEventData();
        }
    }

    function addEvent(date, event) {
        if (!isReady)
            return;

        if (!event.title || event.title.trim() === "" || event.title === "New Appointment") {
            return;
        }

        const key = getDateKey(date);
        if (!eventData[key]) {
            eventData[key] = [];
        }
        eventData[key].push(event);
        eventData = Object.assign({}, eventData);
        saveEventData();
    }

    function saveEventData() {
        if (!isReady)
            return;

        try {
            const jsonString = JSON.stringify(eventData, null, 2);
            plannerFile.setText(jsonString);
        } catch (e) {
            console.error("failed to save planner data:", e);
        }
    }

    function getWeekStart(date) {
        const d = new Date(date);
        const day = d.getDay();
        const diff = d.getDate() - day;
        return new Date(d.setDate(diff));
    }

    function getEventsForDate(date) {
        const key = getDateKey(date);
        return eventData[key] || [];
    }

    function getAppointmentsForDateAndHour(date, hour) {
        const events = getEventsForDate(date);
        return events.filter(event => event.type === "appointment" && event.time && event.time.hour === hour);
    }
}
