import QtQuick
import qs
import QtQuick.Controls

Item {
    id: customTooltip
    property Item target: null
    property string tooltipText: ""
    visible: target !== null

    width: tooltipContent.width
    height: tooltipContent.height

    x: target ? target.mapToItem(target.parent, 0, 0).x + (target.width / 2) - (width / 2) : 0
    y: target ? target.mapToItem(target.parent, 0, 0).y + target.height + 5 : 0

    Column {
        id: tooltipContent
        spacing: 0

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

        Rectangle {
            color: "#dd" + Globals.colors.colors.color0
            radius: 5
            border.width: 1
            border.color: "#dd" + Globals.colors.colors.color12
            anchors.horizontalCenter: parent.horizontalCenter
            width: tooltipText.width + 16
            height: tooltipText.height + 8

            Label {
                id: tooltipText
                text: customTooltip.tooltipText
                anchors.centerIn: parent
                font.family: Globals.secondaryFont
                font.pixelSize: 13
                color: "white"
            }
        }
    }
}
