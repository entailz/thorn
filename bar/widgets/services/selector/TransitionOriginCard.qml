import QtQuick
import "root:/"
import QtQuick.Layouts

Rectangle {
    color: "#10" + colors.color1
    radius: 8
    border.width: 1
    border.color: "#20" + colors.color6

    ColumnLayout {
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 12

        Text {
            text: "Transition Origin"
            font {
                family: Globals.font
                pixelSize: 12
                weight: Font.Medium
            }
            color: "#" + colors.color7
        }

        MonitorOriginPicker {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
        }
    }
}
