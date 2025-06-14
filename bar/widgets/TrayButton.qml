import QtQuick

Item {
    id: root
    width: 26
    height: 26

    signal clicked(var mouse)

    Rectangle {
        id: hoverBackground
        anchors.fill: parent
        radius: 6
        color: mouseArea.containsMouse ? "#11c1c1c1" : "transparent"
        z: -1
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: mouse => {
            root.clicked(mouse);
        }
    }

    default property alias content: contentItem.data

    Item {
        id: contentItem
        anchors.centerIn: parent
    }
}
