import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "root:/"

Rectangle {
    id: gridContainer

    property var colors
    property int currentImageIndex: 0
    property var model

    signal imageSelected(string imagePath, int index)
    signal currentImageChanged(int index, string path)

    color: "transparent"
    radius: 12

    function navigateImage(direction) {
        if (gridView.model && gridView.model.length > 0) {
            let newIndex;
            if (direction > 0) {
                newIndex = (currentImageIndex + 1) % gridView.model.length;
            } else {
                newIndex = (currentImageIndex - 1 + gridView.model.length) % gridView.model.length;
            }
            currentImageIndex = newIndex;
            gridView.currentIndex = newIndex;
            if (gridView.model[newIndex]) {
                currentImageChanged(newIndex, gridView.model[newIndex]);
            }
        }
    }

    GridView {
        id: gridView
        anchors {
            fill: parent
            margins: 5
        }
        cellWidth: width / 6
        cellHeight: cellWidth
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: gridContainer.model
        currentIndex: gridContainer.currentImageIndex
        highlightFollowsCurrentItem: true

        delegate: Item {
            id: delegateItem
            required property var modelData
            required property int index
            width: gridView.cellWidth
            height: gridView.cellHeight
            scale: 1

            Button {
                id: imageButton
                anchors.centerIn: parent
                width: parent.width - 10
                height: width

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function (mouse) {
                        if (mouse.button === Qt.LeftButton && !selectionAnimation.running) {
                            gridContainer.currentImageIndex = delegateItem.index;
                            gridContainer.currentImageChanged(delegateItem.index, delegateItem.modelData);
                            gridContainer.imageSelected(delegateItem.modelData, delegateItem.index);
                            selectionAnimation.start();
                        }
                    }
                }

                Rectangle {
                    id: hoverBorder
                    anchors.fill: parent
                    color: "transparent"
                    radius: 10
                    border {
                        width: (mouseArea.containsMouse || delegateItem.index === gridContainer.currentImageIndex) ? 3 : 0
                        color: delegateItem.index === gridContainer.currentImageIndex ? "#" + colors.color9 : "#" + colors.color11
                    }
                    opacity: (mouseArea.containsMouse || delegateItem.index === gridContainer.currentImageIndex) ? 1 : 0
                    z: 2

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Image {
                    id: imageItem
                    anchors {
                        fill: parent
                        margins: 5
                    }
                    source: delegateItem.modelData
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    sourceSize {
                        width: parent.width
                        height: parent.height
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: imageItem.width
                            height: imageItem.height
                            radius: 6
                        }
                    }
                }

                background: Rectangle {
                    color: mouseArea.containsMouse ? "#22" + colors.color11 : "transparent"
                    radius: 10

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 8.0
                        samples: 17
                        color: "#30000000"
                    }
                }

                ToolTip {
                    id: tooltip
                    text: {
                        const parts = delegateItem.modelData.split('/');
                        const filename = parts[parts.length - 1];
                        return filename;
                    }
                    visible: mouseArea.containsMouse
                    delay: 800
                    timeout: 3000
                    background: Rectangle {
                        color: "#" + colors.color0
                        border.color: "#" + colors.color8
                        radius: 4
                    }
                    contentItem: Text {
                        text: tooltip.text
                        color: "#" + colors.color7
                    }
                }
            }

            ParallelAnimation {
                id: selectionAnimation
                NumberAnimation {
                    target: delegateItem
                    property: "scale"
                    to: 1.1
                    duration: 300
                    easing.type: Easing.OutQuad
                }
                NumberAnimation {
                    targets: gridView.contentItem.children
                    exclude: delegateItem
                    property: "opacity"
                    to: 0.5
                    duration: 300
                }
                onFinished: {
                    delegateItem.scale = 0.85;
                    for (var i = 0; i < gridView.count; i++) {
                        var item = gridView.contentItem.children[i];
                        if (item !== delegateItem) {
                            item.opacity = 1;
                        }
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            policy: ScrollBar.AsNeeded
            width: 8
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                leftMargin: 24
            }

            background: Rectangle {
                color: "#22" + colors.color8
                radius: 4
                anchors.fill: parent
            }

            contentItem: Item {
                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: width / 2
                    color: scrollBar.pressed ? "#" + colors.color9 : scrollBar.hovered ? "#AA" + colors.color9 : "#77" + colors.color9

                    Rectangle {
                        width: parent.width * 0.6
                        height: 4
                        radius: 2
                        color: "#" + colors.color7
                        anchors.centerIn: parent
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "No wallpapers found"
            color: "#" + colors.color7
            font {
                family: Globals.font
                pointSize: 16
            }
            visible: gridView.count === 0
        }
    }
}
