import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs

Rectangle {
    id: root
    color: "transparent"
    radius: 8

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120

            Image {
                id: profileImage
                anchors.fill: parent
                source: UserProfile.profileImagePath
                visible: false
                fillMode: Image.PreserveAspectCrop
            }

            Rectangle {
                id: mask
                anchors.fill: parent
                radius: 10
                visible: false
                color: "white"
            }

            OpacityMask {
                anchors.fill: parent
                source: profileImage
                maskSource: mask
            }

            Text {
                anchors.centerIn: parent
                text: UserProfile.getInitials()
                font.family: Globals.font
                font.pixelSize: 50
                color: "#A0A0A0"
                visible: profileImage.status === Image.Error || profileImage.status === Image.Null
            }

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "transparent"
                border.width: 2
                border.color: "#" + Globals.colors.colors.color6
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: UserProfile.name
            color: "#" + Globals.colors.colors.color6
            font.family: "Modor"
            font.pixelSize: 34
            font.weight: Font.Medium
            Layout.preferredHeight: 18
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 80
            Layout.preferredHeight: 48
            radius: 12
            color: "transparent"

            RowLayout {
                anchors.centerIn: parent
                spacing: 4

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: UserProfile.statusColor
                }

                Text {
                    text: UserProfile.status
                    color: "#A0A0A0"
                    font.family: Globals.font
                    font.pixelSize: 12
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                color: "transparent"
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 4

                    Text {
                        text: "Last activity @ " + UserProfile.lastActivity
                        color: "#909090"
                        font.family: Globals.secondaryFont
                        font.pixelSize: 11
                        Layout.alignment: Qt.AlignHCenter
                        font.bold: false
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignHCenter
                color: "transparent"
                radius: 4

                RowLayout {
                    anchors.centerIn: parent
                    anchors.margins: 20

                    Text {
                        text: "Theme: " + UserProfile.theme
                        color: "#909090"
                        font.family: Globals.font
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
