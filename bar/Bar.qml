import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
// import "widgets/notis" as Notis
import Quickshell.Wayland
import "widgets" as Widgets
import qs

Variants {
    model: Quickshell.screens
    PanelWindow {
        id: root

        required property var modelData
        readonly property bool vert: Globals.vertical
        property int vertMargin: 3
        screen: modelData
        property color backgroundColor: Globals.backgroundColor

        WlrLayershell.namespace: "thorn"
        // WlrLayershell.layer: WlrLayer.Top
        // exclusionMode: ExclusionMode.Normal

        implicitHeight: 42
        implicitWidth: 44
        color: "transparent"

        anchors {
            top: true
            left: true
            bottom: root.vert
            right: !root.vert
        }

        Rectangle {
            id: bar
            anchors {
                fill: parent
                margins: 5
            }
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: root.vert ? 2 : -2
                verticalOffset: 2
                radius: 6
                spread: 0.2
                samples: 20
                color: "#30000000"
            }

            x: root.vert ?? 10
            y: !root.vert ?? 10
            implicitWidth: root.vert ? 48 : Screen.width - 8
            implicitHeight: root.vert ? Screen.height - 8 : 42
            color: root.backgroundColor
            radius: 8
            layer.enabled: true
            layer.smooth: true
            layer.samples: 8

            Loader {
                anchors.fill: parent
                sourceComponent: root.vert ? verticalLayoutComponent : horizontalLayoutComponent
            }
            Widgets.Faces {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 70

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 1
                height: parent.height
                visible: !root.vert
            }

            Component {
                id: horizontalLayoutComponent

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        Layout.alignment: Qt.AlignLeft
                        Layout.fillWidth: false
                        Widgets.Power {
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                        }
                        // Widgets.Overview {
                        //     Layout.fillWidth: true
                        //     Layout.topMargin: -3
                        //
                        //     Layout.leftMargin: 4
                        // }

                        // Notis.NotificationIndicator {
                        //     Layout.fillHeight: true
                        // }
                        Widgets.Workspaces {
                            Layout.fillWidth: true

                            Layout.alignment: Qt.AlignHCenter
                            // Layout.preferredWidth: 180
                            Layout.topMargin: -2
                            Layout.leftMargin: 4
                        }

                        // Layout.rightMargin: 10
                        // Widgets.Pomodoro {
                        //     // Layout.leftMargin: -4
                        //     Layout.rightMargin: 4
                        //     Layout.topMargin: 3
                        // }
                        Widgets.Recorder {
                            id: recorder
                            Layout.topMargin: -2
                        }

                        Widgets.ActiveWindow {
                            layer.enabled: true
                            Layout.fillHeight: true
                            // Layout.leftMargin: 400
                            Layout.topMargin: -9
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Widgets.Faces {
                    //     // anchors.centerIn: parent
                    //     Layout.topMargin: -5
                    //     Layout.preferredWidth: 70
                    // }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Layout.fillWidth: false

                        Widgets.SystemTray {
                            Layout.fillHeight: true
                        }
                        Widgets.Wallpaper {

                            Layout.topMargin: -1
                        }

                        Widgets.PipewireCava {
                            Layout.bottomMargin: 1.3
                            Layout.rightMargin: 6
                        }

                        Widgets.Mpris {
                            Layout.fillHeight: true
                            Layout.topMargin: 2
                            Layout.rightMargin: 6
                        }
                    }
                }
            }

            Component {
                id: verticalLayoutComponent

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillHeight: false

                        // Widgets.Overview {
                        //     // Layout.fillWidth: true
                        //
                        //     Layout.topMargin: 14
                        //     Layout.leftMargin: root.vertMargin
                        // }

                        Widgets.Workspaces {
                            Layout.topMargin: 2
                            Layout.leftMargin: root.vertMargin
                        }

                        Widgets.Recorder {
                            Layout.leftMargin: root.vertMargin - 2
                        }

                        Widgets.Clock {
                            Layout.topMargin: 250
                            Layout.leftMargin: root.vertMargin
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                    Widgets.SystemTray {}

                    Widgets.Picker {

                        Layout.leftMargin: root.vertMargin
                        Layout.bottomMargin: 20
                    }

                    ColumnLayout {
                        Layout.alignment: Qt.AlignBottom
                        Layout.fillHeight: false

                        Item {
                            Layout.fillWidth: true
                        }
                        Widgets.PipewireCava {}

                        Widgets.Mpris {
                            Layout.fillWidth: true
                            Layout.leftMargin: root.vertMargin + 2
                            // Layout.alignment: Qt.AlignHCenter
                            Layout.bottomMargin: 60
                        }
                    }
                }
            }
        }
    }
}
