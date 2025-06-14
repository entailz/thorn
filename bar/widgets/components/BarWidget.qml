import QtQuick

Rectangle {
    id: root

    property real padding: 3
    default property alias data: content.data

    property alias widgetImplicitHeight: content.implicitHeight
    property alias widgetImplicitWidth: content.implicitWidth

    property alias widgetAnchors: content.anchors

    implicitWidth: content.implicitWidth + widgetAnchors.leftMargin + widgetAnchors.rightMargin

    implicitHeight: content.implicitHeight + widgetAnchors.topMargin + widgetAnchors.bottomMargin

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.padding

        implicitWidth: children[0]?.implicitWidth ?? 0
        implicitHeight: children[0]?.implicitHeight ?? 0
    }
}
