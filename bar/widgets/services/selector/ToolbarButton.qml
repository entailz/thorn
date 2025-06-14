import QtQuick
import QtQuick.Controls
import "root:/"

Button {
    property string iconName
    property string tooltip

    width: 36
    height: 36
    hoverEnabled: true

    background: Rectangle {
        radius: 8
        color: parent.hovered ? "#40" + Globals.colors.colors.color8 : "#20" + colors.color8
        border.width: 1
        border.color: parent.hovered ? "#30" + Globals.colors.colors.color6 : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    contentItem: Text {
        text: iconName
        color: "#" + Globals.colors.colors.color7
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    HoverHandler {
        id: hoverHandler
    }

    ToolTip {
        text: tooltip
        visible: hoverHandler.hovered
        delay: 800
    }
}
