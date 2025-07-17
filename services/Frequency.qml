pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell
import qs

Singleton {
    id: root
    property bool dataReady: false

    FileView {
        id: frequencyFile
        path: Globals.homeDir + "/.cache/qs/runner_frequency.json"
        watchChanges: false
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        blockLoading: false
        preload: true

        adapter: JsonAdapter {
            id: adapter
            property var apps: ({})
            property string lastUpdateTime: ""
            onAppsChanged: root.dataReady = true
        }

        onLoadFailed: function (error) {
            if (error.code === FileViewError.FileNotFound) {
                adapter.apps = {};
                adapter.lastUpdateTime = new Date().toISOString();
                writeAdapter();
            }
            root.dataReady = true;
        }

        onLoaded: {
            root.dataReady = true;
        }
    }

    function trackApp(appName) {
        if (!appName || !dataReady)
            return;

        var apps = frequencyFile.adapter.apps || {};
        apps[appName] = (apps[appName] || 0) + 1;
        frequencyFile.adapter.apps = apps;
        frequencyFile.adapter.lastUpdateTime = new Date().toISOString();
    }

    function getCount(appName) {
        if (!dataReady)
            return 0;

        var apps = frequencyFile.adapter.apps || {};
        return apps[appName] || 0;
    }

    function sortByFrequency(apps) {
        if (!dataReady)
            return apps;

        return apps.slice().sort((a, b) => {
            var countA = getCount(a.name || a.id);
            var countB = getCount(b.name || b.id);
            return countB - countA;
        });
    }
}
