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

    function getImageName(path) {
        var parts = path.split("/");
        var baseName = parts[parts.length - 1];
        var extension = baseName.split('.').pop();
        var nameWithoutExtension = baseName.replace(/\.[^/.]+$/, '');
        var randomSuffix = palette;

        return nameWithoutExtension + "_" + randomSuffix + "." + extension;
    }

    function checkAndStartLutgen() {
        if (root.palette && root.palette !== "" && root.tenimage && root.tenimage !== "")
            lutgen.running = true;
    }

    Process {
        id: wal

        running: false
        command: ["wal", "-q", "-e", "-i", root.imagePath, "--saturate", "0.14", "--backend", "haishoku"]
    }

    Process {
        id: copyimage

        running: false
        command: ["cp", root.imagePath, Globals.homeDir + "/.cache/current_wallpaper.jpg"]
    }

    Process {
        id: disc

        running: false
        command: [Globals.homeDir + "/wal-discord/wal-discord", "-t", "-b", "haishoku"]
    }

    Process {
        id: lutgen

        running: false
        command: ["lutgen", "apply", "-p", root.palette, root.tenimage, "-l", "16", "-o", Globals.homeDir + "/paper/luts/" + root.getImageName(root.tenimage)]
        Component.onCompleted: {
            root.paletteChanged.connect(root.checkAndStartLutgen);
        }
        onRunningChanged: {
            if (!running) {
                let newImagePath = Globals.homeDir + "/paper/luts/" + root.getImageName(root.tenimage);
                RandomImage.addImageToJson(newImagePath, root.palette);
            }
        }
    }

    Timer {
        id: timer

        interval: 100
        running: false
        repeat: false
        onTriggered: {
            disc.running = true;
        }
    }

    Connections {
        function onArtChanged() {
            timer.start();
            // bar.running = true;
            wal.running = true;
            copyimage.running = true;
            disc.running = false;
        }

        target: root
    }
}
