pragma ComponentBehavior: Bound
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick
import Quickshell
import qs

Rectangle {
    id: slider

    Layout.fillWidth: true
    Layout.preferredHeight: 24

    property var audioNode: null
    property bool isMicrophone: false
    property string label: ""
    property bool showLabel: false
    property string iconName: ""
    property color accentColor: "#" + Globals.colors.colors.color6
    property string fontFamily: Globals.secondaryFont
    color: "transparent"

    function getVolumeIconSource(volume, isMuted) {
        if (isMuted || volume <= 0)
            return "image://icon/audio-volume-muted-symbolic";
        if (volume < 0.33)
            return "image://icon/audio-volume-low-symbolic";
        if (volume < 0.66)
            return "image://icon/audio-volume-medium-symbolic";
        return "image://icon/audio-volume-high-symbolic";
    }

    function getMicIconSource(volume, isMuted) {
        if (isMuted || volume <= 0)
            return "image://icon/microphone-sensitivity-muted-symbolic";
        return "image://icon/microphone-sensitivity-high-symbolic";
    }

    function updateBindings() {
        if (!audioNode || !audioNode.audio)
            return;

        volumeFill.width = Qt.binding(function () {
            if (!audioNode || !audioNode.audio)
                return 0;

            if (audioNode.audio.muted)
                return 0;

            return (audioNode.audio.volume * volumeBackground.width);
        });

        volumeHandle.x = Qt.binding(function () {
            return volumeFill.width - (volumeHandle.width / 2);
        });
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Item {
            implicitWidth: 24
            implicitHeight: 24
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            MouseArea {
                id: volumeArea
                anchors.fill: parent

                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                property bool dragging: false

                onPressed: {
                    dragging = true;
                    updateVolume(mouseX);
                }

                onReleased: {
                    dragging = false;
                }

                onPositionChanged: {
                    if (dragging) {
                        updateVolume(mouseX);
                    }
                }

                onClicked: {
                    updateVolume(mouseX);
                }

                function updateVolume(xPos) {
                    if (audioNode && audioNode.audio) {
                        const clickX = Math.min(Math.max(xPos, 0), volumeBackground.width);
                        const fraction = clickX / volumeBackground.width;

                        audioNode.audio.volume = fraction;

                        if (audioNode.audio.muted && fraction > 0) {
                            audioNode.audio.muted = false;
                        }
                    }
                }

                Rectangle {
                    id: volumeBackground
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: 4
                    color: "#30ffffff"
                    radius: 2

                    Rectangle {
                        id: volumeFill
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: {
                            if (!audioNode || !audioNode.audio)
                                return 0;

                            if (audioNode.audio.muted)
                                return 0;

                            return (audioNode.audio.volume * volumeBackground.width);
                        }
                        color: slider.accentColor
                        radius: 2
                    }

                    Rectangle {
                        id: volumeHandle
                        width: 12
                        height: 12
                        radius: width / 2
                        color: "#" + Globals.colors.colors.color5

                        x: volumeFill.width - (width / 2)
                        anchors.verticalCenter: parent.verticalCenter

                        states: State {
                            name: "hovered"
                            when: volumeArea.containsMouse || volumeArea.dragging
                            PropertyChanges {
                                target: volumeHandle
                                width: 16
                                height: 16
                                // color: "#f0f0f0"
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

                        layer.enabled: true
                        layer.effect: DropShadow {
                            horizontalOffset: 0
                            verticalOffset: 1
                            radius: 4.0
                            samples: 9
                            color: "#80000000"
                        }
                    }
                }

                Rectangle {
                    id: volumeHoverIndicator
                    width: 2
                    height: volumeBackground.height + 6
                    color: "#80ffffff"
                    visible: volumeArea.containsMouse && !volumeArea.dragging
                    x: Math.min(Math.max(volumeArea.mouseX, 0), volumeBackground.width)
                    anchors.verticalCenter: volumeBackground.verticalCenter
                }

                Rectangle {
                    id: volumeTooltip
                    width: volumeValueText.width + 10
                    height: volumeValueText.height + 6
                    radius: 4
                    color: "#60000000"
                    visible: volumeArea.containsMouse
                    x: Math.min(Math.max(volumeArea.mouseX - width / 2, 0), volumeBackground.width - width)
                    y: volumeBackground.y - height - 4

                    Text {
                        id: volumeValueText
                        anchors.centerIn: parent
                        color: "#ffffff"
                        font.family: slider.fontFamily
                        font.pixelSize: 10
                        text: {
                            const fraction = Math.min(Math.max(volumeArea.mouseX / volumeBackground.width, 0), 1);
                            return Math.round(fraction * 100) + "%";
                        }
                    }
                }
            }
        }

        Text {
            text: {
                if (!audioNode || !audioNode.audio)
                    return "0%";

                if (audioNode.audio.muted)
                    return "Muted";

                return Math.round(audioNode.audio.volume * 100) + "%";
            }
            color: "#C5B4A8"
            font.family: slider.fontFamily
            font.pixelSize: 12
            Layout.minimumWidth: 40
            horizontalAlignment: Text.AlignRight
        }
    }
}
