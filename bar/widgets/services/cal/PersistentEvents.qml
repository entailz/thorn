pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    readonly property string cacheDir: Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")
    property var eventData: ({})
    property bool isReady: false

    FileView {
        id: plannerFile
        path: root.cacheDir + "/qs/planner-data.json"

        onLoaded: {
            try {
                const data = JSON.parse(text())
                root.eventData = (data && typeof data === 'object') ? data : {}
            } catch (e) {
                console.warn("Failed to parse planner data:", e)
                root.eventData = {}
            }
            root.isReady = true
        }

        onLoadFailed: function (error) {
            console.warn("Failed to load planner data:", error)
            root.eventData = {}
            root.isReady = true
        }
    }

    function getDateKey(date) {
        if (!date)
            return "invalid-date";
        return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, '0') + "-" + String(date.getDate()).padStart(2, '0');
    }

    function removeEvent(date, eventId) {
        if (!root.isReady)
            return;

        const key = getDateKey(date);
        if (root.eventData[key]) {
            root.eventData[key] = root.eventData[key].filter(event => event.id !== eventId);
            if (root.eventData[key].length === 0) {
                delete root.eventData[key];
            }
            root.eventData = Object.assign({}, root.eventData);
            saveEventData();
        }
    }

    function addEvent(date, event) {
        if (!root.isReady)
            return;

        if (!event || !event.title || event.title.trim() === "" || event.title === "New Appointment") {
            return;
        }

        const key = getDateKey(date);
        if (!root.eventData[key]) {
            root.eventData[key] = [];
        }
        root.eventData[key].push(event);
        root.eventData = Object.assign({}, root.eventData);
        saveEventData();
    }

    function saveEventData() {
        if (!root.isReady)
            return;

        try {
            const jsonString = JSON.stringify(root.eventData, null, 2);
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
        if (!root.isReady) return [];
        const key = getDateKey(date);
        return root.eventData[key] || [];
    }

    function getAppointmentsForDateAndHour(date, hour) {
        const events = getEventsForDate(date);
        return events.filter(event => event.type === "appointment" && event.time && event.time.hour === hour);
    }
}
