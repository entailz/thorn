import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/"
import "../../components" as Components

Row {
    id: controlsRow

    property var colors
    property string selectedShader
    property var palettes
    property string currentPalette

    signal shaderChanged(string shader)
    // signal paletteChanged(string palette)
    signal searchToggled(bool visible)
    signal randomRequested

    spacing: 20
    height: 40

    Button {
        id: searchButton
        y: 5
        width: 30
        height: 30

        background: Rectangle {
            radius: 5
            color: searchMouseArea.containsMouse ? "#66" + colors.color8 : "#22" + colors.color8
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        contentItem: Components.ColorIcon {
            source: Quickshell.iconPath("search-icon")
            implicitSize: 30
        }

        MouseArea {
            id: searchMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: searchToggled(true)
        }
    }

    Rectangle {
        width: 80
        height: 40
        radius: 20
        color: "#AA" + colors.color0

        Rectangle {
            id: shaderButton
            width: 80
            height: 40
            radius: 20
            color: buttonMouseArea.containsMouse ? "#66" + colors.color8 : "#22" + colors.color8

            property int currentIndex: 0
            property var shaderModel: [
                {
                    name: "   Peel",
                    path: "shaders/Peel.frag.qsb"
                },
                {
                    name: "󱗜   Circle",
                    path: "shaders/circlePit.frag.qsb"
                },
                {
                    name: "󱓈   Doom",
                    path: "shaders/Doom.frag.qsb"
                }
            ]

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            MouseArea {
                id: buttonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (shaderPopupLoader.item && shaderPopupLoader.item.visible) {
                        shaderPopupLoader.item.closeWithAnimation();
                    } else if (shaderPopupLoader.active) {
                        shaderPopupLoader.item.show();
                    } else {
                        shaderPopupLoader.activeAsync = true;
                    }
                }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 10
                spacing: 5

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: shaderButton.shaderModel[shaderButton.currentIndex].name
                    font {
                        family: Globals.secondaryFont
                        pixelSize: 14
                        weight: Font.Medium
                    }
                    color: "#" + colors.color6
                }

                Item {
                    width: 18
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: "#" + colors.color7
                        font.pixelSize: 12
                    }
                }
            }

            LazyLoader {
                id: shaderPopupLoader
                loading: false

                Components.SlidingPopup {
                    anchor.rect.x: controlsRow.width / 2 - width / 2 - 80
                    anchor.rect.y: 50
                    anchor.window: controlsRow.parent
                    implicitWidth: 180
                    implicitHeight: contentColumn.implicitHeight + 28
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#BB" + colors.color0
                        radius: 6
                        border.width: 1
                        border.color: "#22" + colors.color6

                        Column {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 1

                            Repeater {
                                model: shaderButton.shaderModel

                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: parent.width
                                    height: 36
                                    color: shaderButton.currentIndex === index ? "#44" + colors.color4 : itemMouseArea.containsMouse ? "#22" + colors.color4 : "transparent"
                                    radius: 4

                                    MouseArea {
                                        id: itemMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            shaderButton.currentIndex = index;
                                            controlsRow.shaderChanged(modelData.path);
                                            shaderPopupLoader.item.closeWithAnimation();
                                        }
                                    }

                                    Text {
                                        anchors {
                                            left: parent.left
                                            leftMargin: 15
                                            verticalCenter: parent.verticalCenter
                                        }
                                        text: modelData.name
                                        color: "#" + colors.color7
                                        font {
                                            family: Globals.secondaryFont
                                            pixelSize: 14
                                            weight: Font.Medium
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: paletteSelector
        width: 140
        height: 40
        radius: 20
        color: "#AA" + colors.color0
        visible: palettes.length > 1

        Rectangle {
            id: paletteButton
            anchors.fill: parent
            radius: 20
            color: paletteMouseArea.pressed ? "#44" + colors.color8 : paletteMouseArea.containsMouse ? "#66" + colors.color8 : "#33" + colors.color8

            property string currentText: palettes[0] || ""

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            MouseArea {
                id: paletteMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (palettePopupLoader.item && palettePopupLoader.item.visible) {
                        palettePopupLoader.item.closeWithAnimation();
                    } else if (palettePopupLoader.active) {
                        palettePopupLoader.item.show();
                    } else {
                        palettePopupLoader.activeAsync = true;
                    }
                }
            }

            Text {
                anchors {
                    left: parent.left
                    right: dropdownIndicator.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 15
                    rightMargin: 5
                }
                text: paletteButton.currentText
                font {
                    family: Globals.font
                    pixelSize: 13
                }
                color: "#" + colors.color6
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: dropdownIndicator
                width: 22
                height: 22
                radius: 11
                color: "#44" + colors.color4
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 10
                }

                Text {
                    text: "⯆"
                    color: "#" + colors.color7
                    anchors.centerIn: parent
                    font.pixelSize: 12
                }
            }

            LazyLoader {
                id: palettePopupLoader
                loading: false

                Components.SlidingPopup {
                    anchor.rect.y: paletteButton.height * 1.2
                    anchor.rect.x: controlsRow.width / 2 + 220 + 100
                    anchor.window: controlsRow.parent
                    implicitWidth: paletteButton.width * 1.5
                    implicitHeight: Math.min(contentColumn2.implicitHeight + 30, 300)
                    color: "transparent"

                    Rectangle {
                        anchors.fill: parent
                        color: "#BB" + colors.color0
                        radius: 6
                        border.width: 1
                        border.color: "#22" + colors.color6
                        anchors.margins: 2

                        ScrollView {
                            id: scrollView
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true

                            Column {
                                id: contentColumn2
                                width: scrollView.width

                                Repeater {
                                    model: palettes

                                    delegate: Rectangle {
                                        required property var modelData
                                        required property int index
                                        width: parent.width
                                        height: 36
                                        color: paletteButton.currentText === modelData ? "#44" + colors.color4 : paletteItemMouseArea.containsMouse ? "#22" + colors.color4 : "transparent"
                                        radius: 4

                                        MouseArea {
                                            id: paletteItemMouseArea
                                            cursorShape: Qt.PointingHandCursor
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                paletteButton.currentText = modelData;
                                                controlsRow.paletteChanged(modelData);
                                                palettePopupLoader.item.closeWithAnimation();
                                            }
                                        }

                                        Text {
                                            anchors {
                                                left: parent.left
                                                leftMargin: 15
                                                verticalCenter: parent.verticalCenter
                                            }
                                            text: modelData
                                            color: "#" + colors.color7
                                            font {
                                                family: Globals.font
                                                pixelSize: 13
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Button {
        id: randomButton
        y: 5
        width: 30
        height: 30

        background: Rectangle {
            radius: 4
            color: randomMouseArea.containsMouse ? "#66" + colors.color8 : "#22" + colors.color8
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        contentItem: Components.ColorIcon {
            source: Quickshell.iconPath("randomize")
            implicitSize: 30
        }

        MouseArea {
            id: randomMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: randomRequested()
        }
    }
}
