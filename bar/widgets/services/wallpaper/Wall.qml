import Quickshell
import QtQuick
import Quickshell.Hyprland
import "root:/"
import "../../components" as Components
import "../../../../services" as Services

Components.BarWidget {
    id: root
    readonly property var colors: Globals.colors.colors
    property string selectedShader: "shaders/Peel.frag.qsb"
    property string tentativeImage: ""
    property string currentPalette: "all"
    property string lastProcessedImage: ""
    property var palettes: []
    property bool searchPanelVisible: false
    property string searchText: ""
    property int currentImageIndex: 0
    property string currentImagePath: ""

    signal checkjson
    signal artChanged

    implicitWidth: 34
    implicitHeight: 34
    color: "transparent"

    function onArtChanged() {
        Services.ArtProcessManager.artChanged();
    }

    function updatePalettes() {
        let paletteSet = new Set(["all"]);
        for (let key in Services.RandomImage.imageData) {
            let image = Services.RandomImage.imageData[key];
            if (image.palette) {
                paletteSet.add(image.palette);
            }
        }
        palettes = Array.from(paletteSet);
    }

    function updateFilteredImages() {
        let filtered = Object.values(Services.RandomImage.imageData).filter(img => {
            const paletteMatch = currentPalette === "all" || img.palette === currentPalette;
            const searchMatch = !searchText || (img.path && img.path.toLowerCase().includes(searchText.toLowerCase()));
            return paletteMatch && searchMatch;
        }).map(img => img.path);

        if (selectorLoader.item) {
            selectorLoader.item.updateGridModel(filtered);
        }

        if (filtered.length > 0) {
            currentImageIndex = Math.max(0, Math.min(currentImageIndex, filtered.length - 1));
            currentImagePath = filtered[currentImageIndex];
        } else {
            currentImagePath = "";
            currentImageIndex = 0;
        }
    }

    function selectImage(imagePath) {
        Services.WallpaperSingleton.setImagePath(imagePath);
        root.artChanged();
        currentImagePath = imagePath;
    }

    function navigateImage(direction) {
        if (selectorLoader.item) {
            selectorLoader.item.navigateImage(direction);
        }
    }

    HyprlandFocusGrab {
        id: grabs
        windows: selectorLoader.item ? [selectorLoader.item] : []
        onCleared: {
            if (selectorLoader.item) {
                selectorLoader.item.closeWithAnimation();
            }
            root.searchPanelVisible = false;
        }
    }

    Keys.onPressed: function (event) {
        if (selectorLoader.item && selectorLoader.item.visible) {
            selectorLoader.item.handleKeyPress(event);
        }
    }

    Component.onCompleted: {
        updatePalettes();
        Services.RandomImage.imagesChanged.connect(() => {
            updatePalettes();
            updateFilteredImages();
        });
        Services.WallpaperSingleton.setShader(selectedShader);
    }

    Text {
        id: wallpaperIcon
        anchors.centerIn: parent
        text: "󰸉"
        font.pixelSize: 14
        color: "#" + colors.color6
    }

    Rectangle {
        id: hoverBackground
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: 6
        color: mouseAreaButton.containsMouse ? "#22" + colors.color8 : "transparent"
        z: -1
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouseAreaButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onClicked: {
            if (!selectorLoader.active) {
                selectorLoader.activeAsync = true;
            }

            if (selectorLoader.item) {
                const window = root.QsWindow.window;
                const itemRect = window.contentItem.mapFromItem(wallpaperIcon, 0, wallpaperIcon.height);

                selectorLoader.item.positionPopup(itemRect.x - (selectorLoader.item.width / 2) + (wallpaperIcon.width / 2), itemRect.y + 14);
                selectorLoader.item.show();
                grabs.active = !grabs.active;

                if (selectorLoader.item.visible) {
                    updateFilteredImages();
                    if (selectorLoader.item.hasImages()) {
                        currentImagePath = selectorLoader.item.getFirstImage();
                        currentImageIndex = 0;
                    }
                }
            }
        }
    }

    LazyLoader {
        id: selectorLoader
        loading: false

        WallpaperSelectorPopup {
            id: popup
            anchor.window: root.QsWindow.window
            colors: root.colors
            selectedShader: root.selectedShader
            palettes: root.palettes
            searchPanelVisible: root.searchPanelVisible
            searchText: root.searchText
            currentImageIndex: root.currentImageIndex
            currentImagePath: root.currentImagePath
            currentPalette: root.currentPalette

            onShaderChanged: function (shader) {
                root.selectedShader = shader;
                Services.WallpaperSingleton.setShader(shader);
            }

            onPaletteChanged: function (palette) {
                root.currentPalette = palette;
                root.updateFilteredImages();
            }

            onSearchChanged: function (text) {
                root.searchText = text;
                root.updateFilteredImages();
            }

            onSearchPanelToggled: function (visible) {
                root.searchPanelVisible = visible;
            }

            onImageSelected: function (imagePath) {
                root.selectImage(imagePath);
                grabs.active = false;
            }

            onRandomImageRequested: {
                let randomPath = Services.RandomImage.selectRandomImage();
                if (randomPath) {
                    root.selectImage(randomPath);
                    grabs.active = false;
                }
            }

            onCurrentImageChanged: function (index, path) {
                root.currentImageIndex = index;
                root.currentImagePath = path;
            }
        }
    }
}
