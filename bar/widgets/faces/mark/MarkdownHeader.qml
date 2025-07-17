import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    property alias text: headerText.text
    property int level: 1
    property bool showSymbol: true

    readonly property var config: {
        if (typeof MarkdownParser !== 'undefined' && MarkdownParser.headerConfigs) {
            return MarkdownParser.headerConfigs[`header${level}`] || MarkdownParser.headerConfigs.header1;
        }
        return {
            size: 16 + (6 - level) * 2,
            color: "#FFFFFF",
            symbol: "●",
            weight: Font.Bold
        };
    }

    implicitHeight: headerRow.implicitHeight
    implicitWidth: headerRow.implicitWidth

    RowLayout {
        id: headerRow
        anchors.fill: parent
        spacing: 8

        Text {
            id: symbolText
            text: config.symbol || "●"
            font.family: Globals.font
            font.pixelSize: config.size || 16
            font.weight: config.weight || Font.Bold
            color: config.color || "#FFFFFF"
            visible: showSymbol

            Layout.alignment: Qt.AlignBaseline
        }

        Text {
            id: headerText
            font.family: Globals.secondaryFont
            font.pixelSize: config.size || 16
            font.weight: config.weight || Font.Bold
            color: config.color || "#FFFFFF"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBaseline
        }
    }
}
