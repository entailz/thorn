import QtQuick
import QtQuick.Controls
import "root:/"
import "mark" as Md

ScrollView {
    id: root
    property string markdownText: ""
    property var parsedElements: []
    clip: true

    property var parser: Md.MarkdownParser

    onMarkdownTextChanged: {
        if (parser && typeof parser.parseText === 'function') {
            parsedElements = parser.parseText(markdownText);
        } else {
            parsedElements = [];
        }
    }

    Component.onCompleted: {
        if (markdownText && parser && typeof parser.parseText === 'function') {
            parsedElements = parser.parseText(markdownText);
        }
    }

    Column {
        id: contentColumn
        width: root.width
        spacing: 8
        padding: 12

        Repeater {
            model: root.parsedElements

            Loader {
                id: elementLoader
                width: contentColumn.width - contentColumn.padding * 2

                sourceComponent: {
                    if (!modelData || !root.parser)
                        return paragraphComponent;

                    const element = modelData;
                    const types = root.parser.elementTypes;

                    switch (element.type) {
                    case types.HEADER1:
                    case types.HEADER2:
                    case types.HEADER3:
                    case types.HEADER4:
                    case types.HEADER5:
                    case types.HEADER6:
                        return headerComponent;
                    case types.BULLET:
                        return bulletComponent;
                    case types.IMAGE:
                        return imageComponent;
                    case types.PARAGRAPH:
                    default:
                        return paragraphComponent;
                    }
                }

                property var elementData: modelData || {}
            }
        }

        Item {
            width: 1
            height: 20
        }
    }

    Component {
        id: headerComponent
        Md.MarkdownHeader {
            width: parent ? parent.width : 0
            text: elementData.content || ""
            level: elementData.level || 1
        }
    }

    Component {
        id: paragraphComponent
        Md.MarkdownParagraph {
            width: parent ? parent.width : 0
            content: elementData.content || ""
            isEmpty: elementData.isEmpty || false
        }
    }

    Component {
        id: bulletComponent
        Md.MarkdownBullet {
            width: parent ? parent.width : 0
            content: elementData.content || ""
        }
    }

    Component {
        id: imageComponent
        Md.MarkdownImage {
            width: parent ? parent.width : 0
            src: elementData.src || ""
            alt: elementData.alt || ""
            maxWidth: parent ? parent.width - 40 : 200
        }
    }
}
