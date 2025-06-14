import QtQuick

FocusScope {
    id: keyHandler

    property var parentRoot: null

    signal navigateRequested(int direction)
    signal imageSelected
    signal popupClosed

    Keys.onPressed: function (event) {
        switch (event.key) {
        case Qt.Key_Left:
            navigateRequested(-1);
            event.accepted = true;
            break;
        case Qt.Key_Right:
            navigateRequested(1);
            event.accepted = true;
            break;
        case Qt.Key_Up:
            navigateRequested(-4);
            event.accepted = true;
            break;
        case Qt.Key_Down:
            navigateRequested(4);
            event.accepted = true;
            break;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            imageSelected();
            event.accepted = true;
            break;
        case Qt.Key_Escape:
            popupClosed();
            event.accepted = true;
            break;
        default:
            break;
        }
    }
}
