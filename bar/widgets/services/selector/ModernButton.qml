import QtQuick.Controls
import QtQuick
import qs

Button {
    property bool primary: false

    background: Rectangle {
        radius: 10
        color: {
            if (!parent.enabled)
                return "#15" + colors.color8;
            if (parent.pressed)
                return primary ? "#70" + colors.color9 : "#40" + colors.color8;
            if (parent.hovered)
                return primary ? "#AA" + colors.color9 : "#30" + colors.color8;
            return primary ? "#50" + colors.color9 : "#20" + colors.color8;
        }
        border.width: 1
        border.color: primary ? "#40" + colors.color9 : "#20" + colors.color6

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    contentItem: Text {
        text: parent.text
        font {
            family: Globals.font
            pixelSize: 14
            weight: Font.Medium
        }
        color: primary ? "#" + colors.color6 : "#" + colors.color6
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
