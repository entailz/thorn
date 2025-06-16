import QtQuick
import "root:/"

Item {
    id: root

    property string src: ""
    property string alt: ""
    property int maxWidth: 400
    property int maxHeight: 300

    implicitHeight: imageLoader.status === Loader.Ready ? imageLoader.item.height : placeholderHeight
    implicitWidth: imageLoader.status === Loader.Ready ? imageLoader.item.width : maxWidth

    readonly property int placeholderHeight: 100

    Loader {
        id: imageLoader
        anchors.centerIn: parent

        sourceComponent: {
            if (root.src.startsWith("http://") || root.src.startsWith("https://") || root.src.startsWith("file://")) {
                return imageComponent;
            } else {
                return placeholderComponent;
            }
        }
    }

    Component {
        id: imageComponent
        Column {
            spacing: 8

            Image {
                id: actualImage
                source: root.src
                fillMode: Image.PreserveAspectFit

                width: Math.min(sourceSize.width, root.maxWidth)
                height: Math.min(sourceSize.height, root.maxHeight)

                Component.onCompleted: {
                    if (sourceSize.width > 0 && sourceSize.height > 0) {
                        const aspectRatio = sourceSize.width / sourceSize.height;
                        if (width / height > aspectRatio) {
                            width = height * aspectRatio;
                        } else {
                            height = width / aspectRatio;
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 1
                    border.color: "#33" + Globals.colors.colors.color6
                    radius: 8
                    visible: parent.status === Image.Ready
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    color: "#22" + Globals.colors.colors.color0
                    radius: 8
                    visible: parent.status === Image.Loading

                    Text {
                        anchors.centerIn: parent
                        text: "Loading..."
                        color: "#A0A0A0"
                        font.family: Globals.font
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#22" + Globals.colors.colors.color0
                    radius: 8
                    border.width: 1
                    border.color: "#A67676"
                    visible: parent.status === Image.Error

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰋩"
                            color: "#A67676"
                            font.family: "Nerd Font"
                            font.pixelSize: 24
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Failed to load image"
                            color: "#A67676"
                            font.family: Globals.font
                            font.pixelSize: 12
                        }
                    }
                }
            }

            Text {
                visible: root.alt && root.alt.trim() !== ""
                text: root.alt
                color: "#909090"
                font.family: Globals.font
                font.pixelSize: 12
                font.italic: true
                wrapMode: Text.Wrap
                width: actualImage.width
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Component {
        id: placeholderComponent
        Rectangle {
            width: root.maxWidth
            height: root.placeholderHeight
            color: "#22" + Globals.colors.colors.color0
            radius: 8
            border.width: 1
            border.color: "#33" + Globals.colors.colors.color6

            Column {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰋩"
                    color: "#606060"
                    font.family: "Nerd Font"
                    font.pixelSize: 24
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.alt || "Image"
                    color: "#606060"
                    font.family: Globals.font
                    font.pixelSize: 12
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.src
                    color: "#404040"
                    font.family: Globals.font
                    font.pixelSize: 10
                    elide: Text.ElideMiddle
                    width: root.maxWidth - 20
                }
            }
        }
    }
}
