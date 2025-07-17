import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import qs

Rectangle {
    id: root
    property string currentImagePath
    property string lastImagePath: ""
    signal imageSelected(string path)
    color: "transparent"

    radius: 18

    function triggerTransition() {
        if (currentImagePath && currentImagePath !== lastImagePath) {
            transitionAnim.start();
        }
    }

    onCurrentImagePathChanged: {
        if (currentImagePath && currentImagePath !== lastImagePath) {
            triggerTransition();
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: {
                if (!currentImagePath)
                    return "No image selected";
                const parts = currentImagePath.split('/');
                return parts[parts.length - 1];
            }
            font {
                family: Globals.font
                pixelSize: 11
                weight: Font.Medium
            }
            color: "#" + Globals.colors.colors.color7
            elide: Text.ElideMiddle
            horizontalAlignment: Text.AlignHCenter
        }

        ClippingRectangle {
            id: previewContainer
            Layout.fillWidth: true
            Layout.preferredHeight: width
            contentUnderBorder: true
            color: "#05" + Globals.colors.colors.color8
            radius: 12
            border {
                width: 0
                color: "#22" + Globals.colors.colors.color2
            }

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                smooth: true
                antialiasing: true
                radius: 16
                spread: 0.01
                cached: true
                samples: 20
                color: "#20000000"
            }

            Image {
                id: imageOld
                x: 0
                y: 0
                width: previewContainer.width
                height: previewContainer.height
                anchors.centerIn: parent
                opacity: 1.0
                source: lastImagePath || ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: opacity > 0 && source != ""
                sourceSize.width: previewContainer.width
                sourceSize.height: previewContainer.height
            }

            Image {
                id: imageNew
                x: previewContainer.width
                y: 0
                width: previewContainer.width
                height: previewContainer.height
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.0
                source: currentImagePath || ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: opacity > 0 && source != ""

                sourceSize.width: previewContainer.width
                sourceSize.height: previewContainer.height
            }

            ParallelAnimation {
                id: transitionAnim

                PropertyAnimation {
                    target: imageNew
                    property: "x"
                    from: 50
                    to: (previewContainer.width - imageNew.width) / 2
                    duration: 400
                    easing.type: Easing.OutCubic
                }

                PropertyAnimation {
                    target: imageNew
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.OutCubic
                }

                PropertyAnimation {
                    target: imageOld
                    property: "x"
                    from: (previewContainer.width - imageOld.width) / 2
                    to: -previewContainer.width
                    duration: 400
                    easing.type: Easing.OutCubic
                }

                PropertyAnimation {
                    target: imageOld
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 250
                    easing.type: Easing.OutQuad
                }

                onStopped: {
                    lastImagePath = currentImagePath;
                    imageOld.x = (previewContainer.width - imageOld.width) / 2;
                    imageOld.opacity = 1.0;
                    imageNew.x = previewContainer.width;
                    imageNew.opacity = 0.0;
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No Preview"
                color: "#" + Globals.colors.colors.color7
                font.pixelSize: 12
                visible: !currentImagePath
            }
        }
    }
}
