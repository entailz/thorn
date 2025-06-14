import QtQuick
import "root:/"

Item {
    property alias text: keyText.text

    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight

    Row {
        id: contentRow
        spacing: 4

        Text {
            id: keyText
            font.family: "Fanwood Text"
            font.pointSize: 10
            color: "#" + Globals.colors.colors.color7
        }
    }
}
