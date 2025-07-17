pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs
import "../services" as Service

GridView {
    id: gridView

    property int itemsPerRow: 4

    signal executeApp(var entry)
    signal indexChanged(int index)

    clip: true
    model: Service.RunnerAppModel.appModel
    cellWidth: width / itemsPerRow
    cellHeight: 100
    currentIndex: 0

    highlight: Rectangle {
        color: "#40" + Globals.colors.colors.color2
        radius: 8
    }

    highlightMoveDuration: 100

    onCurrentIndexChanged: indexChanged(currentIndex)

    delegate: Item {
        id: gridViewDelegate
        required property var modelData
        required property int index
        width: gridView.cellWidth
        height: gridView.cellHeight

        Rectangle {
            anchors.fill: parent
            anchors.margins: 5
            radius: 8
            color: "transparent"

            Column {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: Quickshell.iconPath(gridViewDelegate.modelData.icon, "system-help")
                    sourceSize.width: 48
                    sourceSize.height: 48
                    width: 48
                    height: 48
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: gridView.cellWidth - 20
                    text: gridViewDelegate.modelData.name
                    font.family: "Fanwood Text"
                    font.pointSize: 12
                    color: "#" + Globals.colors.colors.color7
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                gridView.currentIndex = index;
            }
            onClicked: {
                gridView.executeApp(gridViewDelegate.modelData.entry);
            }
        }
    }
}
