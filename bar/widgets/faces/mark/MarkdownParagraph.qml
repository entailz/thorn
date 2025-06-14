import QtQuick
import "root:/"

Item {
    id: root

    property var content: []
    property bool isEmpty: false

    implicitHeight: isEmpty ? 12 : textFlow.implicitHeight
    implicitWidth: textFlow.implicitWidth

    Flow {
        id: textFlow
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: content

            Loader {
                sourceComponent: {
                    const element = modelData;
                    switch (element.type) {
                    case "text":
                        return textComponent;
                    case MarkdownParser.elementTypes.BOLD:
                        return boldComponent;
                    case MarkdownParser.elementTypes.ITALIC:
                        return italicComponent;
                    case MarkdownParser.elementTypes.CODE:
                        return codeComponent;
                    case MarkdownParser.elementTypes.LINK:
                        return linkComponent;
                    default:
                        return textComponent;
                    }
                }

                property var elementData: modelData
            }
        }
    }

    Component {
        id: textComponent
        Text {
            text: elementData.content
            font.family: Globals.font
            font.pixelSize: 14
            color: "#C0C0C0"
            wrapMode: Text.Wrap
        }
    }

    Component {
        id: boldComponent
        Text {
            text: elementData.content
            font.family: Globals.font
            font.pixelSize: 14
            font.weight: Font.Bold
            color: "#C0C0C0"
            wrapMode: Text.Wrap
        }
    }

    Component {
        id: italicComponent
        Text {
            text: elementData.content
            font.family: Globals.font
            font.pixelSize: 14
            font.italic: true
            color: "#C0C0C0"
            wrapMode: Text.Wrap
        }
    }

    Component {
        id: codeComponent
        Rectangle {
            width: codeText.implicitWidth + 8
            height: codeText.implicitHeight + 4
            color: "#22" + Globals.colors.colors.color0
            radius: 4
            border.width: 1
            border.color: "#33" + Globals.colors.colors.color6

            Text {
                id: codeText
                anchors.centerIn: parent
                text: elementData.content
                font.family: "monospace"
                font.pixelSize: 12
                color: "#E0E0E0"
            }
        }
    }

    Component {
        id: linkComponent
        Text {
            text: elementData.content
            font.family: Globals.font
            font.pixelSize: 14
            color: "#" + Globals.colors.colors.color6
            font.underline: true
            wrapMode: Text.Wrap

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (elementData.url) {
                        Qt.openUrlExternally(elementData.url);
                    }
                }
            }
        }
    }
}
