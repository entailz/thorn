import "Bluetooth.qml"
import QtQuick
import Quickshell

ShellRoot {
    Component.onCompleted: {
        id: "bt";
        Bluetooth.btProcessRef = false;
    }
}
