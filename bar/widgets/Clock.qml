import QtQuick
import QtQuick.Layouts
import qs

Item {
    width: 42
    height: childrenRect.height
    readonly property var colors: Globals.colors.colors

    Rectangle {
        id: clockBox
        width: parent.width - 14
        height: clockLayout.height + 16
        color: "#44" + colors.color0
        radius: 6
        // border.color: "#404040"
        // border.width: 1

        ColumnLayout {
            id: clockLayout
            anchors.centerIn: parent
            spacing: 0

            Text {
                id: hourText
                Layout.alignment: Qt.AlignHCenter
                text: "00"
                font.family: Globals.font
                font.pixelSize: 18
                color: "#" + colors.color6
            }

            Text {
                id: minuteText
                Layout.alignment: Qt.AlignHCenter
                text: "00"
                font.family: Globals.font
                font.pixelSize: 16
                color: "#" + colors.color4
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
    }

    Component.onCompleted: updateTime()

    function updateTime() {
        var now = new Date();
        var hours = now.getHours();
        var minutes = now.getMinutes();

        hourText.text = hours.toString().padStart(2, '0');
        minuteText.text = minutes.toString().padStart(2, '0');
    }
}
