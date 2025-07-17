import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    property int from: 0
    property int to: 100
    property int value: 0
    property int stepSize: 1
    property bool enabled: true
    property string suffix: ""
    property bool padZero: false

    implicitWidth: 80
    implicitHeight: 32

    function textFromValue(val) {
        const text = val.toString();
        return padZero ? text.padStart(2, '0') : text;
    }

    Rectangle {
        anchors.fill: parent
        color: "#22" + Globals.colors.colors.color8
        border.color: "#44" + Globals.colors.colors.color6
        border.width: 1
        radius: 8

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            color: "transparent"
            radius: 7

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.fillHeight: true
                    color: decreaseMouseArea.containsMouse ? "#33" + Globals.colors.colors.color4 : "transparent"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "−"
                        color: root.enabled ? "#" + Globals.colors.colors.color6 : "#66" + Globals.colors.colors.color6
                        font.family: Globals.font
                        font.pixelSize: 14
                        font.bold: true
                    }

                    MouseArea {
                        id: decreaseMouseArea
                        anchors.fill: parent
                        hoverEnabled: root.enabled
                        enabled: root.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.value > root.from) {
                                root.value -= root.stepSize;
                                root.valueChanged();
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: root.textFromValue(root.value) + root.suffix
                        color: root.enabled ? "#" + Globals.colors.colors.color6 : "#66" + Globals.colors.colors.color6
                        font.family: Globals.font
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.fillHeight: true
                    color: increaseMouseArea.containsMouse ? "#33" + Globals.colors.colors.color4 : "transparent"
                    radius: 4

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: root.enabled ? "#" + Globals.colors.colors.color6 : "#66" + Globals.colors.colors.color6
                        font.family: Globals.font
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: increaseMouseArea
                        anchors.fill: parent
                        hoverEnabled: root.enabled
                        enabled: root.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.value < root.to) {
                                root.value += root.stepSize;
                                root.valueChanged();
                            }
                        }
                    }
                }
            }
        }
    }
}
