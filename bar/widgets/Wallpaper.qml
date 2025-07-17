import Quickshell
import QtQuick
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import qs
import "components" as Components
import "../../services" as Services
import "services/selector" as Selector

Components.BarWidget {
    id: root
    readonly property var colors: Globals.colors.colors
    property string selectedShader: "shaders/magic.frag.qsb"
    property string currentPalette: "all"
    property string lastProcessedImage: ""
    property var palettes: []
    property bool searchPanelVisible: false
    property string searchText: ""
    property int currentImageIndex: 0
    property string currentImagePath: ""
    property color backgroundColor: Globals.backgroundColor
    signal checkjson
    signal artChanged

    implicitWidth: 34
    implicitHeight: 34
    color: "transparent"

    HyprlandFocusGrab {
        id: grabs
        windows: [selectorPopup, shaderSelector.popupWindow]
        onCleared: {
            selectorPopup.closeWithAnimation();
            root.searchPanelVisible = false;
        }
    }

    function onArtChanged() {
        Services.ArtProcessManager.artChanged();
    }

    function needsOriginSelection() {
        const path = shaderSelector.currentItem?.path || "";
        return path === "shaders/circleSelect.frag.qsb" || path === "shaders/magic.frag.qsb";
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
        gridView.model = filtered;

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
        if (gridView.model && gridView.model.length > 0) {
            let newIndex = currentImageIndex + direction;

            if (newIndex < 0) {
                newIndex = gridView.model.length + newIndex;
            } else if (newIndex >= gridView.model.length) {
                newIndex = newIndex % gridView.model.length;
            }

            currentImageIndex = newIndex;
            currentImagePath = gridView.model[currentImageIndex];
            gridView.currentIndex = currentImageIndex;
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

    Components.BarTooltip {
        relativeItem: wallpaperIcon.containsMouse ? wallpaperIcon : null
        offset: 2

        Label {
            font.family: Globals.secondaryFont
            font.pixelSize: 11
            font.hintingPreference: Font.PreferFullHinting
            color: "white"
            text: "Wallpaper Selector"
        }
    }

    Components.IconButton {
        id: wallpaperIcon
        // anchors.centerIn: parent
        outerSize: 20
        clickable: true
        size: 16
        useVariableFill: true
        icon: "wallpaper"

        onClicked: {
            selectorPopup.show();
            grabs.active = !grabs.active;

            if (selectorPopup.visible) {
                keyHandler.forceActiveFocus();
            }
        }
    }

    Components.SlidingPopup {
        id: selectorPopup
        anchor.item: root
        direction: "left"
        anchor.rect.y: root.implicitHeight - 8
        visible: false
        implicitWidth: 780
        implicitHeight: needsOriginSelection() ? 800 : 620

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }

        Selector.KeyHandler {
            id: keyHandler
            anchors.fill: parent
            parentRoot: root

            onNavigateRequested: function (direction) {
                root.navigateImage(direction);
            }

            onImageSelected: {
                if (root.currentImagePath) {
                    root.selectImage(root.currentImagePath);
                    selectorPopup.closeWithAnimation();
                    grabs.active = false;
                }
            }

            onPopupClosed: {
                selectorPopup.closeWithAnimation();
            }
        }
        ClippingRectangle {
            id: mainRect
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            radius: 16
            color: root.backgroundColor
            layer.smooth: true
            layer.samples: 8
            layer.enabled: true
            contentInsideBorder: true

            border {
                width: 3
                color: color
            }

            Rectangle {
                id: header
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 20
                }
                height: 60
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 16

                    RowLayout {
                        Layout.alignment: Qt.AlignLeft
                        spacing: 12

                        Components.IconButton {
                            id: searchButton
                            icon: "search"
                            fillNormal: 0.0
                            fillHover: 1.0
                            useVariableFill: true
                            clickable: true
                            outerSize: 28
                            onClicked: searchPanelVisible = !searchPanelVisible
                        }

                        Components.IconButton {
                            id: randomButton
                            icon: "casino"
                            clickable: true
                            useVariableFill: true
                            fillNormal: 0.0
                            fillHover: 1.0
                            outerSize: 28
                            onClicked: {
                                let randomPath = Services.RandomImage.selectRandomImage();
                                if (randomPath) {
                                    selectImage(randomPath);
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignCenter
                        Selector.ModernDropdown {
                            id: shaderSelector
                            Layout.preferredWidth: 120
                            placeholder: "Shaders"
                            model: [
                                {
                                    name: "Select",
                                    path: "shaders/circleSelect.frag.qsb",
                                    icon: "lasso_select"
                                },
                                {
                                    name: "Magic",
                                    path: "shaders/magic.frag.qsb",
                                    icon: "stars"
                                },
                                {
                                    name: "Peel",
                                    path: "shaders/Peel.frag.qsb",
                                    icon: "nutrition"
                                },
                                {
                                    name: "Circle",
                                    path: "shaders/circle.frag.qsb",
                                    icon: "orbit"
                                },
                                {
                                    name: "Doom",
                                    path: "shaders/Doom.frag.qsb",
                                    icon: "skull"
                                }
                            ]
                            onSelectionChanged: function (item) {
                                root.selectedShader = item.path;
                                Services.WallpaperSingleton.setShader(root.selectedShader);
                            }
                            Component.onCompleted: {
                                for (const item of model) {
                                    if (item.path === root.selectedShader) {
                                        currentItem = item;
                                        break;
                                    }
                                }
                            }
                        }

                        Selector.ModernDropdown {
                            id: paletteSelector
                            Layout.preferredWidth: 180
                            placeholder: "Color Palette"
                            model: palettes.map(p => ({
                                        name: p,
                                        value: p
                                    }))
                            visible: palettes.length > 1
                            onSelectionChanged: function (item) {
                                currentPalette = item.value;
                                updateFilteredImages();
                            }
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 40
                    }
                }
            }

            RowLayout {
                id: contentArea
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    margins: 20
                    topMargin: 10
                }
                spacing: 20

                Rectangle {
                    id: sidebar
                    Layout.preferredWidth: 280
                    Layout.fillHeight: true
                    color: "#15" + colors.color1
                    radius: 12
                    border.width: 1
                    border.color: "#20" + colors.color6

                    ColumnLayout {
                        anchors {
                            fill: parent
                            margins: 20
                        }
                        spacing: 16

                        Selector.PreviewSection {
                            id: previewSection
                            Layout.fillWidth: true
                            Layout.preferredHeight: 280
                            currentImagePath: root.currentImagePath
                            onImageSelected: function (path) {
                                selectImage(path);
                            }
                        }

                        Selector.NavigationControls {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            enabled: gridView.model && gridView.model.length > 0
                            onNavigateRequested: function (direction) {
                                navigateImage(direction);
                            }
                        }

                        Selector.ModernButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            text: "Apply Wallpaper"
                            primary: true
                            enabled: currentImagePath
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (currentImagePath) {
                                        selectImage(currentImagePath);
                                    }
                                }
                            }
                        }

                        Selector.TransitionOriginCard {
                            id: originCard
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? 180 : 0
                            visible: needsOriginSelection()

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Selector.WallpaperGrid {
                        id: gridView
                        anchors {
                            fill: parent
                            margins: 5
                        }
                        model: Services.RandomImage.imagePaths
                        currentIndex: root.currentImageIndex

                        onImageSelected: function (path, index) {
                            currentImageIndex = index;
                            currentImagePath = path;
                            selectImage(path);
                        }
                    }
                }
            }
        }

        Rectangle {
            id: searchPanel
            width: 250
            height: mainRect.height - 6
            anchors {
                verticalCenter: mainRect.verticalCenter
                right: mainRect.left
                rightMargin: searchPanelVisible ? -width - 5 : 40
            }
            color: Qt.rgba(parseInt(colors.color0.substring(0, 2), 16) / 255, parseInt(Globals.colors.colors.color0.substring(2, 4), 16) / 255, parseInt(Globals.colors.colors.color0.substring(4, 6), 16) / 255, 0.90)
            radius: 8

            Behavior on anchors.rightMargin {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 2
                spread: 0.01
                radius: 8.0
                samples: 17
                color: "#30000000"
            }

            Rectangle {
                id: panelHandle
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 15
                    rightMargin: -8
                }
                width: 16
                height: 40
                radius: 8
                color: panelClose.containsMouse ? "#" + colors.color9 : "#" + colors.color2
                MouseArea {
                    id: panelClose
                    anchors.fill: parent
                    onClicked: searchPanelVisible = !searchPanelVisible
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }
                }
            }

            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 15
                }
                spacing: 15

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Search Images"
                    font {
                        family: Globals.font
                        pointSize: 10
                        weight: Font.Medium
                    }
                    color: "#" + colors.color7
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#22" + colors.color10
                    border {
                        width: 1
                        color: searchField.activeFocus ? "#" + colors.color9 : "#" + Globals.colors.colors.color8
                    }

                    TextField {
                        id: searchField
                        anchors {
                            fill: parent
                            leftMargin: 15
                            rightMargin: 15
                        }
                        placeholderText: "Enter image name..."
                        color: "#" + colors.color7

                        placeholderTextColor: "#909090"
                        font {
                            family: Globals.font
                            pointSize: 10
                        }
                        background: null

                        onTextChanged: {
                            root.searchText = text;
                            updateFilteredImages();
                        }

                        Button {
                            id: clearButton
                            anchors {
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                rightMargin: 5
                            }
                            width: 24
                            height: 24
                            visible: searchField.text.length > 0

                            background: Rectangle {
                                radius: 12
                                color: clearButton.pressed ? "#33" + colors.color8 : clearButton.hovered ? "#22" + Globals.colors.colors.color8 : "transparent"
                            }

                            contentItem: Text {
                                text: "✕"
                                color: "#" + colors.color7
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                searchField.text = "";
                            }
                        }
                    }
                }

                Text {
                    text: "Found: " + gridView.count + " images"
                    color: "#" + colors.color7
                    font {
                        family: Globals.font
                        pointSize: 8
                    }
                    opacity: 0.8
                }

                Rectangle {
                    width: parent.width
                    height: 2
                    radius: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: "#" + colors.color9 + "33"
                        }
                        GradientStop {
                            position: 0.5
                            color: "#" + colors.color9
                        }
                        GradientStop {
                            position: 1.0
                            color: "#" + colors.color9 + "33"
                        }
                    }
                }
            }
        }
    }
}
