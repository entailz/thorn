import QtQuick
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs

Item {
    id: previewItem
    required property var modelData
    property real containerHeight: 120
    property real calculatedWidth: 150
    property real calculatedHeight: 120

    signal itemHovered(bool hovered)
    signal isDragStateChanged(bool dragging)

    implicitWidth: calculatedWidth
    implicitHeight: calculatedHeight
    opacity: previewItem.isDragging ? 0.0 : 1.0

    property bool isDragging: false
    property point dragOrigin
    property point originalPosition: Qt.point(x, y)

    onIsDraggingChanged: {
        isDragStateChanged(isDragging);
    }

    MouseArea {
        id: previewDragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.OpenHandCursor
        drag.target: previewItem
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            previewItem.itemHovered(true);
        }

        onExited: {
            if (!previewItem.isDragging) {
                previewItem.itemHovered(false);
            }
        }

        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton && modelData && modelData.activate) {
                modelData.activate();
            }
        }

        onPressed: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                previewItem.dragOrigin = Qt.point(mouse.x, mouse.y);
                previewItem.isDragging = true;

                if (root) {
                    root.isDragging = true;
                    root.draggedToplevel = modelData;
                }

                var globalPos = mapToGlobal(mouse.x, mouse.y);
                if (root && root.onToplevelDrag) {
                    root.onToplevelDrag(modelData, globalPos);
                }
            }
        }

        onReleased: function (mouse) {
            if (mouse.button === Qt.RightButton && previewItem.isDragging) {
                previewItem.x = previewItem.originalPosition.x;
                previewItem.y = previewItem.originalPosition.y;
                previewItem.isDragging = false;

                if (root) {
                    root.isDragging = false;
                    root.draggedToplevel = null;
                }

                if (root && root.onToplevelDragEnd) {
                    root.onToplevelDragEnd(modelData);
                }
            }
        }

        onPositionChanged: function (mouse) {
            if (previewItem.isDragging) {
                var globalPos = mapToGlobal(mouse.x, mouse.y);
                if (root && root.onToplevelDrag) {
                    root.onToplevelDrag(modelData, globalPos);
                }
            }
        }
    }

    ClippingWrapperRectangle {
        id: previewBorder
        color: "transparent"
        border.color: modelData.active ? "#" + Globals.colors.colors.color1 : "#" + Globals.colors.colors.color6
        border.width: 2
        radius: 5
        resizeChild: true

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }

        child: ScreencopyView {
            id: windowPreview
            live: true
            paintCursor: false
            captureSource: modelData
            constraintSize.height: previewItem.calculatedHeight - 4
            constraintSize.width: previewItem.calculatedWidth - 4
            clip: true

            implicitWidth: previewItem.calculatedWidth - 4
            implicitHeight: previewItem.calculatedHeight - 4

            onSourceSizeChanged: {
                if (sourceSize.width > 0 && sourceSize.height > 0) {
                    let aspect = sourceSize.width / sourceSize.height;

                    if (root && root.toplevels && root.toplevels.length <= 3) {
                        let maxWidth = 240;
                        let maxHeight = 140;

                        let newWidth = Math.min(maxWidth, maxHeight * aspect);
                        let newHeight = Math.min(maxHeight, maxWidth / aspect);

                        if (newWidth > maxWidth) {
                            newWidth = maxWidth;
                            newHeight = maxWidth / aspect;
                        }
                        if (newHeight > maxHeight) {
                            newHeight = maxHeight;
                            newWidth = maxHeight * aspect;
                        }

                        previewItem.calculatedWidth = newWidth;
                        previewItem.calculatedHeight = newHeight;

                        constraintSize.width = newWidth - 4;
                        constraintSize.height = newHeight + 20;
                        implicitWidth = newWidth - 4;
                        implicitHeight = newHeight - 4;
                    } else {
                        let maxWidth = 150;
                        let maxHeight = 120;

                        let newWidth = Math.min(maxWidth, maxHeight * aspect);
                        let newHeight = Math.min(maxHeight, maxWidth / aspect);

                        if (newWidth > maxWidth) {
                            newWidth = maxWidth;
                            newHeight = maxWidth / aspect;
                        }
                        if (newHeight > maxHeight) {
                            newHeight = maxHeight;
                            newWidth = maxHeight * aspect;
                        }

                        previewItem.calculatedWidth = newWidth;
                        previewItem.calculatedHeight = newHeight;

                        constraintSize.width = newWidth - 4;
                        constraintSize.height = newHeight - 4;
                        implicitWidth = newWidth - 4;
                        implicitHeight = newHeight - 4;
                    }
                }
            }

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    implicitWidth: windowPreview.width
                    implicitHeight: windowPreview.height
                    radius: 4
                }
            }
        }
    }

    NumberAnimation on opacity {
        id: entranceAnimation
        from: 0
        to: 1
        duration: 200
        easing.type: Easing.OutCubic
        running: false
    }

    Component.onCompleted: {
        entranceAnimation.start();
    }
}
