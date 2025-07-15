import QtQuick
import Quickshell.Services.Pipewire
import QtQuick.Layouts
import Quickshell

Rectangle {

    property PwNode stream: null

    height: appStreamLayout.implicitHeight
    color: "transparent"
    radius: 4

    PwObjectTracker {
        objects: stream ? [stream] : []
    }

    ColumnLayout {
        id: appStreamLayout
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 5
        }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                source: getAppIcon()
            }

            Text {
                Layout.fillWidth: true
                text: getAppName()
                color: "#DEDEDE"
                font.family: root.fontFamily
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        Text {
            Layout.fillWidth: true
            visible: text.length > 0
            text: getMediaInfo()
            color: "#A0C5B4A8"
            font.family: root.fontFamily
            font.pixelSize: 11
            font.italic: true
            elide: Text.ElideRight
            leftPadding: 20
        }

        AudioMixerEntry {
            Layout.fillWidth: true
            Layout.leftMargin: 15
            audioNode: stream
            isMicrophone: false
            showBackground: false
        }
    }

    function getAppIcon() {
        if (!stream?.ready || !stream.properties) {
            return Quickshell.iconPath("applications-multimedia-symbolic");
        }

        const iconName = stream.properties["application.icon-name"];
        const appName = (stream.properties["application.name"] || "").toLowerCase();
        const mediaName = (stream.properties["media.name"] || "").toLowerCase().trim();

        if (mediaName.includes("zen") || appName.includes("zen")) {
            return "../../icons/zen_dark.png";
        }
        if (mediaName.includes("youtube") || appName.includes("youtube")) {
            return "../../icons/youtube.png";
        }
        if (mediaName.includes("spotify") || appName.includes("spotify")) {
            return "../../icons/spotify.png";
        }
        if (mediaName.includes("twitch") || appName.includes("twitch")) {
            return "../../icons/twitch.png";
        }
        if (mediaName.includes("soundcloud") || appName.includes("soundcloud")) {
            return "../../icons/soundcloud.png";
        }
        if (mediaName.includes("firefox") || appName.includes("firefox")) {
            return "../../icons/firefox.png";
        }

        if (iconName && !appName.includes("firefox")) {
            return Quickshell.iconPath(iconName);
        }

        return Quickshell.iconPath("applications-multimedia-symbolic");
    }

    function getAppName() {
        if (stream?.ready && stream.properties && stream.properties["application.name"]) {
            return stream.properties["application.name"];
        }
        return stream?.name || "Unknown Application";
    }

    function getMediaInfo() {
        if (!stream?.ready || !stream.properties)
            return "";

        const title = stream.properties["media.title"];
        const artist = stream.properties["media.artist"];
        const mediaName = stream.properties["media.name"];

        if (title && artist) {
            return `${title} - ${artist}`;
        } else if (mediaName) {
            return mediaName;
        }
        return "";
    }
}
