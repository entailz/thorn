pragma Singleton
import QtQuick
import qs

QtObject {
    id: userProfile

    property string name: "entailz"
    property string status: "online"
    property string bio: "working on thorn."
    property string profileImagePath: Globals.homeDir + "/.config/quickshell/thorn/bar/widgets/icons/profile/angel_prof.jpg"
    property color statusColor: "#76A67A"

    readonly property string lastActivity: "Today, " + Qt.formatTime(new Date(), "h:mm AP")
    readonly property string theme: "Zen"

    function getInitials() {
        return name.charAt(0).toUpperCase();
    }
}
