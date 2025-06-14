pragma Singleton
import QtQuick

QtObject {
    id: markdownParser

    readonly property var elementTypes: ({
            HEADER1: "header1",
            HEADER2: "header2",
            HEADER3: "header3",
            HEADER4: "header4",
            HEADER5: "header5",
            HEADER6: "header6",
            PARAGRAPH: "paragraph",
            BULLET: "bullet",
            IMAGE: "image",
            BOLD: "bold",
            ITALIC: "italic",
            CODE: "code",
            LINK: "link"
        })

    readonly property var headerConfigs: ({
            "header1": {
                size: 18,
                color: "#BC87A9",
                symbol: "✥",
                weight: Font.Bold
            },
            "header2": {
                size: 17,
                color: "#7F7DC9",
                symbol: "✿",
                weight: Font.Bold
            },
            "header3": {
                size: 16,
                color: "#BB9382",
                symbol: "❀",
                weight: Font.Bold
            },
            "header4": {
                size: 15,
                color: "#56888E",
                symbol: "❃",
                weight: Font.Bold
            },
            "header5": {
                size: 14,
                color: "#7893D5",
                symbol: "✤",
                weight: Font.Bold
            },
            "header6": {
                size: 13,
                color: "#FF9FF3",
                symbol: "✺",
                weight: Font.Bold
            }
        })

    function parseText(text) {
        if (!text)
            return [];

        const lines = text.split("\n");
        let elements = [];

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const element = parseLine(line, i);
            if (element) {
                elements.push(element);
            }
        }

        return elements;
    }

    function parseLine(line, lineNumber) {
        if (!line.trim()) {
            return {
                type: elementTypes.PARAGRAPH,
                content: "",
                isEmpty: true,
                lineNumber: lineNumber
            };
        }

        const headerMatch = line.match(/^(#{1,6})\s+(.+)$/);
        if (headerMatch) {
            const level = headerMatch[1].length;
            const content = headerMatch[2];
            return {
                type: `header${level}`,
                content: content,
                level: level,
                lineNumber: lineNumber
            };
        }

        const bulletMatch = line.match(/^[\s]*[-*+]\s+(.+)$/);
        if (bulletMatch) {
            const content = bulletMatch[1];
            return {
                type: elementTypes.BULLET,
                content: parseInlineElements(content),
                lineNumber: lineNumber
            };
        }

        const imageMatch = line.match(/!\[([^\]]*)\]\(([^)]+)\)/);
        if (imageMatch) {
            return {
                type: elementTypes.IMAGE,
                alt: imageMatch[1],
                src: imageMatch[2],
                lineNumber: lineNumber
            };
        }

        return {
            type: elementTypes.PARAGRAPH,
            content: parseInlineElements(line),
            lineNumber: lineNumber
        };
    }

    function parseInlineElements(text) {
        let elements = [];
        let currentPos = 0;

        const patterns = [
            {
                regex: /\*\*([^*]+)\*\*/g,
                type: elementTypes.BOLD
            },
            {
                regex: /__([^_]+)__/g,
                type: elementTypes.BOLD
            },
            {
                regex: /\*([^*]+)\*/g,
                type: elementTypes.ITALIC
            },
            {
                regex: /_([^_]+)_/g,
                type: elementTypes.ITALIC
            },
            {
                regex: /`([^`]+)`/g,
                type: elementTypes.CODE
            },
            {
                regex: /\[([^\]]+)\]\(([^)]+)\)/g,
                type: elementTypes.LINK
            }
        ];

        let matches = [];

        patterns.forEach(pattern => {
            let match;
            while ((match = pattern.regex.exec(text)) !== null) {
                matches.push({
                    type: pattern.type,
                    start: match.index,
                    end: match.index + match[0].length,
                    content: match[1],
                    url: match[2] || null,
                    fullMatch: match[0]
                });
            }
        });

        matches.sort((a, b) => a.start - b.start);

        let lastEnd = 0;

        matches.forEach(match => {
            if (match.start > lastEnd) {
                const textBefore = text.substring(lastEnd, match.start);
                if (textBefore) {
                    elements.push({
                        type: "text",
                        content: textBefore
                    });
                }
            }

            elements.push({
                type: match.type,
                content: match.content,
                url: match.url
            });

            lastEnd = match.end;
        });

        if (lastEnd < text.length) {
            const remainingText = text.substring(lastEnd);
            if (remainingText) {
                elements.push({
                    type: "text",
                    content: remainingText
                });
            }
        }

        if (elements.length === 0) {
            elements.push({
                type: "text",
                content: text
            });
        }

        return elements;
    }
}
