pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell
import qs

Singleton {
    id: noteSaver

    property bool isSaving: false
    property string lastSavedPath: ""
    property string statusMessage: ""
    property string notePath: Globals.notePath

    signal saveCompleted(bool success, string message)

    property var fileWriter: FileView {
        id: fileWriter
        atomicWrites: true
        printErrors: true

        onSaved: {
            noteSaver.isSaving = false;
            noteSaver.statusMessage = "Note saved successfully";
            noteSaver.saveCompleted(true, "Note saved to " + noteSaver.lastSavedPath);
        }

        onSaveFailed: function (error) {
            noteSaver.isSaving = false;
            noteSaver.statusMessage = "Failed to save note";
            noteSaver.saveCompleted(false, "Error saving note: " + error);
        }
    }

    function saveNote(noteText, filePath) {
        if (isSaving) {
            return false;
        }

        if (!noteText || !filePath) {
            return false;
        }

        isSaving = true;
        lastSavedPath = filePath;
        statusMessage = "Saving note...";

        fileWriter.path = filePath;
        fileWriter.setText(noteText);

        return true;
    }

    function generateNotePath() {
        return notePath + "/note_" + new Date().toISOString().replace(/[:.]/g, "_") + ".md";
    }

    function saveAndClear(noteText, filePath, onSuccess) {
        if (saveNote(noteText, filePath)) {
            _successCallback = onSuccess;
            return true;
        }
        return false;
    }

    property var _successCallback: null

    onSaveCompleted: function (success, message) {
        if (success && _successCallback) {
            _successCallback();
        }
        _successCallback = null;
    }
}
