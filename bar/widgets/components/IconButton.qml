import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import qs

Item {
    id: root
    property string icon
    readonly property bool containsMouse: mouseArea.containsMouse
    property bool enabled: true
    property bool highlight: true
    property bool clickable: false
    property bool useMask: true
    property bool useVariableFill: false
    property real size: 18
    property real outerSize: size
    property color hoverColor: "#22" + Globals.colors.colors.color2
    property color iconColor: "#" + Globals.colors.colors.color6
    property real buttonRadius: 6
    property real padding: 4

    property real fillValue: 0.0
    property real fillTarget: 0.0
    property real fillHover: 1.0
    property real fillNormal: 0.0
    property int fillDuration: 300

    signal clicked(var mouse)

    implicitWidth: outerSize + (padding * 2)
    implicitHeight: outerSize + (padding * 2)

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        radius: root.buttonRadius
        color: mouseArea.containsMouse && root.highlight ? root.hoverColor : "transparent"
        visible: root.highlight

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }

    NumberAnimation {
        id: fillAnimation
        target: root
        property: "fillValue"
        duration: root.fillDuration
        easing.type: Easing.OutCubic
        to: root.fillTarget
    }

    Text {
        id: variableFillIcon
        visible: root.useVariableFill
        anchors.centerIn: parent
        font.family: "Material Symbols Outlined"
        renderType: Text.NativeRendering
        textFormat: Text.PlainText
        font.pointSize: root.size * 0.8
        text: root.icon
        color: root.enabled ? root.iconColor : "#" + Globals.colors.colors.color8
        opacity: root.enabled ? 1.0 : 0.5

        font.variableAxes: {
            "FILL": root.fillValue.toFixed(1)
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }

    Item {
        id: maskedIcon
        visible: root.useMask && !root.useVariableFill
        anchors.centerIn: parent
        width: root.size
        height: root.size
        smooth: true
        layer.enabled: true
        layer.effect: OpacityMask {
            source: Rectangle {
                width: root.size
                height: root.size
                color: "white"
            }
            maskSource: IconImage {
                mipmap: true
                implicitSize: root.size
                source: root.useVariableFill ? "" : Quickshell.iconPath(root.icon)
                opacity: root.enabled ? 1.0 : 0.5
                smooth: true
            }
        }

        transform: Translate {
            x: mouseArea.containsMouse ? -1 : 0
            y: mouseArea.containsMouse ? -2 : 0

            Behavior on x {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutElastic
                    easing.amplitude: 1.0
                    easing.period: 0.3
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutElastic
                    easing.amplitude: 1.0
                    easing.period: 0.3
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: root.enabled ? root.iconColor : "#" + Globals.colors.colors.color8

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }

    IconImage {
        id: unmaskedIcon
        visible: !root.useMask && !root.useVariableFill
        anchors.centerIn: parent
        source: root.useVariableFill ? "" : Quickshell.iconPath(root.icon)
        implicitSize: root.size
        opacity: root.enabled ? 1.0 : 0.5

        transform: Translate {
            x: mouseArea.containsMouse ? -1 : 0
            y: mouseArea.containsMouse ? -2 : 0

            Behavior on x {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutElastic
                    easing.amplitude: 1.0
                    easing.period: 0.6
                }
            }

            Behavior on y {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutElastic
                    easing.amplitude: 1.0
                    easing.period: 0.6
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.clickable && root.enabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function (mouse) {
            root.clicked(mouse);
        }

        onContainsMouseChanged: {
            if (root.useVariableFill) {
                root.fillTarget = containsMouse ? root.fillHover : root.fillNormal;
                fillAnimation.restart();
            }
        }
    }

    Component.onCompleted: {
        if (useVariableFill) {
            fillValue = fillNormal;
        }
    }
}
