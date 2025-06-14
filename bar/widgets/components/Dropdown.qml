import QtQuick

Column {
    id: root
    property var model: []
    // property var anchorItem: null
    property bool visibleOverlay: false
    // property int widgewidth: 200
    signal itemClicked(var item)

    width: 280
    visible: visibleOverlay
    opacity: visibleOverlay ? 1 : 0

    Rectangle {
        width: 280
        height: listView.contentHeight
        color: "transparent"
        radius: 6
        // height: 100
        border.color: "transparent"
        clip: true

        ListView {
            id: listView
            model: root.model
            interactive: true
            spacing: 4
            width: parent.width
            implicitHeight: contentHeight

            delegate: Rectangle {
                width: parent.width
                height: 30
                color: "transparent"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.itemClicked(modelData);
                        root.visibleOverlay = false;
                    }

                    Text {
                        anchors.centerIn: parent
                        text: typeof modelData === "string" ? modelData : modelData.name
                        color: "white"
                        font.pixelSize: 14
                        font.family: Globals.font
                    }
                }
            }
        }
    }
}
