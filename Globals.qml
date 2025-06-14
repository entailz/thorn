pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property bool vertical: false
    readonly property string notePath: homeDir + "/notes/bar"
    property var date: new Date()
    readonly property string font: "Readex Pro"
    readonly property bool toolTip: true
    readonly property color backgroundColor: "#" + colors.colors.color0
    readonly property string secondaryFont: "Rubik"
    readonly property var popupContext: PopupContext {}
    // envs
    readonly property string homeDir: Quickshell.env("HOME")
    readonly property string cacheDir: Quickshell.env("XDG_CACHE_HOME")

    readonly property var fallbackColors: ({
            "colors": {
                "color0": "181818",
                "color1": "3f425e",
                "color2": "5d463e",
                "color3": "5a4c73",
                "color4": "906070",
                "color5": "b1948a",
                "color6": "c8c1ad",
                "color7": "c5c5c5",
                "color8": "515151",
                "color9": "3f425e",
                "color10": "5d463e",
                "color11": "5a4c73",
                "color12": "906070",
                "color13": "b1948a",
                "color14": "c8c1ad",
                "color15": "c5c5c5"
            }
        })

    readonly property var colors: colorManager.colorsLoaded ? colorManager.currentColors : fallbackColors

    property var colorComponents: []

    QtObject {
        id: colorManager
        property var currentColors: ({})
        property bool colorsLoaded: false

        property FileView colorFile: FileView {
            path: Qt.resolvedUrl(root.homeDir + "/.config/quickshell/thorn/colors-qs.json")
            preload: true
            watchChanges: true
            onFileChanged: {
                colorManager.reloadColors();
            }
            onLoaded: {
                colorManager.reloadColors();
            }
        }

        function reloadColors() {
            colorFile.reload();
            try {
                if (!colorFile.text()) {
                    return;
                }
                currentColors = JSON.parse(colorFile.text());
                colorsLoaded = true;
            } catch (e) {
                colorsLoaded = false;
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.date = new Date()
    }

    signal colorReloadRequested
    onColorReloadRequested: {
        colorManager.reloadColors();
    }

    function reloadColors() {
        colorManager.reloadColors();
    }

    Component.onCompleted: {
        colorManager.reloadColors();
        // Hyprland.dispatch("mkdir -p " + root.homeDir + "hio");
    }
}
