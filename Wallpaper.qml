import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: panels
        property var modelData

        color: "#181A21"
        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Item {
            id: mainContainer
            anchors.fill: parent

            Item {
                id: imageContainer
                anchors.fill: parent

                Image {
                    id: currentImage
                    anchors.fill: parent
                    layer.enabled: true
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    cache: true
                    sourceSize.width: imageContainer.width
                    sourceSize.height: imageContainer.height
                }

                Image {
                    id: nextImage
                    anchors.fill: parent
                    layer.enabled: true
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    cache: true
                    sourceSize.width: imageContainer.width
                    sourceSize.height: imageContainer.height
                }
            }

            ShaderEffect {
                id: transitionEffect
                anchors.fill: imageContainer
                property vector2d origin: Services.RandomImage.origin
                property vector2d imageSize: currentImage.sourceSize
                property var fromImage: currentImage
                property var toImage: nextImage
                property real progress: 0
                property real horizontal: 1
                property real vertical: 0
                property real aspectX: imageContainer.width / imageContainer.height
                property real aspectY: 1.0
                property vector2d aspectRatio: Qt.vector2d(aspectX, aspectY)

                fragmentShader: Qt.resolvedUrl(Services.WallpaperSingleton.shader)
            }

            PropertyAnimation {
                id: transitionAnimation
                target: transitionEffect
                property: "progress"
                from: 0
                to: 1
                duration: 2200
                easing.type: Easing.InOutQuad
                onFinished: {
                    transitionEffect.progress = 0;
                    currentImage.source = nextImage.source;
                    nextImage.source = "";
                    Services.WallpaperSingleton.onTransitionFinished();
                }
            }

            Timer {
                id: delayTimer
                interval: 100
                repeat: false
                onTriggered: {
                    if (nextImage.status === Image.Ready && currentImage.status === Image.Ready)
                        transitionAnimation.start();
                }
            }

            Connections {
                target: Services.WallpaperSingleton
                function onUpdateImages(currentImagePath, nextImagePath, startTransition) {
                    if (transitionAnimation.running) {
                        currentImage.source = nextImage.source;
                        transitionAnimation.stop();
                        transitionEffect.progress = 0;
                    }

                    if (startTransition && nextImagePath.length > 0) {
                        nextImage.source = nextImagePath;
                        if (!currentImage.source)
                            currentImage.source = currentImagePath;
                        delayTimer.restart();
                    } else {
                        currentImage.source = currentImagePath;
                        nextImage.source = "";
                    }
                }

                function onArtChanged() {
                    artProcessManager.artChanged();
                }

                function onTransitionFinished(newCurrentImage, newNextImage) {
                }
            }
        }
    }
}
