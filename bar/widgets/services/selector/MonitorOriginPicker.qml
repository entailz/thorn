import QtQuick
import Quickshell.Hyprland
import "../../../../services" as Services
import "root:/"

Rectangle {
    readonly property var monitor: Hyprland.monitors.values[0]
    property real aspectRatio: monitor ? monitor.width / monitor.height : 16 / 9
    property vector2d clickPosition: Qt.vector2d(0.5, 0.5)

    color: "#15" + colors.color8
    radius: 6
    border.width: 1
    border.color: "#25" + colors.color6

    height: width / aspectRatio

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: function (mouse) {
            const x = mouse.x / width;
            const y = mouse.y / height;
            parent.clickPosition = Qt.vector2d(x, y);
            Services.RandomImage.origin = parent.clickPosition;
        }
    }

    Rectangle {
        width: 8
        height: 8
        radius: 4
        color: "#" + colors.color9
        border.width: 2
        border.color: "#" + colors.color2

        x: parent.clickPosition.x * parent.width - width / 2
        y: parent.clickPosition.y * parent.height - height / 2

        Behavior on x {
            NumberAnimation {
                duration: 200
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 200
            }
        }
    }

    Canvas {
        anchors.fill: parent
        opacity: 0.3

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "#" + colors.color6;
            ctx.lineWidth = 1;
            ctx.setLineDash([2, 2]);

            ctx.beginPath();
            ctx.moveTo(width / 2, 0);
            ctx.lineTo(width / 2, height);
            ctx.moveTo(0, height / 2);
            ctx.lineTo(width, height / 2);
            ctx.stroke();
        }
    }
}
