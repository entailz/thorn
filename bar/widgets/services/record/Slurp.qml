import QtQuick
import Quickshell
import qs

PanelWindow {
    id: slurpWindow

    property var targetMonitor: null
    property bool isSelecting: false
    property point startPoint: Qt.point(0, 0)
    property point endPoint: Qt.point(0, 0)

    signal selectionMade(string selection)
    signal selectionCancelled

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    aboveWindows: true
    focusable: true
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: false

    screen: targetMonitor ? Quickshell.screens.find(s => s.name === targetMonitor.name) : null

    Item {
        id: keys
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: {
            slurpWindow.selectionCancelled();
            slurpWindow.visible = false;
        }

        Item {
            anchors.fill: parent

            Rectangle {
                anchors.fill: parent
                color: "#40000000"
                visible: !slurpWindow.isSelecting
            }

            Item {
                anchors.fill: parent
                visible: slurpWindow.isSelecting

                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.max(0, Math.min(slurpWindow.startPoint.y, slurpWindow.endPoint.y))
                    color: "#90000000"
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: Math.max(0, parent.height - Math.max(slurpWindow.startPoint.y, slurpWindow.endPoint.y))
                    color: "#90000000"
                }

                Rectangle {
                    anchors.left: parent.left
                    y: Math.min(slurpWindow.startPoint.y, slurpWindow.endPoint.y)
                    width: Math.max(0, Math.min(slurpWindow.startPoint.x, slurpWindow.endPoint.x))
                    height: Math.abs(slurpWindow.endPoint.y - slurpWindow.startPoint.y)
                    color: "#90000000"
                }

                Rectangle {
                    anchors.right: parent.right
                    y: Math.min(slurpWindow.startPoint.y, slurpWindow.endPoint.y)
                    width: Math.max(0, parent.width - Math.max(slurpWindow.startPoint.x, slurpWindow.endPoint.x))
                    height: Math.abs(slurpWindow.endPoint.y - slurpWindow.startPoint.y)
                    color: "#90000000"
                }
            }

            Rectangle {
                id: selectionOverlay
                x: Math.min(slurpWindow.startPoint.x, slurpWindow.endPoint.x)
                y: Math.min(slurpWindow.startPoint.y, slurpWindow.endPoint.y)
                width: Math.abs(slurpWindow.endPoint.x - slurpWindow.startPoint.x)
                height: Math.abs(slurpWindow.endPoint.y - slurpWindow.startPoint.y)

                color: "transparent"
                border.color: "#" + Globals.colors.colors.color6
                border.width: 1
                visible: slurpWindow.isSelecting && (width > 0 || height > 0)

                Rectangle {
                    anchors.top: parent.bottom
                    anchors.left: parent.left
                    anchors.topMargin: 5
                    width: dimensionsText.width + 10
                    height: dimensionsText.height + 6
                    color: "#cc000000"
                    radius: 3
                    visible: parent.visible && parent.width > 50 && parent.height > 20

                    Text {
                        id: dimensionsText
                        anchors.centerIn: parent
                        text: `${selectionOverlay.width}×${selectionOverlay.height}`
                        color: "#" + Globals.colors.colors.color6
                        font.pixelSize: 12
                        font.family: "monospace"
                    }
                }
            }

            // Rectangle {
            //     anchors.centerIn: parent
            //     width: instructionsText.width + 20
            //     height: instructionsText.height + 16
            //     color: "#cc" + Globals.colors.colors.color0
            //     radius: 8
            //     visible: !slurpWindow.isSelecting || (selectionOverlay.width < 200 || selectionOverlay.height < 100)

            // Text {
            //     id: instructionsText
            //     anchors.centerIn: parent
            //     text: slurpWindow.isSelecting ? "release to select region" : "click and drag to select recording area\npress Esc to cancel"
            //     font.family: Globals.font
            //     color: "white"
            //     font.pixelSize: 14
            //     horizontalAlignment: Text.AlignHCenter
            // }
            // }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.CrossCursor
                hoverEnabled: true

                onPressed: mouse => {
                    slurpWindow.startPoint = Qt.point(mouse.x, mouse.y);
                    slurpWindow.endPoint = slurpWindow.startPoint;
                    slurpWindow.isSelecting = true;
                }

                onPositionChanged: mouse => {
                    if (slurpWindow.isSelecting) {
                        slurpWindow.endPoint = Qt.point(mouse.x, mouse.y);
                    }
                }

                onReleased: mouse => {
                    if (slurpWindow.isSelecting) {
                        const finalRect = Qt.rect(Math.min(slurpWindow.startPoint.x, slurpWindow.endPoint.x), Math.min(slurpWindow.startPoint.y, slurpWindow.endPoint.y), Math.abs(slurpWindow.endPoint.x - slurpWindow.startPoint.x), Math.abs(slurpWindow.endPoint.y - slurpWindow.startPoint.y));

                        if (finalRect.width > 5 && finalRect.height > 5) {
                            const globalX = Math.floor(finalRect.x + (targetMonitor ? targetMonitor.x : 0));
                            const globalY = Math.floor(finalRect.y + (targetMonitor ? targetMonitor.y : 0));
                            const width = Math.floor(finalRect.width);
                            const height = Math.floor(finalRect.height);
                            const selectionString = `${globalX},${globalY} ${width}x${height}`;
                            slurpWindow.selectionMade(selectionString);
                        } else {
                            slurpWindow.selectionCancelled();
                        }

                        slurpWindow.visible = false;
                    }
                }
            }
        }
    }

    function startSelection(monitor) {
        targetMonitor = monitor;
        screen = monitor ? Quickshell.screens.find(s => s.name === monitor.name) : null;
        isSelecting = false;
        visible = true;
    }

    onVisibleChanged: {
        if (!visible) {
            isSelecting = false;
            startPoint = Qt.point(0, 0);
            endPoint = Qt.point(0, 0);
        }
    }
}
