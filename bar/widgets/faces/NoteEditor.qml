import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import "../services" as Service
import "../components" as Components

Rectangle {
    id: root

    property bool showPreview: false
    property alias noteText: noteTextArea.text

    property string filePath: Globals.notePath + "/note_" + new Date().toISOString().replace(/[:.]/g, "_") + ".md"

    signal saveRequested(string content, string path)

    color: "#33" + Globals.colors.colors.color0
    border.width: 1
    border.color: "#11" + Globals.colors.colors.color6
    radius: 8

    Canvas {
        id: undercurlCanvas
        width: 90
        y: 32
        x: 118
        height: 6

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            ctx.strokeStyle = "#303030";
            ctx.lineWidth = 1;
            ctx.beginPath();

            var amplitude = 2;
            var wavelength = 7;

            for (var x = 0; x <= width; x++) {
                var y = height - amplitude + amplitude * Math.sin((2 * Math.PI * x) / wavelength);
                if (x === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }

            ctx.stroke();
        }

        Component.onCompleted: undercurlCanvas.requestPaint()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 3

        RowLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
            }
            Item {
                Layout.fillWidth: true
            }

            Text {
                Layout.rightMargin: 22
                Layout.alignment: Qt.AlignHCenter
                text: "Scratch Pad"
                color: "#" + Globals.colors.colors.color6
                font.family: Globals.font
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Item {
                Layout.fillWidth: true
            }

            Components.IconButton {
                id: saveButton
                icon: "save"
                useVariableFill: true
                outerSize: 20
                clickable: true
                size: 20
                fillNormal: 0.0
                fillHover: 1.0

                Layout.alignment: Qt.AlignRight
                enabled: noteTextArea.text.trim() !== ""

                onClicked: {
                    const textContent = noteTextArea.text;

                    const dirPath = filePath.substring(0, filePath.lastIndexOf('/'));

                    Service.NoteSaver.saveAndClear(textContent, filePath, function () {
                        noteTextArea.text = "";
                        filePath = Service.NoteSaver.generateNotePath();
                    });
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 4

                Text {
                    id: lineNumbers
                    Layout.topMargin: 6
                    font.family: Globals.font
                    font.pixelSize: 14
                    color: "#606060"
                    text: {
                        const lines = noteTextArea.text.split("\n").length;
                        let out = "";
                        for (let i = 1; i <= lines; i++) {
                            out += i + "\n";
                        }
                        return out;
                    }
                    wrapMode: Text.NoWrap
                    visible: !showPreview
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 24
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !showPreview
                        clip: true

                        TextArea {
                            id: noteTextArea
                            placeholderText: "what's on your mind?..."
                            placeholderTextColor: "#303030"
                            wrapMode: TextEdit.Wrap
                            color: "#C0C0C0"
                            font.family: Globals.font
                            font.pixelSize: 14
                            background: null
                            selectByMouse: true
                        }
                    }

                    MarkdownRenderer {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: showPreview
                        markdownText: noteTextArea.text
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: filePathField
                Layout.fillWidth: true
                Layout.maximumWidth: 300
                placeholderText: "Enter file path"
                text: Globals.notePath + "/note_" + new Date().toISOString().replace(/[:.]/g, "_") + ".md"
                color: "#EEEEEE"
                font.family: Globals.font
                font.pixelSize: 12
                visible: false
                background: Rectangle {
                    color: "#22" + Globals.colors.colors.color0
                    radius: 4
                    border.color: parent.activeFocus ? "#" + Globals.colors.colors.color6 : "#333333"
                    border.width: 1
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                id: toggleContainer
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 160
                Layout.preferredHeight: 22
                color: "#22" + Globals.colors.colors.color0
                radius: 16
                border.width: 1
                border.color: "#33" + Globals.colors.colors.color6

                Rectangle {
                    id: toggleIndicator
                    width: parent.width / 2
                    height: parent.height - 4
                    radius: 14
                    color: "#" + Globals.colors.colors.color6
                    anchors.verticalCenter: parent.verticalCenter
                    x: showPreview ? parent.width / 2 + 2 : 2

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        radius: 16

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (showPreview) {
                                    showPreview = false;
                                }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "󰷈"
                                    font.family: "Nerd Font"
                                    font.pixelSize: 12
                                    color: !showPreview ? "#" + Globals.colors.colors.color0 : "#A0A0A0"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                Text {
                                    text: "Edit"
                                    font.family: Globals.font
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: !showPreview ? "#" + Globals.colors.colors.color0 : "#A0A0A0"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        radius: 16

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!showPreview) {
                                    showPreview = true;
                                }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "󰈈"
                                    font.family: "Nerd Font"
                                    font.pixelSize: 12
                                    color: showPreview ? "#" + Globals.colors.colors.color0 : "#A0A0A0"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }

                                Text {
                                    text: "Preview"
                                    font.family: Globals.font
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: showPreview ? "#" + Globals.colors.colors.color0 : "#A0A0A0"

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 200
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }
    Connections {
        target: Service.NoteSaver
        function onSaveCompleted(success, message) {
            if (success) {
                saveNotification.color = "#2E4B2E";
                saveNotification.text = message;
            } else {
                saveNotification.color = "#4B2E2E";
                saveNotification.text = message;
            }
            saveNotification.visible = true;
            saveNotificationPopup.show();
            notificationTimer.restart();
        }
    }
}
