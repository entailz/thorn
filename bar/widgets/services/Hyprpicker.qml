pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs

Singleton {
    id: root

    property string currentColor: ""
    property var colorHistory: []
    readonly property int maxHistorySize: 10
    property bool isReady: false

    signal colorPicked(string color)

    FileView {
        id: colorHistoryFile
        path: Globals.homeDir + "/.cache/qs/colorpicker_history.json"
        watchChanges: true

        onLoaded: {
            try {
                const fileContent = text();
                if (fileContent && fileContent.trim() !== "") {
                    root.colorHistory = JSON.parse(fileContent);
                } else {
                    root.colorHistory = [];
                }
            } catch (e) {
                root.colorHistory = [];
            }
            root.isReady = true;
        }

        onLoadFailed: function (error) {
            root.colorHistory = [];
            root.isReady = true;
        }

        onFileChanged: {
            if (isReady) {
                loadColorHistory();
            }
        }
    }

    function loadColorHistory() {
        if (!colorHistoryFile.loaded || !isReady)
            return;

        try {
            const fileContent = colorHistoryFile.text();
            if (fileContent && fileContent.trim() !== "") {
                root.colorHistory = JSON.parse(fileContent);
            } else {
                root.colorHistory = [];
            }
        } catch (e) {
            root.colorHistory = [];
        }
    }

    function saveColorHistory() {
        if (!isReady)
            return;

        const jsonString = JSON.stringify(root.colorHistory, null, 2);
        colorHistoryFile.setText(jsonString);
    }

    function addToHistory(color) {
        if (!isReady)
            return;

        const index = colorHistory.indexOf(color);
        if (index !== -1) {
            colorHistory.splice(index, 1);
        }
        colorHistory.unshift(color);
        if (colorHistory.length > maxHistorySize) {
            colorHistory.pop();
        }
        saveColorHistory();
        colorHistoryChanged();
    }

    function copyToClipboard(color) {
        copyProcess.command = ["wl-copy", color];
        copyProcess.running = true;
    }

    function pickColor() {
        hyprpickerProcess.running = true;
    }

    function isValidColor(str) {
        return /^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$/.test(str);
    }

    Process {
        id: copyProcess
    }

    Process {
        id: hyprpickerProcess
        command: ["hyprpicker"]
        stdout: SplitParser {
            onRead: function (data) {
                const color = data.trim();
                if (root.isValidColor(color)) {
                    root.currentColor = color;
                    root.addToHistory(color);
                    root.copyToClipboard(color);
                    root.colorPicked(color);
                }
            }
        }
    }
}
