import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick.Layouts
import "../../components" as Components
import QtQuick.Controls
import Quickshell.Widgets
import qs

Rectangle {
    property PwNode audioNode: null
    property bool isMicrophone: false
    property bool showBackground: true
    property string title: ""

    Layout.fillWidth: true
    implicitHeight: mixerContent.implicitHeight + (showBackground ? 10 : 0)
    color: showBackground ? "#30" + Globals.colors.colors.color0 : "transparent"
    radius: showBackground ? 4 : 0

    PwObjectTracker {
        objects: audioNode ? [audioNode] : []
    }

    RowLayout {
        id: mixerContent
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            margins: showBackground ? 5 : 0
        }
        spacing: 8

        Components.VolumeSlider {
            Layout.fillWidth: true
            audioNode: parent.parent.audioNode
            isMicrophone: parent.parent.isMicrophone
            fontFamily: root.fontFamily
        }

        Button {
            Layout.preferredWidth: 25
            Layout.preferredHeight: 25
            background: null

            contentItem: IconImage {
                source: {
                    if (audioNode.audio.muted)
                        return isMicrophone ? Quickshell.iconPath("microphone-sensitivity-muted-symbolic") : Quickshell.iconPath("audio-volume-muted-symbolic");

                    const volume = audioNode.audio.volume;
                    const prefix = isMicrophone ? "microphone-sensitivity" : "audio-volume";
                    if (volume < 0.01)
                        return Quickshell.iconPath(`${prefix}-muted-symbolic`);
                    if (volume < 0.33)
                        return Quickshell.iconPath(`${prefix}-low-symbolic`);
                    if (volume < 0.66)
                        return Quickshell.iconPath(`${prefix}-medium-symbolic`);
                    return Quickshell.iconPath(`${prefix}-high-symbolic`);
                }
                implicitSize: 14
            }

            onClicked: {
                if (audioNode?.audio) {
                    audioNode.audio.muted = !audioNode.audio.muted;
                }
            }
        }
    }
}
