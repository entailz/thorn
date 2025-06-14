import QtQuick.Layouts
import QtQuick

RowLayout {
    signal navigateRequested(int direction)
    spacing: 12

    ModernButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        text: "←"
        enabled: parent.enabled

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navigateRequested(-1)
        }
    }

    ModernButton {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        text: "→"
        enabled: parent.enabled

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: navigateRequested(1)
        }
    }
}
