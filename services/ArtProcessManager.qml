pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import "root:/"

Item {
    id: root

    property string imagePath: ""
    property string palette: ""
    property string tenimage: ""

    signal artChanged

    Process {
        id: walrus
        running: false
        command: ["walrus", "-s", "0.14", root.imagePath]
    }

    Process {
        id: disc

        running: false
        command: [Globals.walVesktop, "-t", "-b", "haishoku"]
    }

    Connections {
        function onArtChanged() {
            walrus.running = true;
            disc.running = true;
        }

        target: root
    }
}
