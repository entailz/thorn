import QtQuick
import Quickshell
import Quickshell.Widgets
import qs

LazyLoader {
    id: root
    property real offset
    property Item relativeItem: null

    property Item displayItem: null

    property PopupContext popupContext: Globals.popupContext

    property bool hoverable: false
    readonly property bool hovered: item?.hovered ?? false

    default required property Component contentDelegate

    active: displayItem != null && popupContext.popup == this

    onRelativeItemChanged: {
        if (relativeItem == null) {
            if (item != null)
                item.hideTimer.start();
        } else {
            if (item != null)
                item.hideTimer.stop();
            displayItem = relativeItem;
            popupContext.popup = this;
        }
    }

    PopupWindow {
        id: popup

        visible: Globals.toolTip && internalVisible
        property bool internalVisible: false

        property bool shouldBeVisible: root.displayItem !== null && popupContext.popup === root

        onShouldBeVisibleChanged: {
            if (shouldBeVisible) {
                internalVisible = true;
                animationWrapper.opacity = 0;
                animationWrapper.scale = 0.95;
                fadeInAnim.start();
            } else {
                fadeOutAnim.start();
            }
        }

        anchor.item: root.displayItem
        anchor.rect.x: root.displayItem?.width / 2 ?? 0
        anchor.rect.y: root.displayItem?.height + root.offset ?? 30
        anchor.edges: Edges.Top
        anchor.gravity: Edges.Bottom

        property alias hovered: body.containsMouse

        property Timer hideTimer: Timer {
            interval: 250
            onTriggered: root.popupContext.popup = null
        }

        color: "transparent"
        Region {
            id: emptyRegion
        }
        mask: root.hoverable ? null : emptyRegion

        implicitWidth: body.implicitWidth
        implicitHeight: body.implicitHeight

        Item {
            id: animationWrapper
            anchors.fill: parent
            opacity: 0
            scale: 0.95

            MouseArea {
                id: body
                anchors.fill: parent
                hoverEnabled: root.hoverable

                implicitWidth: content.implicitWidth + 18
                implicitHeight: content.implicitHeight + 6 + 10

                Column {
                    spacing: 0
                    anchors.horizontalCenter: parent.horizontalCenter

                    Canvas {
                        width: 12
                        height: 6
                        anchors.horizontalCenter: parent.horizontalCenter
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            ctx.fillStyle = "#dd" + Globals.colors.colors.color6;
                            ctx.beginPath();
                            ctx.moveTo(width / 2, 0);
                            ctx.lineTo(width, height);
                            ctx.lineTo(0, height);
                            ctx.closePath();
                            ctx.fill();
                        }
                    }

                    ClippingRectangle {
                        color: "#" + Globals.colors.colors.color0
                        radius: 6
                        // border.width: 1
                        // border.color: "#" + Globals.colors.colors.color2
                        anchors.horizontalCenter: parent.horizontalCenter
                        contentInsideBorder: true

                        implicitWidth: content.implicitWidth + 16
                        implicitHeight: content.implicitHeight + 8

                        Loader {
                            id: content
                            anchors.centerIn: parent
                            sourceComponent: contentDelegate
                            active: true
                        }
                    }
                }
            }

            SequentialAnimation {
                id: fadeInAnim
                PropertyAnimation {
                    target: animationWrapper
                    property: "opacity"
                    to: 1
                    duration: 120
                }
                PropertyAnimation {
                    target: animationWrapper
                    property: "scale"
                    to: 1.0
                    duration: 120
                }
            }

            SequentialAnimation {
                id: fadeOutAnim
                PropertyAnimation {
                    target: animationWrapper
                    property: "opacity"
                    to: 0
                    duration: 100
                }
                PropertyAnimation {
                    target: animationWrapper
                    property: "scale"
                    to: 0.95
                    duration: 100
                }
                onStopped: internalVisible = false
            }
        }
    }
}
