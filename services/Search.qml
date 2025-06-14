pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "root:/"

Singleton {
    id: root
    property string searchTerm: ""

    Process {
        id: searchProcess
        command: ["bash", "-c", Globals.homeDir + `/.config/quickshell/thorn/services/scripts/search.sh "${root.searchTerm}"`]
        running: root.searchTerm !== ""
    }
}
