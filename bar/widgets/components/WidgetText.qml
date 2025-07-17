import QtQuick
import qs

Rectangle {
    width: 200
    // implicitWidth: children[0].implicitWidth - children[0].implicitWidth / 2
    implicitHeight: children[0].implicitHeight
    color: "transparent"

    // border {
    //     color: "red"
    //     width: 1
    // }

    property alias text: t.text

    Text {
        id: t
        anchors.fill: parent
        font.family: Globals.font
        color: "#C5B4A8"
        font.pointSize: 10
        font.styleName: "Bold"
        elide: Text.ElideRight
    }
}
