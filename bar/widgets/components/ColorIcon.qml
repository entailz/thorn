pragma ComponentBehavior: Bound
import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell.Widgets
import qs

Item {
    id: root
    required property var implicitSize
    required property var source
    property bool hovered: false
    property color hoverColor: "#" + Globals.colors.colors.color11
    property color normalColor: "#" + Globals.colors.colors.color6

    width: implicitSize
    height: implicitSize

    IconImage {
        id: iconImage
        anchors.fill: parent
        source: root.source
        layer.enabled: true
        layer.effect: ColorOverlay {
            color: root.normalColor
        }
    }

    Item {
        id: hoverContainer
        anchors.fill: parent
        opacity: root.hovered ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutQuad
            }
        }

        IconImage {
            id: hoverIconImage
            anchors.fill: parent
            source: root.source
            layer.enabled: true
            layer.effect: ColorOverlay {
                color: root.hoverColor
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: hoverContainer.width
                height: hoverContainer.height

                gradient: Gradient {
                    GradientStop {
                        id: gradientStart
                        position: root.hovered ? -0.3 : 0.7
                        color: "transparent"

                        Behavior on position {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    GradientStop {
                        id: gradientEnd
                        position: root.hovered ? 0.7 : 1.3
                        color: "white"

                        Behavior on position {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                rotation: -45
                transformOrigin: Item.Center

                scale: 1.5
            }
        }
    }
}
