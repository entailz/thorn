import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell
import Quickshell.Widgets
import "visualizer" as Viz
import "../components" as Components
import "root:/"

Item {
    id: root

    anchors.left: parent.left
    anchors.right: parent.right

    property color backgroundColor: Globals.backgroundColor
    // property var accentColor: "#60ffffff"
    property string fontFamily: Globals.secondaryFont

    height: mainContainer.height
    implicitHeight: mainContainer.height

    // property var focusManager: Focus
    property var currentSink: sinkTracker.objects.length > 0 ? sinkTracker.objects[0] : (Pipewire.ready ? Pipewire.defaultAudioSink : null)

    property var currentSource: sourceTracker.objects.length > 0 ? sourceTracker.objects[0] : (Pipewire.ready ? Pipewire.defaultAudioSource : null)

    Connections {
        target: sinkTracker
        function onObjectsChanged() {
            root.currentSink = sinkTracker.objects.length > 0 ? sinkTracker.objects[0] : (Pipewire.ready ? Pipewire.defaultAudioSink : null);
        }
    }

    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            if (sinkTracker.objects.length === 0 && Pipewire.ready) {
                root.currentSink = Pipewire.defaultAudioSink;
            }
        }
    }

    PwObjectTracker {
        id: sourceTracker
        objects: Pipewire.ready && Pipewire.defaultAudioSource ? [Pipewire.defaultAudioSource] : []
    }

    PwObjectTracker {
        id: sinkTracker
        objects: Pipewire.ready && Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []

        Component.onCompleted: {
            function updateTrackedSink() {
                if (Pipewire.ready && Pipewire.defaultAudioSink) {
                    objects = [Pipewire.defaultAudioSink];
                }
            }

            Pipewire.readyChanged.connect(updateTrackedSink);
            Pipewire.defaultAudioSinkChanged.connect(updateTrackedSink);
        }
    }

    PwObjectTracker {
        id: appStreamTracker
    }

    PwNodeLinkTracker {
        id: sinkLinkTracker
        node: sinkTracker.objects.length > 0 ? sinkTracker.objects[0] : null

        Component.onCompleted: {
            Pipewire.readyChanged.connect(updateTrackedNode);
        }

        function updateTrackedNode() {
            if (Pipewire.ready && Pipewire.defaultAudioSink) {
                node = Pipewire.defaultAudioSink;
            }
        }
    }

    property string outputIcon: {
        const sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio)
            return Quickshell.iconPath("audio-volume-muted");

        const name = sink.name?.toLowerCase() || "";
        const desc = sink.description?.toLowerCase() || "";
        const vol = sink.audio.volume;

        if (sink.audio.muted || vol === 0)
            return Quickshell.iconPath("audio-volume-muted");
        if (vol > 1.0)
            return Quickshell.iconPath("audio-volume-overamplified");
        if (vol < 0.33)
            return Quickshell.iconPath("audio-volume-low");
        if (vol < 0.66)
            return Quickshell.iconPath("audio-volume-medium");

        if (vol < .9)
            return Quickshell.iconPath("audio-volume-high");
        // else {
        if (name.includes("headphone") || name.includes("usb") || name.includes("arctis") || desc.includes("headphone") || desc.includes("arctis"))
            return Quickshell.iconPath("audio-volume-high");

        return Quickshell.iconPath("audio-type-speaker");
        // }
    }

    property string inputIcon: {
        const source = Pipewire.defaultAudioSource;
        if (!source || !source.audio)
            return Quickshell.iconPath("microphone-sensitivity-muted");

        const vol = source.audio.volume;

        if (source.audio.muted || vol === 0)
            return Quickshell.iconPath("microphone-sensitivity-muted");
        if (vol < 0.33)
            return Quickshell.iconPath("microphone-sensitivity-low");
        if (vol < 0.66)
            return Quickshell.iconPath("microphone-sensitivity-medium");
        return Quickshell.iconPath("microphone-sensitivity-high");
    }

    Rectangle {
        id: mainContainer
        anchors.left: parent.left
        anchors.right: parent.right
        color: root.backgroundColor
        // color: "transparent"
        // color: "#99" + Globals.colors.colors.color0
        radius: 16
        // anchors {
        //     // fill: parent
        //     margins: 2
        // }
        // width: 150

        height: {
            let contentHeight = tabContent.children[tabBar.currentIndex].implicitHeight + 50;
            return contentHeight + contentColumn.anchors.margins * 2 + cava.cavaHeight + 20;
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutQuad
            }
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 10
            }
            spacing: 8
            Viz.Thorn {
                id: cava
                cavaHeight: visible ? 100 : 0
                cavaWidth: 450
                count: 4
                visualizerMode: "wave" // wave or bars
            }

            Row {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 4

                Rectangle {
                    width: parent.width / 2 - 2
                    height: parent.height
                    color: tabBar.currentIndex === 0 ? "#60" + Globals.colors.colors.color6 : "transparent"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Output Devices"
                        color: tabBar.currentIndex === 0 ? "#DEDEDE" : "#" + Globals.colors.colors.color8
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.bold: tabBar.currentIndex === 0
                    }

                    MouseArea {

                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: tabBar.currentIndex = 0
                    }
                }

                Rectangle {
                    width: parent.width / 2 - 2
                    height: parent.height

                    // border.width: 1
                    // border.color: "#101010"
                    color: tabBar.currentIndex === 1 ? "#60" + Globals.colors.colors.color6 : "transparent"
                    radius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Input Devices"
                        color: tabBar.currentIndex === 1 ? "#DEDEDE" : "#" + Globals.colors.colors.color8
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.bold: tabBar.currentIndex === 1
                    }

                    MouseArea {

                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: tabBar.currentIndex = 1
                    }
                }
            }

            TabBar {
                id: tabBar
                Layout.fillWidth: true
                visible: false

                TabButton {
                    text: "Output"
                }

                TabButton {
                    text: "Input"
                }
            }
            Component {
                id: customDropdownComponent
                Dropdown {}
            }

            StackLayout {
                id: tabContent
                Layout.fillWidth: true
                currentIndex: tabBar.currentIndex

                Behavior on currentIndex {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }

                Item {
                    id: outputTab
                    implicitHeight: outputLayout.implicitHeight

                    ColumnLayout {
                        id: outputLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 12

                        Loader {
                            id: outputDeviceDropdown
                            Layout.fillWidth: true
                            sourceComponent: customDropdownComponent

                            property bool initializedNode: false

                            onLoaded: {
                                item.isSink = true;

                                function updateCurrentNode() {
                                    if (!Pipewire.ready)
                                        return;

                                    if (sinkTracker.objects.length > 0) {
                                        item.currentNode = sinkTracker.objects[0];
                                        initializedNode = true;
                                    } else if (Pipewire.defaultAudioSink) {
                                        item.currentNode = Pipewire.defaultAudioSink;
                                        initializedNode = true;
                                    }
                                }

                                Pipewire.readyChanged.connect(updateCurrentNode);

                                if (!initializedNode) {
                                    updateCurrentNode();
                                }

                                item.onNodeSelected = function (node) {
                                    if (node) {
                                        Pipewire.preferredDefaultAudioSink = node;
                                        sinkTracker.objects = [node];
                                        root.currentSink = node;
                                    }
                                };
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: masterVolumeContent.implicitHeight + 10
                            color: "#30" + Globals.colors.colors.color0
                            radius: 4

                            RowLayout {
                                id: masterVolumeContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    margins: 5
                                }
                                spacing: 8
                                Layout.leftMargin: 15

                                Components.VolumeSlider {
                                    Layout.fillWidth: true
                                    audioNode: root.currentSink
                                    isMicrophone: false
                                    fontFamily: root.fontFamily
                                    // accentColor: "#60E5D4C8"
                                }
                                Button {
                                    Layout.preferredWidth: 25
                                    Layout.preferredHeight: 25
                                    background: null

                                    property bool isMuted: {
                                        let node = sinkTracker.objects.length > 0 ? sinkTracker.objects[0] : null;
                                        return node && node.audio ? node.audio.muted : false;
                                    }

                                    contentItem: IconImage {
                                        source: {
                                            let node = root.currentSink;
                                            if (!node || !node.audio)
                                                return Quickshell.iconPath("audio-volume-muted-symbolic");

                                            if (node.audio.muted)
                                                return Quickshell.iconPath("audio-volume-muted-symbolic");
                                            let vol = node.audio.volume;
                                            if (vol < 0.01)
                                                return Quickshell.iconPath("audio-volume-muted-symbolic");
                                            if (vol < 0.33)
                                                return Quickshell.iconPath("audio-volume-low-symbolic");
                                            if (vol < 0.66)
                                                return Quickshell.iconPath("audio-volume-medium-symbolic");
                                            return Quickshell.iconPath("audio-volume-high-symbolic");
                                        }
                                        implicitSize: 14
                                    }

                                    onClicked: {
                                        let node = sinkTracker.objects.length > 0 ? sinkTracker.objects[0] : null;
                                        if (node && node.audio) {
                                            node.audio.muted = !node.audio.muted;
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Connected Applications"
                            color: "#" + Globals.colors.colors.color8
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.bold: true
                            visible: connectedAppsView.count > 0
                            leftPadding: 5
                        }

                        ListView {
                            id: connectedAppsView
                            Layout.fillWidth: true
                            Layout.preferredHeight: contentHeight
                            clip: true
                            spacing: 4

                            model: sinkLinkTracker.linkGroups.filter(g => g.source && g.source.isStream && g.source.audio)

                            delegate: Rectangle {

                                Component.onCompleted: {
                                    if (stream && !appStreamTracker.objects.includes(stream)) {
                                        appStreamTracker.objects = [...appStreamTracker.objects, stream];
                                    }
                                }
                                property var stream: modelData.source
                                width: connectedAppsView.width
                                height: appStreamLayout.implicitHeight
                                color: "transparent"
                                radius: 4

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
                                            source: {
                                                if (stream.ready && stream.properties) {
                                                    const iconName = stream.properties["application.icon-name"];
                                                    const appName = (stream.properties["application.name"] || "").toLowerCase();
                                                    const mediaName = (stream.properties["media.name"] || "").toLowerCase().trim();

                                                    if (mediaName.includes("zen") || appName.includes("zen")) {
                                                        return "../icons/zen_dark.png";
                                                    }
                                                    if (mediaName.includes("youtube") || appName.includes("youtube")) {
                                                        return "../icons/youtube.png";
                                                    }
                                                    if (mediaName.includes("spotify") || appName.includes("spotify")) {
                                                        return "../icons/spotify.png";
                                                    }
                                                    if (mediaName.includes("twitch") || appName.includes("twitch")) {
                                                        return "../icons/twitch.png";
                                                    }
                                                    if (mediaName.includes("soundcloud") || appName.includes("soundcloud")) {
                                                        return "../icons/soundcloud.png";
                                                    }

                                                    if (mediaName.includes("firefox") || appName.includes("firefox")) {
                                                        return "../icons/firefox.png";
                                                    }

                                                    if (iconName && !appName.includes("firefox")) {
                                                        return Quickshell.iconPath(iconName);
                                                    }
                                                }

                                                return Quickshell.iconPath("applications-multimedia-symbolic");
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: {
                                                if (stream.ready && stream.properties && stream.properties["application.name"]) {
                                                    return stream.properties["application.name"];
                                                }
                                                return stream.name || "Unknown Application";
                                            }
                                            color: "#DEDEDE"
                                            font.family: root.fontFamily
                                            font.pixelSize: 13
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                        text: {
                                            if (stream.ready && stream.properties) {
                                                if (stream.properties["media.title"] && stream.properties["media.artist"]) {
                                                    return stream.properties["media.title"] + " - " + stream.properties["media.artist"];
                                                } else if (stream.properties["media.name"]) {
                                                    return stream.properties["media.name"];
                                                }
                                            }
                                            return "";
                                        }
                                        color: "#A0C5B4A8"
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.italic: true
                                        elide: Text.ElideRight
                                        leftPadding: 20
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 15
                                        spacing: 8

                                        Components.VolumeSlider {
                                            Layout.fillWidth: true
                                            audioNode: stream
                                            isMicrophone: false
                                            fontFamily: root.fontFamily
                                            // accentColor: "#60E5D4C8"
                                        }

                                        Button {
                                            Layout.preferredWidth: 25
                                            Layout.preferredHeight: 25
                                            background: null

                                            property bool isMuted: stream && stream.audio ? stream.audio.muted : false

                                            contentItem: IconImage {
                                                source: {
                                                    if (!stream || !stream.audio)
                                                        return Quickshell.iconPath("audio-volume-muted-symbolic");

                                                    if (stream.audio.muted)
                                                        return Quickshell.iconPath("audio-volume-muted-symbolic");

                                                    let vol = stream.audio.volume;
                                                    if (vol < 0.01)
                                                        return Quickshell.iconPath("audio-volume-muted-symbolic");
                                                    if (vol < 0.33)
                                                        return Quickshell.iconPath("audio-volume-low-symbolic");
                                                    if (vol < 0.66)
                                                        return Quickshell.iconPath("audio-volume-medium-symbolic");
                                                    return Quickshell.iconPath("audio-volume-high-symbolic");
                                                }
                                                implicitSize: 14
                                            }

                                            onClicked: {
                                                if (stream && stream.audio) {
                                                    stream.audio.muted = !stream.audio.muted;
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: connectedAppsView.count === 0
                                text: "No connected audio streams"
                                color: "#80C5B4A8"
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.italic: true
                            }
                        }
                    }
                }

                Item {
                    id: inputTab
                    implicitHeight: inputLayout.implicitHeight

                    ColumnLayout {
                        id: inputLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 12

                        Loader {
                            id: inputDeviceDropdown
                            Layout.fillWidth: true
                            sourceComponent: customDropdownComponent

                            onLoaded: {
                                item.isSink = false;
                                item.currentNode = Pipewire.defaultAudioSource;
                                item.onNodeSelected = function (node) {
                                    if (node) {
                                        Pipewire.preferredDefaultAudioSource = node;

                                        sourceTracker.objects = [node];

                                        if (typeof root.currentSource !== 'undefined') {
                                            root.currentSource = node;
                                        }
                                    }
                                };
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: micVolumeContent.implicitHeight + 10
                            color: "#30" + Globals.colors.colors.color0
                            radius: 4

                            RowLayout {
                                id: micVolumeContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    margins: 15
                                }
                                spacing: 12

                                Components.VolumeSlider {
                                    Layout.fillWidth: true
                                    audioNode: root.currentSource
                                    isMicrophone: true
                                    fontFamily: root.fontFamily
                                }
                                Button {
                                    Layout.preferredWidth: 25
                                    Layout.preferredHeight: 25
                                    background: null

                                    property bool isMuted: {
                                        let node = root.currentSource;
                                        return node && node.audio ? node.audio.muted : false;
                                    }

                                    contentItem: IconImage {
                                        source: {
                                            let node = root.currentSource;
                                            if (!node || !node.audio)
                                                return Quickshell.iconPath("microphone-sensitivity-muted-symbolic");

                                            if (node.audio.muted)
                                                return Quickshell.iconPath("microphone-sensitivity-muted-symbolic");

                                            let vol = node.audio.volume;
                                            if (vol < 0.01)
                                                return Quickshell.iconPath("microphone-sensitivity-muted-symbolic");
                                            if (vol < 0.33)
                                                return Quickshell.iconPath("microphone-sensitivity-low-symbolic");
                                            if (vol < 0.66)
                                                return Quickshell.iconPath("microphone-sensitivity-medium-symbolic");
                                            return Quickshell.iconPath("microphone-sensitivity-high-symbolic");
                                        }
                                        implicitWidth: 14
                                    }

                                    onClicked: {
                                        let node = root.currentSource;
                                        if (node && node.audio) {
                                            node.audio.muted = !node.audio.muted;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
