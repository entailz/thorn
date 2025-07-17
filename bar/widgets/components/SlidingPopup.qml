import QtQuick
import Quickshell
import Qt5Compat.GraphicalEffects
import qs

PopupWindow {
    id: root
    color: "transparent"
    visible: false

    property int startY: -height
    property int endY: 0
    property int startX: -width
    property int endX: 0
    property int animationDuration: 300
    property int easingType: Easing.OutBack
    property color backgroundColor: Qt.rgba(0, 0, 0, 0.6)
    property int cornerRadius: 16
    property string direction: "down" // left, right, up, down

    property real startScale: 0.6
    property real endScale: 1.0

    readonly property int actualStartX: {
        switch (direction) {
        case "left":
            return width;
        case "right":
            return -width;
        default:
            return 0;
        }
    }
    readonly property int actualEndX: 0
    readonly property int actualStartY: {
        switch (direction) {
        case "up":
            return height;
        case "down":
            return -height;
        default:
            return 0;
        }
    }
    readonly property int actualEndY: 0

    property bool isClosing: false
    property bool shouldShow: false

    signal closeAnimationFinished

    function closeWithAnimation() {
        if (visible && !isClosing) {
            isClosing = true;
        }
    }

    function show() {
        closeTimer.stop();
        isClosing = false;
        shouldShow = true;
        visible = true;
    }

    function hide() {
        shouldShow = false;
        isClosing = false;
        visible = false;
    }

    default property alias contentItem: contentContainer.children

    Timer {
        id: closeTimer
        interval: root.animationDuration + 50
        onTriggered: {
            if (root.isClosing) {
                root.visible = false;
                root.shouldShow = false;
                root.isClosing = false;
                root.closeAnimationFinished();
            }
        }
    }

    onIsClosingChanged: {
        if (isClosing) {
            closeTimer.start();
        } else {
            closeTimer.stop();
        }
    }

    Rectangle {
        id: backgroundRect
        focus: true
        Keys.onEscapePressed: root.closeWithAnimation()
        anchors.fill: parent
        color: "transparent"
        radius: root.cornerRadius
        layer.smooth: true
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
        anchors {
            fill: parent
            margins: 10
        }

        transform: [
            Translate {
                id: slideTransform
                x: root.shouldShow && !root.isClosing ? root.actualEndX : root.actualStartX
                y: root.shouldShow && !root.isClosing ? root.actualEndY : root.actualStartY
                Behavior on x {
                    enabled: root.direction === "left" || root.direction === "right"
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: root.easingType
                        easing.overshoot: 0.6
                    }
                }
                Behavior on y {
                    enabled: root.direction === "up" || root.direction === "down"
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: root.easingType
                        easing.overshoot: 0.5
                    }
                }
            },
            Scale {
                id: scaleTransform
                origin.x: backgroundRect.width / 2
                origin.y: backgroundRect.height / 2
                xScale: root.shouldShow && !root.isClosing ? root.endScale : root.startScale
                yScale: root.shouldShow && !root.isClosing ? root.endScale : root.startScale

                Behavior on xScale {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutQuart
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: root.animationDuration
                        easing.type: Easing.OutQuart
                    }
                }
            }
        ]

        opacity: root.shouldShow && !root.isClosing ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutQuad
            }
        }

        Item {
            id: contentContainer
            anchors.fill: parent
        }
    }
}
