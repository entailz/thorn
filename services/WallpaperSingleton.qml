pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: wallpaperSingleton

    property string randomImagePath: ""
    property string shader: ""
    property bool preventWallpaperChange: false

    property var currentImages: []
    property int currentIndex: 0

    signal artChanged

    signal updateImages(string currentImage, string nextImage, bool startTransition)
    signal transitionFinished(string newCurrentImage, string newNextImage)

    function selectRandomImage() {
        var newPath = RandomImage.getRandomImage();
        if (newPath) {
            randomImagePath = newPath;
            artChanged();
        }
    }

    function setImagePath(path) {
        if (path) {
            randomImagePath = path;
            artChanged();
        }
    }

    function setShader(shaderPath) {
        shader = shaderPath;
    }

    function setArt(immediate) {
        const artUrl = randomImagePath;
        if (artUrl.length === 0) {
            return;
        }

        if (immediate || currentImages.length === 0) {
            currentImages = [artUrl];
            currentIndex = 0;
            updateImages(artUrl, "", false);
        } else {
            currentImages.push(artUrl);
            if (currentImages.length > 2) {
                currentImages.shift();
            }

            currentIndex = currentImages.length - 2;
            updateImages(currentImages[currentIndex], artUrl, true);
        }
    }

    function onTransitionFinished() {
        currentIndex = (currentIndex + 1) % currentImages.length;
        var nextImageSource = "";

        if (currentImages.length > 1) {
            nextImageSource = currentImages[(currentIndex + 1) % currentImages.length];
        }

        transitionFinished(currentImages[currentIndex], nextImageSource);
    }

    Component.onCompleted: {
        if (RandomImage.imagePaths.length > 0) {
            selectRandomImage();
        } else {
            RandomImage.imagesChanged.connect(() => {
                if (!RandomImage.preventWallpaperChange) {
                    selectRandomImage();
                }
            });
        }

        artChanged.connect(() => {
            setArt(currentImages.length === 0);
        });
    }
}
