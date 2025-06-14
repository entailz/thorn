import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "root:/"

Rectangle {
    id: previewContainer

    property var colors
    property string currentImagePath

    signal navigateRequested(int direction)
    signal imageApplied(string imagePath)

    color: "#22" + colors.color0
    radius: 12

    Column {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 100
            text: {
                const parts = currentImagePath.split('/');
                const filename = parts[parts.length - 1];
                return filename;
            }
            font {
                family: Globals.font
                pointSize: 11
                weight: Font.Medium
            }
            elide: Text.ElideRight
            color: "#" + colors.color7
        }

        Rectangle {
            width: parent.width
            height: width
            color: "#11" + colors.color8
            radius: 8
            border.width: 2
            border.color: "#44" + colors.color9

            Image {
                id: previewImage
                anchors {
                    fill: parent
                    margins: 3
                }
                source: currentImagePath
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: previewImage.width
                        height: previewImage.height
                        radius: 8
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No Image"
                color: "#" + colors.color7
                font.pointSize: 10
                visible: !currentImagePath
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10

            Button {
                width: 30
                height: 30
                enabled: currentImagePath

                background: Rectangle {
                    radius: 15
                    color: leftMouseArea.containsMouse ? "#33" + colors.color8 : "#22" + colors.color8
                }

                contentItem: Text {
                    text: "◀"
                    color: "#" + colors.color7
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: leftMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateRequested(-1)
                }
            }

            Button {
                width: 30
                height: 30
                enabled: currentImagePath

                background: Rectangle {
                    radius: 15
                    color: rightMouseArea.containsMouse ? "#33" + colors.color8 : "#22" + colors.color8
                }

                contentItem: Text {
                    text: "▶"
                    color: "#" + colors.color7
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: rightMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: navigateRequested(1)
                }
            }
        }

        Button {
            width: parent.width
            height: 35
            hoverEnabled: true
            enabled: currentImagePath

            background: Rectangle {
                radius: 8
                color: applyMouseArea.containsMouse ? "#66" + colors.color8 : "#22" + colors.color8
                border.width: 1
                border.color: "#" + colors.color9
            }

            contentItem: Text {
                text: "Apply Wallpaper"
                color: "#A0A0A0"
                font {
                    family: Globals.font
                    pointSize: 10
                    weight: Font.Medium
                }
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: applyMouseArea
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    if (currentImagePath) {
                        imageApplied(currentImagePath);
                    }
                }
            }
        }
    }
}
