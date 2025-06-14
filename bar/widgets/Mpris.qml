pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import "components" as Components
import "root:/"

Components.BarWidget {
    id: mprisd
    color: "transparent"
    property MprisPlayer requestedPlayer: null
    property MprisPlayer player: requestedPlayer ?? Mpris.players.values[0] ?? null
    property bool infoVisible: false
    property var art: requestedPlayer?.trackArtUrl ?? ""
    readonly property var colors: Globals.colors
    property color backgroundColor: Globals.backgroundColor
    implicitWidth: mprisd.player ? 48 : 24
    implicitHeight: 32

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    function isLiveStream(position, length) {
        if (!position || !length || length <= 0)
            return false;
        return position - length > 1.5;
    }

    Loader {
        id: loader
        anchors.fill: parent
        active: true
        sourceComponent: Components.BarWidget {
            id: widget
            color: "transparent"
            widgetAnchors.margins: 0

            Components.SlidingPopup {
                id: mediaPopup
                anchor {
                    item: mprisd
                    rect: Qt.rect(0, unifiedIconButton.height - 5, mprisd.width, mprisd.height)

                    // edges: Edges.Bottom | Edges.Left
                    // gravity: Edges.Bottom | Edges.Right
                    // adjustment: PopupAdjustment.None
                }
                color: "transparent"
                implicitWidth: 325
                implicitHeight: 380

                Behavior on height {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.InOutQuad
                    }
                }
                visible: false

                ClippingRectangle {
                    anchors.fill: parent
                    color: mprisd.backgroundColor
                    radius: 16
                    contentInsideBorder: true
                    layer.enabled: true
                    layer.samples: 8
                    layer.smooth: true
                    z: 1

                    ColumnLayout {
                        anchors.fill: parent
                        // anchors.margins: 10
                        spacing: 10

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Layout.margins: 10

                            Text {
                                Layout.fillWidth: true
                                text: mprisd.player?.identity + "." ?? "No Player"
                                color: "#A0A0A0"
                                font.family: Globals.secondaryFont
                                font.capitalization: Font.AllLowercase
                                font.pixelSize: 13
                                font.styleName: "Regular"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8

                                Repeater {
                                    model: Mpris.players

                                    Components.IconButton {
                                        id: delegate
                                        required property MprisPlayer modelData
                                        readonly property alias player: delegate.modelData
                                        clickable: true
                                        useMask: false

                                        icon: DesktopEntries.byId(player.desktopEntry)?.icon ?? ""
                                        highlight: mprisd.player == player
                                        size: 20
                                        outerSize: size + 10
                                        // hoverEnabled: true

                                        onClicked: {
                                            mprisd.requestedPlayer = player;
                                        }
                                    }
                                }
                            }
                        }

                        ClippingRectangle {
                            id: albumRect
                            Layout.fillWidth: true
                            Layout.preferredHeight: 180
                            contentInsideBorder: contentUnderBorder
                            property color bgColor: "#222222"
                            color: bgColor

                            children: [
                                MouseArea {
                                    id: volumeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    propagateComposedEvents: true

                                    onWheel: function (wheel) {
                                        if (mprisd.player && mprisd.player.volumeSupported && mprisd.player.canControl) {
                                            var currentVolume = mprisd.player.volume;
                                            var adjustment = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                                            var newVolume = Math.max(0, Math.min(1, currentVolume + adjustment));

                                            mprisd.player.volume = newVolume;

                                            volumeShowPercentage.restart();

                                            volumeIndicator.opacity = 1;
                                            volumeFadeOutTimer.restart();
                                        }

                                        wheel.accepted = true;
                                    }

                                    onEntered: {
                                        volumeIndicator.opacity = 1;
                                    }

                                    onExited: {
                                        if (!volumeShowPercentage.running) {
                                            volumeFadeOutTimer.restart();
                                        }
                                    }
                                },
                                Image {
                                    id: albumArt
                                    anchors.fill: parent
                                    anchors.margins: 5
                                    source: {
                                        let art = mprisd.player?.trackArtUrl;
                                        return (art && art.length > 0) ? art : "icons/noalbum.png";
                                    }
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    asynchronous: true
                                    visible: false
                                },
                                FastBlur {
                                    id: blur
                                    anchors.fill: parent
                                    source: albumArt
                                    radius: 47
                                    layer.enabled: true
                                },
                                BrightnessContrast {
                                    anchors.fill: blur
                                    source: blur
                                    brightness: -0.5
                                    contrast: 0
                                },
                                ClippingRectangle {
                                    id: clipAlbum
                                    width: 80
                                    height: 80
                                    contentInsideBorder: true
                                    color: "transparent"
                                    radius: 10
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: 10
                                    border {
                                        width: 2
                                        color: "#" + Globals.colors.colors.color4
                                    }
                                    Image {
                                        id: albumCrop

                                        anchors.fill: parent
                                        visible: true
                                        source: {
                                            let art = mprisd.player?.trackArtUrl;
                                            return (art && art.length > 0) ? art : "icons/noalbum.png";
                                        }
                                        fillMode: Image.PreserveAspectCrop
                                        layer.enabled: true
                                    }
                                },
                                DropShadow {
                                    anchors.fill: clipAlbum
                                    horizontalOffset: 2
                                    verticalOffset: 2
                                    radius: clipAlbum.radius
                                    samples: 17
                                    color: "#60000000"
                                    source: clipAlbum
                                },
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: clipAlbum.right
                                    anchors.leftMargin: 20
                                    spacing: 4
                                    width: parent.width - clipAlbum.width - 40

                                    Text {
                                        text: mprisd.player?.trackTitle || "No track playing"
                                        color: "white"
                                        font.family: Globals.font
                                        font.pixelSize: 15
                                        elide: Text.ElideRight
                                        width: parent.width
                                        maximumLineCount: 1
                                        wrapMode: Text.NoWrap
                                    }

                                    Text {
                                        text: mprisd.player?.trackArtist || "Unknown Artist"
                                        color: "#" + Globals.colors.colors.color13
                                        font.family: Globals.font
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        width: parent.width
                                        maximumLineCount: 1
                                        wrapMode: Text.NoWrap
                                    }
                                },
                                Rectangle {
                                    id: volumeIndicator
                                    x: albumCrop.x + albumCrop.width * 3.4
                                    y: 5
                                    width: 40
                                    height: 40
                                    radius: 13
                                    color: Qt.rgba(0, 0, 0, 0.2)
                                    opacity: 0

                                    Timer {
                                        id: volumeFadeOutTimer
                                        interval: 500
                                        onTriggered: volumeFadeOut.start()
                                    }

                                    IconImage {
                                        id: volumeIcon
                                        anchors.centerIn: parent
                                        implicitSize: 20
                                        source: {
                                            const vol = mprisd.player?.volume ?? 0;
                                            if (vol <= 0)
                                                return Quickshell.iconPath("audio-volume-muted-symbolic");
                                            if (vol < 0.33)
                                                return Quickshell.iconPath("audio-volume-low-symbolic");
                                            if (vol < 0.66)
                                                return Quickshell.iconPath("audio-volume-medium-symbolic");
                                            return Quickshell.iconPath("audio-volume-high-symbolic");
                                        }
                                        visible: !volumeText.visible
                                    }

                                    Text {
                                        id: volumeText
                                        anchors.centerIn: parent
                                        color: colorQuantizer.colors?.length > 6 ? colorQuantizer.colors[6] : "#ffffff"
                                        font.pixelSize: 13
                                        font.family: Globals.font
                                        text: Math.round((mprisd.player?.volume ?? 0) * 100) + "%"
                                        visible: false

                                        Connections {
                                            target: mprisd.player || null
                                            function onVolumeChanged() {
                                                volumeText.text = Math.round((mprisd.player?.volume ?? 0) * 100) + "%";
                                            }
                                        }
                                    }

                                    SequentialAnimation {
                                        id: volumeShowPercentage

                                        PropertyAction {
                                            target: volumeText
                                            property: "visible"
                                            value: true
                                        }
                                        PropertyAction {
                                            target: volumeIcon
                                            property: "visible"
                                            value: false
                                        }

                                        PauseAnimation {
                                            duration: 1000
                                        }

                                        PropertyAction {
                                            target: volumeText
                                            property: "visible"
                                            value: false
                                        }
                                        PropertyAction {
                                            target: volumeIcon
                                            property: "visible"
                                            value: true
                                        }
                                    }

                                    PropertyAnimation {
                                        id: volumeFadeOut
                                        target: volumeIndicator
                                        property: "opacity"
                                        to: 0
                                        duration: 500
                                    }
                                }
                            ]
                        }
                        Timer {
                            // only emit the signal when the position is actually changing.
                            running: mprisd.player?.playbackState === MprisPlaybackState.Playing
                            // Make sure the position updates at least once per second.
                            interval: 1000
                            repeat: true
                            // emit the positionChanged signal every second.
                            onTriggered: mprisd.player.positionChanged()
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.leftMargin: 10
                            Layout.rightMargin: 10
                            // Layout.fillHeight: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    id: positionText
                                    text: {
                                        const pos = mprisd.player?.position ?? 0;
                                        const len = mprisd.player?.length ?? 0;

                                        if (mprisd.isLiveStream(pos, len))
                                            return "LIVE";

                                        const minutes = Math.floor(pos / 60);
                                        const seconds = Math.floor(pos % 60);
                                        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
                                    }
                                    color: "#AAA5A4"
                                    font.family: Globals.font
                                    font.pixelSize: 12
                                }

                                Item {
                                    id: seekBarContainer
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 24
                                    Rectangle {
                                        id: progressBackground
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            verticalCenter: parent.verticalCenter
                                        }
                                        height: 4
                                        color: "#30ffffff"
                                        radius: 2

                                        Rectangle {
                                            id: progressFill
                                            anchors {
                                                left: parent.left
                                                top: parent.top
                                                bottom: parent.bottom
                                            }
                                            visible: !mprisd.isLiveStream(mprisd.player?.position, mprisd.player?.length)
                                            color: "#60ffffff"
                                            radius: 2
                                            width: {
                                                const pos = mprisd.player?.position ?? 0;
                                                const len = mprisd.player?.length ?? 0;

                                                if (mprisd.isLiveStream(pos, len))
                                                    return parent.width;

                                                return Math.min((pos / len) * parent.width, parent.width);
                                            }
                                        }

                                        Rectangle {
                                            id: seekHandle
                                            width: 12
                                            height: 12
                                            radius: width / 2
                                            color: colorQuantizer.colors.length > 5 ? colorQuantizer.colors[5] : "white"

                                            layer.enabled: true
                                            layer.effect: DropShadow {
                                                horizontalOffset: 0
                                                verticalOffset: 1
                                                radius: 4.0
                                                samples: 9
                                                color: "#40000000"
                                            }

                                            x: progressFill.width - (width / 2)
                                            anchors.verticalCenter: parent.verticalCenter

                                            states: State {
                                                name: "hovered"
                                                when: seekArea.containsMouse || dragArea.drag.active
                                                PropertyChanges {
                                                    target: seekHandle
                                                    width: 16
                                                    height: 16
                                                    color: "#f0f0f0"
                                                }
                                            }

                                            transitions: Transition {
                                                NumberAnimation {
                                                    properties: "width,height"
                                                    duration: 150
                                                    easing.type: Easing.OutQuad
                                                }
                                                ColorAnimation {
                                                    duration: 150
                                                }
                                            }

                                            MouseArea {
                                                id: dragArea
                                                anchors.fill: parent
                                                drag.target: parent
                                                drag.axis: Drag.XAxis
                                                drag.minimumX: -(parent.width / 2)
                                                drag.maximumX: progressBackground.width - (parent.width / 2)

                                                onPositionChanged: {
                                                    if (drag.active && mprisd.player?.canSeek && mprisd.player?.length) {
                                                        const handleCenterX = seekHandle.x + (seekHandle.width / 2);
                                                        const fraction = Math.max(0, Math.min(1, handleCenterX / progressBackground.width));

                                                        progressFill.width = fraction * progressBackground.width;
                                                    }
                                                }

                                                onReleased: {
                                                    if (mprisd.player?.canSeek && mprisd.player?.length) {
                                                        const handleCenterX = seekHandle.x + (seekHandle.width / 2);
                                                        const fraction = Math.max(0, Math.min(1, handleCenterX / progressBackground.width));
                                                        const newPos = fraction * mprisd.player.length;
                                                        mprisd.player.seek(newPos);
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: seekArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor

                                        Rectangle {
                                            id: hoverIndicator
                                            width: 2
                                            height: progressBackground.height + 6
                                            color: "#80ffffff"
                                            visible: seekArea.containsMouse && !dragArea.drag.active
                                            x: Math.min(Math.max(seekArea.mouseX, 0), progressBackground.width)
                                            // anchors.verticalCenter: progressBackground.verticalCenter
                                        }

                                        Rectangle {
                                            id: hoverTooltip
                                            width: hoverTimeText.width + 10
                                            height: hoverTimeText.height + 6
                                            radius: 4
                                            color: "#60000000"
                                            visible: seekArea.containsMouse && !dragArea.drag.active
                                            x: Math.min(Math.max(seekArea.mouseX - width / 2, 0), progressBackground.width - width)
                                            y: progressBackground.y - height - 4

                                            Text {
                                                id: hoverTimeText
                                                anchors.centerIn: parent
                                                color: "#ffffff"
                                                font.family: Globals.font
                                                font.pixelSize: 10
                                                text: {
                                                    if (!mprisd.player?.length)
                                                        return "0:00";
                                                    const fraction = Math.min(Math.max(seekArea.mouseX / progressBackground.width, 0), 1);
                                                    const pos = Math.floor(fraction * mprisd.player.length);
                                                    const minutes = Math.floor(pos / 60);
                                                    const seconds = pos % 60;
                                                    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
                                                }
                                            }
                                        }

                                        onClicked: {
                                            if (mprisd.player?.canSeek && mprisd.player?.positionSupported && mprisd.player?.length) {
                                                const clickX = Math.min(Math.max(mouseX, 0), progressBackground.width);
                                                const fraction = clickX / progressBackground.width;
                                                const newPos = fraction * mprisd.player.length;

                                                mprisd.player.position = newPos;
                                            }
                                        }
                                    }
                                }

                                Text {
                                    id: durationText
                                    text: {
                                        if (!mprisd.player?.length)
                                            return "0:00";
                                        const len = Math.floor(mprisd.player.length);
                                        const minutes = Math.floor(len / 60);
                                        const seconds = len % 60;
                                        return `${minutes}:${seconds.toString().padStart(2, '0')}`;
                                    }
                                    color: "#AAA5A4"
                                    font.family: Globals.secondaryFont
                                    font.pixelSize: 12
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter

                            Layout.bottomMargin: 10
                            spacing: 20

                            Components.IconButton {
                                enabled: mprisd.player?.canGoPrevious ?? false
                                clickable: true
                                icon: "media-skip-backward-symbolic"
                                onClicked: mprisd.player.previous()
                                size: 24
                            }

                            Components.IconButton {
                                enabled: mprisd.player?.canTogglePlaying ?? false
                                clickable: true
                                icon: {
                                    const playing = mprisd.player && mprisd.player.playbackState == MprisPlaybackState.Playing;
                                    return playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic";
                                }
                                onClicked: mprisd.player.togglePlaying()
                                size: 32
                            }

                            Components.IconButton {
                                enabled: mprisd.player?.canGoNext ?? false
                                clickable: true
                                icon: "media-skip-forward-symbolic"
                                onClicked: mprisd.player.next()
                                size: 24
                            }
                        }
                    }
                }
            }

            ColorQuantizer {
                id: colorQuantizer
                source: mprisd.player?.trackArtUrl ? Qt.resolvedUrl(mprisd.player.trackArtUrl) : ""
                depth: 3
                rescaleSize: 64
                onColorsChanged: {
                    if (colors.length > 2) {
                        albumRect.bgColor = colors[2];
                        seekHandle.color = colors[6];
                        volumeText.color = colors[6];
                    } else if (colors.length > 0) {
                        albumRect.bgColor = colors[0];
                    }
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent

                hoverEnabled: true

                onWheel: event => {
                    event.accepted = true;
                    const points = event.angleDelta.y / 120;

                    if (mprisd.player && mprisd.player.canControl && mprisd.player.volumeSupported) {
                        const targetVolume = mprisd.player.volume + points * 0.01;
                        mprisd.player.volume = Math.max(Math.min(targetVolume, 1), 0);
                    }
                }
            }

            Components.WidgetText {
                id: trackInfo
                text: {
                    if (mprisd.player == null)
                        return "";
                    return `${mprisd.player.trackArtists} - ${mprisd.player.trackTitle}`;
                }
                Layout.fillWidth: false
                visible: true
                opacity: mprisd.infoVisible ? 1 : 0
                anchors.verticalCenter: parent.verticalCenter
                x: mprisd.infoVisible ? -(implicitWidth + 230) : 0
                Behavior on x {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 300
                    }
                }
            }

            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                color: "transparent"
                height: 30
                Behavior on height {
                    SmoothedAnimation {
                        velocity: 20
                    }
                }
            }

            Components.BarTooltip {
                relativeItem: mouseAreaTwo.containsMouse ? hoverBackground : null
                offset: 2

                Label {
                    font.family: Globals.secondaryFont
                    font.pixelSize: 11
                    font.hintingPreference: Font.PreferFullHinting
                    color: "white"
                    text: mprisd.player?.identity ?? "No Player"
                }
            }

            Item {
                id: unifiedIconButton
                y: -3
                x: -10
                width: Globals.vertical ? verticalLayout.width + 15 : horizontalLayout.width + 15  
                height: Globals.vertical ? verticalLayout.height + 10 : horizontalLayout.height + 10  

                Rectangle {
                    id: hoverBackground
                    anchors.centerIn: parent
                    width: unifiedIconButton.width
                    height: unifiedIconButton.height
                    // color: mouseAreaButton.containsMouse ? "#11c1c1c1" : "transparent"
                    radius: 6
                    color: mouseAreaTwo.containsMouse ? "#11c1c1c1" : "transparent"
                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                RowLayout {
                    id: horizontalLayout
                    spacing: 7
                    anchors.centerIn: parent
                    visible: !Globals.vertical

                    Components.SimpleImage {
                        id: playerIcon
                        source: mprisd.player?.desktopEntry ? Quickshell.iconPath(DesktopEntries.byId(mprisd.player.desktopEntry)?.icon) : ""
                        visible: mprisd.player != null
                        size: 12
                        cache: true
                        Layout.preferredHeight: 18
                        Layout.preferredWidth: 18
                    }

                    Components.ColorIcon {
                        id: wifiIcon
                        implicitSize: 18
                        source: Quickshell.iconPath("network-cellular-offline")
                        hovered: mouseAreaTwo.containsMouse
                        // Layout.preferredHeight: 18
                        // Layout.preferredWidth: 18
                    }
                }

                ColumnLayout {
                    id: verticalLayout
                    spacing: 7
                    anchors.centerIn: parent
                    visible: Globals.vertical

                    Components.SimpleImage {
                        id: playerIconVertical
                        source: mprisd.player?.desktopEntry ? Quickshell.iconPath(DesktopEntries.byId(mprisd.player.desktopEntry)?.icon) : ""
                        visible: mprisd.player != null

                        size: 12
                        Layout.preferredHeight: 17
                        Layout.preferredWidth: 17
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Components.SimpleImage {
                        id: wifiIconVertical
                        source: wifiIcon.source
                        size: 17
                        Layout.preferredHeight: 17
                        Layout.preferredWidth: 17
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                property string wifiSignalIcon: Quickshell.iconPath("network-cellular-offline")

                // Hopefully wifi module soontm

                Timer {
                    id: wifiUpdateTimer
                    interval: 4000
                    repeat: true
                    running: true
                    triggeredOnStart: true
                    onTriggered: {
                        wifiSignalProcess.running = true;
                    }
                }

                HyprlandFocusGrab {
                    id: grab
                    windows: [mediaPopup]
                    onCleared: {
                        mediaPopup.closeWithAnimation();
                    }
                }

                Process {
                    id: wifiSignalProcess
                    command: ["sh", "-c", "iw dev wlan0 link | awk '/signal/ {gsub(\"-\", \"\"); print $2}'"]
                    stdout: SplitParser {
                        onRead: data => {
                            const signal = parseInt(data.trim());
                            if (!isNaN(signal)) {
                                let iconPath;
                                if (signal >= 75) {
                                    iconPath = Quickshell.iconPath("network-cellular-signal-excellent");
                                } else if (signal >= 50) {
                                    iconPath = Quickshell.iconPath("network-cellular-signal-good");
                                } else if (signal >= 25) {
                                    iconPath = Quickshell.iconPath("network-cellular-signal-ok");
                                } else if (signal >= 0) {
                                    iconPath = Quickshell.iconPath("network-cellular-signal-weak");
                                } else {
                                    iconPath = Quickshell.iconPath("network-cellular-signal-none");
                                }
                                wifiIcon.source = iconPath;
                                wifiIconVertical.source = iconPath;
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseAreaTwo
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mediaPopup.show();
                        // mediaPopup.visible = !mediaPopup.visible;
                        grab.active = true;
                    }
                }
            }
        }
    }
}
