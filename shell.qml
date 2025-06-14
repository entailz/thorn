import QtQuick
import Quickshell
import Quickshell.Hyprland
import "bar" as Status
import "services" as Services

// import "bar/widgets/services/dock" as Docks

ShellRoot {
    id: root

    Status.Bar {
        id: topbar
    }

    Wallpaper {
        id: walls
    }

    Component.onCompleted: {
        Globals.reloadColors();
    }

    Services.ArtProcessManager {
        id: artProcessManager
        imagePath: Services.WallpaperSingleton.randomImagePath
    }

    GlobalShortcut {
        appid: "shell"
        name: "nextimage"
        onPressed: {
            Services.WallpaperSingleton.selectRandomImage();
        }
    }

    Runner {
        id: launcher
    }
}
