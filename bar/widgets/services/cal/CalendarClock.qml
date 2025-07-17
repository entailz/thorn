import QtQuick
import qs

Item {
    id: clockRoot

    property date currentTime: new Date()
    readonly property string timeString: {
        let hours = currentTime.getHours();
        let displayHours = hours === 0 ? 12 : (hours > 12 ? hours - 12 : hours);
        let minutes = currentTime.getMinutes().toString().padStart(2, '0');
        return displayHours + ":" + minutes;
    }
    readonly property string ampmString: currentTime.getHours() >= 12 ? "PM" : "AM"

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockRoot.currentTime = new Date()
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: clockRoot.timeString
            color: "#" + Globals.colors.colors.color6
            font.family: Globals.font
            font.pixelSize: 37
            font.weight: Font.Medium
        }

        Text {
            text: clockRoot.ampmString
            color: "#A0A0A0"
            font.family: Globals.font
            font.pixelSize: 10
            font.weight: Font.Medium
            anchors.baseline: parent.children[0].baseline
        }
    }
}
