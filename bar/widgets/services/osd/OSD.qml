import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Pipewire
import qs
import "../../components" as Components

PopupWindow {
    id: osdPopupWindow
    property color gradientStart: "#44" + Globals.colors.colors.color3
    property color gradientEnd: "#" + Globals.colors.colors.color6
    property var parentQsWindow: null
    anchor.window: parentQsWindow
    anchor.rect.y: Screen.height / 2 - osdPopupWindow.height / 2
    implicitWidth: 56
    implicitHeight: 340
    color: "transparent"

    property int timeout: 1500
    property int barHeight: 16
    property bool isClosing: false

    signal closed

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property bool isMuted: Pipewire.defaultAudioSink?.audio.muted ?? false
    readonly property real currentVolume: Pipewire.defaultAudioSink?.audio.volume ?? 0
    readonly property real displayVolume: currentVolume * 100

    Timer {
        id: debounceTimer
        interval: 50
        repeat: false
        onTriggered: {
            if (!osdPopupWindow.visible || osdPopupWindow.isClosing) {
                osdPopupWindow.showPopup();
            } else {
                dismissTimer.restart();
            }
        }
    }

    Timer {
        id: dismissTimer
        interval: osdPopupWindow.timeout
        running: true
        repeat: false
        onTriggered: osdPopupWindow.closePopup()
    }

    function closePopup() {
        if (!isClosing) {
            isClosing = true;
            exitAnimation.start();
        }
    }

    function showPopup() {
        if (isClosing) {
            exitAnimation.stop();
            isClosing = false;
        }

        osdPopupWindow.visible = true;

        if (clippingRect.opacity < 1) {
            entranceAnimation.restart();
        }

        dismissTimer.restart();
    }

    function handleVolumeChange() {
        debounceTimer.restart();
    }

    ClippingRectangle {
        id: clippingRect
        anchors.centerIn: parent
        width: parent.width - 10
        height: parent.height - 10
        radius: 16

        color: "#99" + Globals.colors.colors.color0
        border {
            width: 1
            color: "#55" + Globals.colors.colors.color4
        }
        contentInsideBorder: true
        layer.enabled: true
        layer.samples: 8
        layer.smooth: true
        opacity: 0

        layer.effect: DropShadow {
            transparentBorder: true
            radius: 10
            spread: 0.01
            cached: true
            samples: 20
            color: "#A0000000"
        }
        z: 1

        Rectangle {
            id: osdContainer
            anchors.fill: parent
            anchors.centerIn: parent
            radius: 8
            color: "transparent"

            anchors.margins: 5

            ParallelAnimation {
                id: entranceAnimation
                running: true

                NumberAnimation {
                    target: osdPopupWindow
                    property: "anchor.rect.x"
                    to: osdPopupWindow.width / 6 + 5
                    from: osdPopupWindow.width / 2 - osdPopupWindow.width / 2
                    duration: 300
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: clippingRect
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.OutCubic
                }

                onFinished: {
                    osdPopupWindow.isClosing = false;
                }
            }

            ParallelAnimation {
                id: exitAnimation

                NumberAnimation {
                    target: osdPopupWindow
                    property: "anchor.rect.x"
                    to: -osdPopupWindow.width
                    duration: 300
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: clippingRect
                    property: "opacity"
                    to: 0
                    duration: 200
                    easing.type: Easing.InCubic
                }

                onFinished: {
                    osdPopupWindow.visible = false;
                    osdPopupWindow.closed();
                    osdPopupWindow.isClosing = false;
                }
            }

            ColumnLayout {
                anchors.fill: parent

                anchors.topMargin: 20
                spacing: 12

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: osdPopupWindow.barHeight - 4
                    Layout.fillHeight: true
                    radius: osdPopupWindow.barHeight / 2
                    color: Qt.rgba(1, 1, 1, 0.2)

                    Item {
                        id: volumeBarFill
                        width: parent.width
                        height: parent.height * (osdPopupWindow.isMuted || osdPopupWindow.displayVolume <= 0 ? 0 : osdPopupWindow.displayVolume / 100)
                        y: parent.height - height
                        clip: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: volumeBarFill.width
                                height: volumeBarFill.height
                                radius: barHeight / 2
                            }
                        }

                        ShaderEffect {
                            id: gradientEffect
                            anchors.fill: parent

                            property color gradientStart: osdPopupWindow.gradientStart
                            property color gradientEnd: osdPopupWindow.gradientEnd
                            property int direction: 1

                            fragmentShader: "../../shaders/volume_gradient.frag.qsb"

                            property bool isMuted: osdPopupWindow.isMuted || osdPopupWindow.displayVolume <= 0

                            function updateGradientColors() {
                                gradientStart = osdPopupWindow.gradientStart;
                                gradientEnd = osdPopupWindow.gradientEnd;
                            }
                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuad
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 68
                    Layout.bottomMargin: 4
                    radius: 16
                    color: "transparent"

                    Components.ColorIcon {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        implicitSize: parent.width
                        source: {
                            if (osdPopupWindow.isMuted || osdPopupWindow.displayVolume <= 0)
                                return Quickshell.iconPath("volume-level-none");
                            if (osdPopupWindow.displayVolume < 33)
                                return Quickshell.iconPath("volume-level-low");
                            if (osdPopupWindow.displayVolume < 66)
                                return Quickshell.iconPath("volume-level-medium");
                            return Quickshell.iconPath("volume-level-high");
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            osdPopupWindow.handleVolumeChange();
        }
        function onMutedChanged() {
            osdPopupWindow.handleVolumeChange();
        }
    }
}
