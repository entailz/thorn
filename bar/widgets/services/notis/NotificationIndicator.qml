import QtQuick
import "root:/"

Item {
    id: sparkleWrapper

    property bool hasNotification: false

    implicitWidth: 20
    implicitHeight: 16
    visible: sparkle.opacity > 0
    opacity: hasNotification ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutQuad
        }
    }

    Canvas {
        id: sparkle
        anchors.fill: parent
        property real phase: 0
        property string sparkleColor: "#" + Globals.colors.colors.color15

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.fillStyle = sparkleColor;

            const centerX = width / 2;
            const centerY = height / 2.4;
            const size = 1.3;
            const radius = 4 + Math.sin(phase) * 2;

            ctx.fillRect(centerX - size / 2, centerY - size / 2, size, size);
            ctx.fillRect(centerX - size / 2 + radius, centerY - size / 2, size, size);
            ctx.fillRect(centerX - size / 2 - radius, centerY - size / 2, size, size);
            ctx.fillRect(centerX - size / 2, centerY - size / 2 + radius, size, size);
            ctx.fillRect(centerX - size / 2, centerY - size / 2 - radius, size, size);

            if (Math.sin(phase + 1) > 0) {
                ctx.fillRect(centerX - size / 2 + radius * 0.7, centerY - size / 2 + radius * 0.7, size, size);
                ctx.fillRect(centerX - size / 2 - radius * 0.7, centerY - size / 2 - radius * 0.7, size, size);
            }
            if (Math.sin(phase + 2) > 0) {
                ctx.fillRect(centerX - size / 2 - radius * 0.7, centerY - size / 2 + radius * 0.7, size, size);
                ctx.fillRect(centerX - size / 2 + radius * 0.7, centerY - size / 2 - radius * 0.7, size, size);
            }
        }

        Timer {
            interval: 150
            running: sparkleWrapper.opacity > 0
            repeat: true
            onTriggered: {
                sparkle.phase += 0.5;
                sparkle.requestPaint();
            }
        }
    }
}
