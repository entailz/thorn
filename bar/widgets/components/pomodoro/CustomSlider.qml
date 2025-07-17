import QtQuick
import qs

Item {
    id: root

    property int from: 1
    property int to: 60
    property int value: 25
    property int stepSize: 1
    property bool enabled: true
    property string label: ""
    property string suffix: "m"
    property color accentColor: "#" + Globals.colors.colors.color4

    implicitWidth: 200
    implicitHeight: 60

    Column {
        anchors.fill: parent
        spacing: 8

        Row {
            width: parent.width

            Text {
                text: root.label
                color: "#A0A0A0"
                font.family: Globals.font
                font.pixelSize: 11
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                // Layout.fillWidth: true
                width: parent.width - valueText.width - (parent.children[0].width || 0)
            }

            Text {
                id: valueText
                text: root.value + root.suffix
                color: "#" + Globals.colors.colors.color6
                font.family: Globals.font
                font.pixelSize: 12
                // font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: parent.width
            height: 20
            color: "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 8
                height: 4
                color: "#33" + Globals.colors.colors.color8
                radius: 2
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                width: Math.max(0, (parent.width - 8) * ((root.value - root.from) / (root.to - root.from)))
                height: 4
                color: root.enabled ? root.accentColor : "#66" + root.accentColor.toString().slice(1)
                radius: 2

                Behavior on width {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }
            }

            Rectangle {
                id: handle
                x: Math.max(0, Math.min(parent.width - width, 4 + (parent.width - 8 - width) * ((root.value - root.from) / (root.to - root.from))))
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                color: root.enabled ? root.accentColor : "#66" + root.accentColor.toString().slice(1)
                radius: 8
                border.color: "#" + Globals.colors.colors.color0
                border.width: 2

                scale: handleMouseArea.pressed ? 1.2 : (handleMouseArea.containsMouse ? 1.1 : 1.0)

                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }

                Behavior on x {
                    NumberAnimation {
                        duration: 100
                        easing.type: Easing.OutQuad
                    }
                }
            }

            MouseArea {
                id: handleMouseArea
                anchors.fill: parent
                hoverEnabled: root.enabled
                enabled: root.enabled
                cursorShape: Qt.PointingHandCursor

                onPressed: mouse => {
                    updateValue(mouse.x);
                }

                onPositionChanged: mouse => {
                    if (pressed) {
                        updateValue(mouse.x);
                    }
                }

                function updateValue(x) {
                    const trackWidth = parent.width - 8;
                    const relativeX = Math.max(0, Math.min(trackWidth, x - 4));
                    const ratio = relativeX / trackWidth;
                    const newValue = Math.round(root.from + ratio * (root.to - root.from));

                    if (newValue !== root.value) {
                        root.value = newValue;
                        root.valueChanged();
                    }
                }
            }
        }
    }
}
