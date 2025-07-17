import QtQuick
import QtQuick.Controls
import Quickshell.Widgets
import qs

ItemDelegate {
    id: itemDelegate
    property string imagePath
    property bool isSelected: false

    hoverEnabled: true

    background: Rectangle {
        color: "transparent"
        radius: 10
        border.width: isSelected ? 2 : (parent.hovered ? 1 : 0)
        border.color: isSelected ? "#" + colors.color9 : "#40" + colors.color8

        Behavior on border.width {
            NumberAnimation {
                duration: 150
            }
        }
    }

    contentItem: ClippingRectangle {
        anchors {
            fill: parent
            margins: 4
        }
        color: "#10" + colors.color8
        radius: 6
        contentUnderBorder: true

        Image {
            anchors {
                fill: parent
            }
            source: imagePath
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false

            sourceSize.width: itemDelegate.width
            sourceSize.height: itemDelegate.height
        }

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: isSelected ? "#20" + colors.color9 : "transparent"
            opacity: isSelected ? 0.3 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }
    }
}
