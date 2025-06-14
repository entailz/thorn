import Quickshell
import QtQuick
import "root:/"
import "../../components" as Components
import ".." as Services
import Quickshell
import Quickshell.Widgets

Components.SlidingPopup {
    id: selectorPopup

    property var colors
    property string selectedShader
    property var palettes
    property bool searchPanelVisible
    property string searchText
    property int currentImageIndex
    property string currentImagePath
    property string currentPalette

    signal shaderChanged(string shader)
    signal paletteChanged(string palette)
    signal searchChanged(string text)
    signal searchPanelToggled(bool visible)
    signal imageSelected(string imagePath)
    signal randomImageRequested
    signal currentImageChanged(int index, string path)

    visible: false
    implicitWidth: 780
    implicitHeight: 520

    function positionPopup(x, y) {
        anchor.rect.x = x;
        anchor.rect.y = y;
    }

    function updateGridModel(filtered) {
        if (gridLoader.item) {
            gridLoader.item.model = filtered;
        }
    }

    function navigateImage(direction) {
        if (gridLoader.item) {
            gridLoader.item.navigateImage(direction);
        }
    }

    function hasImages() {
        return gridLoader.item && gridLoader.item.model && gridLoader.item.model.length > 0;
    }

    function getFirstImage() {
        if (hasImages()) {
            return gridLoader.item.model[0];
        }
        return "";
    }

    function handleKeyPress(event) {
        switch (event.key) {
        case Qt.Key_Left:
            navigateImage(-1);
            event.accepted = true;
            break;
        case Qt.Key_Right:
            navigateImage(1);
            event.accepted = true;
            break;
        case Qt.Key_Up:
            navigateImage(-6);
            event.accepted = true;
            break;
        case Qt.Key_Down:
            navigateImage(6);
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            if (currentImagePath) {
                imageSelected(currentImagePath);
                closeWithAnimation();
            }
            event.accepted = true;
            break;
        case Qt.Key_Escape:
            closeWithAnimation();
            event.accepted = true;
            break;
        }
    }

    ClippingRectangle {
        id: mainRect
        anchors.centerIn: parent
        implicitWidth: parent.width
        implicitHeight: parent.height
        radius: 16
        color: "#99" + colors.color0
        layer.smooth: true
        layer.samples: 8
        layer.enabled: true
        contentInsideBorder: true

        border {
            width: 3
            color: color
        }

        WallpaperControls {
            id: controls
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            colors: selectorPopup.colors
            selectedShader: selectorPopup.selectedShader
            palettes: selectorPopup.palettes
            currentPalette: selectorPopup.currentPalette

            onShaderChanged: selectorPopup.shaderChanged(shader)
            onPaletteChanged: selectorPopup.paletteChanged(palette)
            onSearchToggled: selectorPopup.searchPanelToggled(visible)
            onRandomRequested: selectorPopup.randomImageRequested()
        }

        Row {
            id: mainContentRow
            anchors {
                top: controls.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 20
                leftMargin: 15
                rightMargin: 15
                bottomMargin: 15
            }
            spacing: 15

            LazyLoader {
                id: previewLoader
                loading: selectorPopup.visible

                WallpaperPreview {
                    width: 200
                    height: 40
                    colors: selectorPopup.colors
                    currentImagePath: selectorPopup.currentImagePath

                    onNavigateRequested: function (direction) {
                        selectorPopup.navigateImage(direction);
                    }

                    onImageApplied: function (imagePath) {
                        selectorPopup.imageSelected(imagePath);
                        selectorPopup.closeWithAnimation();
                    }
                }
            }

            LazyLoader {
                id: gridLoader
                loading: selectorPopup.visible

                WallpaperGrid {
                    width: mainContentRow.width - 200 - mainContentRow.spacing
                    height: 40
                    colors: selectorPopup.colors
                    currentImageIndex: selectorPopup.currentImageIndex
                    model: Services.RandomImage.imagePaths

                    onImageSelected: function (imagePath, index) {
                        selectorPopup.currentImageChanged(index, imagePath);
                        selectorPopup.imageSelected(imagePath);
                        selectorPopup.visible = false;
                    }

                    onCurrentImageChanged: function (index, path) {
                        selectorPopup.currentImageChanged(index, path);
                    }
                }
            }
        }
    }
}
