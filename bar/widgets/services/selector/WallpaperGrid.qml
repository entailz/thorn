import QtQuick

GridView {
    property int columns: Math.max(4, Math.floor(width / 140))

    cellWidth: width / columns
    cellHeight: cellWidth
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    signal imageSelected(string path, int index)

    delegate: WallpaperGridItem {
        required property var modelData
        required property int index

        width: gridView.cellWidth
        height: gridView.cellHeight
        imagePath: modelData
        isSelected: index === root.currentImageIndex

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                gridView.imageSelected(modelData, index);
            }
        }
    }
}
