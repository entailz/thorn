import QtQuick
import "services/record" as Service
import "root:/"
import "components" as Components
import QtQuick.Controls

Components.BarWidget {
    id: recorder
    color: "transparent"
    implicitWidth: hoverBackground.width
    implicitHeight: hoverBackground.height

    Component.onCompleted: {
        Service.RecorderProcess.blinkAnim = blinkAnim;
    }

    Rectangle {
        id: hoverBackground
        width: (statusText.text === "" ? indicatorDot.width : contentRow.width) + 16
        height: Math.max(contentRow.height, indicatorDot.height) + 12
        anchors.centerIn: parent
        radius: 6
        color: (statusTextMouseArea.containsMouse && statusText.text !== "") ? "#11c1c1c1" : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Components.IconButton {
        id: materialRecordButton
        icon: "videocam"
        size: 16
        outerSize: 20
        anchors.centerIn: parent
        useVariableFill: true
        clickable: true
        visible: !Service.RecorderProcess.selectionInProgress && !Service.RecorderProcess.recording

        onClicked: {
            Service.RecorderProcess.recording ? Service.RecorderProcess.stopRecording() : Service.RecorderProcess.startRecording();
        }
    }

    Row {
        id: contentRow
        spacing: 8
        anchors.centerIn: parent
        visible: Service.RecorderProcess.recording || Service.RecorderProcess.selectionInProgress

        Rectangle {
            id: indicatorDot
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            radius: 6
            color: Service.RecorderProcess.selectionInProgress ? "yellow" : "red"
            opacity: 0.3
            visible: Service.RecorderProcess.recording || Service.RecorderProcess.selectionInProgress

            SequentialAnimation {
                id: blinkAnim
                running: Service.RecorderProcess.recording || Service.RecorderProcess.selectionInProgress
                loops: Animation.Infinite
                alwaysRunToEnd: false

                NumberAnimation {
                    property: "opacity"
                    to: 0.3
                    duration: 500
                }
                NumberAnimation {
                    property: "opacity"
                    to: 1.0
                    duration: 500
                }

                onRunningChanged: {
                    if (!running)
                        indicatorDot.opacity = 0.3;
                }
            }
        }

        Text {
            id: statusText
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            text: {
                if (Service.RecorderProcess.recording) {
                    return `${Math.floor(Service.RecorderProcess.timer / 60)}:${(Service.RecorderProcess.timer % 60).toString().padStart(2, "0")}`;
                } else if (Service.RecorderProcess.selectionInProgress) {
                    return "Select area...";
                } else {
                    return "";
                }
            }
            font.pixelSize: 13
            font.family: Globals.secondaryFont
            color: "#" + Globals.colors.colors.color6
        }
    }

    MouseArea {
        id: statusTextMouseArea
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: hoverBackground
        visible: statusText.text !== ""
        onClicked: {
            Service.RecorderProcess.recording ? Service.RecorderProcess.stopRecording() : Service.RecorderProcess.startRecording();
        }
    }

    Components.BarTooltip {
        relativeItem: (materialRecordButton.hovered || (statusTextMouseArea.containsMouse && statusText.text !== "")) ? hoverBackground : null
        offset: 2

        Label {
            font.family: Globals.font
            font.pixelSize: 11
            font.hintingPreference: Font.PreferFullHinting
            color: "white"
            text: "Screen Recorder"
        }
    }

    Connections {
        target: Service.RecorderProcess
        function onRecordingStopped() {
            blinkAnim.running = false;
        }
    }
}
