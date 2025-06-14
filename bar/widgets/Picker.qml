import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick.Controls
import "components" as Components
import "services" as Services
import "root:/"

Components.BarWidget {
    id: root
    color: "transparent"
    implicitHeight: 32
    implicitWidth: 24

    property color backgroundColor: Globals.backgroundColor

    HyprlandFocusGrab {
        id: grab
        windows: slidingLoader.item ? [slidingLoader.item] : []
        onCleared: {
            if (slidingLoader.item)
                slidingLoader.item.closeWithAnimation();
        }
    }

    property var colorPicker: Services.Hyprpicker

    Components.IconButton {
        id: colorSelect
        anchors.centerIn: parent
        icon: "colorize"
        size: 16
        outerSize: 18
        useVariableFill: true
        clickable: true
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.colorPicker.pickColor();
            } else if (mouse.button === Qt.RightButton) {
                slidingLoader.active = true;
                const popup = slidingLoader.item;
                popup.show();
                grab.active = true;
            }
        }

        Components.BarTooltip {
            relativeItem: colorSelect.containsMouse ? colorSelect : null
            offset: 2

            Label {
                font.family: Globals.secondaryFont
                font.pixelSize: 11
                font.hintingPreference: Font.PreferFullHinting
                color: "white"
                text: "Hyprpicker"
            }
        }
    }
    LazyLoader {
        id: slidingLoader
        component: slidingComponent
        // active: false
        loading: false

        Component {
            id: slidingComponent
            Components.SlidingPopup {
                id: slidingPopup
                anchor.item: root

                anchor.rect.x: -90
                anchor.rect.y: root.implicitHeight - 11
                implicitWidth: 200
                property bool open: false
                color: "transparent"

                onCloseAnimationFinished: {
                    grab.active = false;
                    slidingPopup.open = false;
                }

                contentItem: ClippingRectangle {
                    anchors.centerIn: parent
                    color: root.backgroundColor
                    implicitWidth: colorGrid.implicitWidth + 20
                    implicitHeight: colorGrid.implicitHeight + 16
                    radius: 12
                    contentInsideBorder: true
                    antialiasing: true
                    layer.samples: 4

                    Grid {
                        id: colorGrid
                        anchors.centerIn: parent
                        columns: Math.min(5, Math.max(1, root.colorPicker.colorHistory.length))
                        spacing: 8

                        Repeater {
                            model: root.colorPicker.colorHistory

                            Rectangle {
                                width: 24
                                height: 24
                                color: modelData
                                border.width: 1
                                border.color: "#44" + Globals.colors.colors.color13
                                radius: 4

                                property color textColor: {
                                    if (typeof modelData === "string" && modelData.startsWith("#") && (modelData.length === 7 || modelData.length === 9)) {
                                        const c = Qt.color(modelData);
                                        return Qt.rgba(1 - c.r, 1 - c.g, 1 - c.b, 1);
                                    }
                                    console.warn("Invalid color in history:", modelData);
                                    return "white";
                                }

                                Text {
                                    anchors {
                                        bottom: parent.bottom
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    text: modelData
                                    font.pixelSize: 6
                                    color: parent.textColor
                                    visible: colorMouseArea.containsMouse
                                }

                                MouseArea {
                                    id: colorMouseArea
                                    anchors.fill: parent

                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        root.colorPicker.copyToClipboard(modelData);
                                        slidingPopup.closeWithAnimation();
                                    }
                                }
                            }
                        }

                        Text {
                            visible: colorPicker.colorHistory.length === 0
                            text: "No colors in history"
                            color: "#FFFFFF"
                        }
                    }
                }
            }
        }
    }
}
