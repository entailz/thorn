import QtQuick
import "root:/"

Item {
    id: root

    property real sparkleOpacity: 0.5
    property color sparkleColor: "#" + Globals.colors.colors.color11
    Canvas {
        id: sparkleCanvas

        width: 8
        height: 8

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = root.sparkleColor;
            ctx.globalAlpha = root.sparkleOpacity;

            ctx.beginPath();
            ctx.moveTo(4, 0);
            ctx.lineTo(5, 3);
            ctx.lineTo(8, 3);
            ctx.lineTo(5.5, 5);
            ctx.lineTo(6.5, 8);
            ctx.lineTo(4, 6.5);
            ctx.lineTo(1.5, 8);
            ctx.lineTo(2.5, 5);
            ctx.lineTo(0, 3);
            ctx.lineTo(3, 3);
            ctx.closePath();
            ctx.fill();
        }

        NumberAnimation on y {
            from: -10
            to: parent ? parent.height + 10 : 100
            duration: 2000
            easing.type: Easing.InQuad
        }

        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 2000
            loops: Animation.Infinite
        }

        Timer {
            interval: 2000
            running: true
            onTriggered: sparkleCanvas.destroy()
        }
    }
}
