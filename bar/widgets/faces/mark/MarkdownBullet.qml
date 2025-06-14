import QtQuick
import QtQuick.Layouts
import "root:/"

Item {
    id: root

    property var content: []

    implicitHeight: bulletRow.implicitHeight
    implicitWidth: bulletRow.implicitWidth

    RowLayout {
        id: bulletRow
        anchors.fill: parent
        spacing: 8

        Text {
            id: bulletSymbol
            text: "󰧞"
            font.family: "Nerd Font"
            font.pixelSize: 12
            color: "#C0C0C0"

            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 2
        }

        MarkdownParagraph {
            content: root.content

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
        }
    }
}
