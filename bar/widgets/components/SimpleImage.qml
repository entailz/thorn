import QtQuick

Item {
    id: root

    property alias source: image.source
    property alias asynchronous: image.asynchronous
    property alias status: image.status
    property alias cache: image.cache
    property alias image: image

    property real size: Math.min(width, height)

    Image {
        id: image
        anchors.fill: parent
        // fillMode: Image.PreserveAspectFit

        sourceSize.width: root.size
        sourceSize.height: root.size
    }
}
