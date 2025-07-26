import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import QtQuick.Effects
import "root:/"
import "../../components" as Components

PopupWindow {
    id: notificationPopupWindow

    property var notification: null

    property string notificationAppIcon: ""
    property string notificationAppName: ""
    property string notificationSummary: "Notification"
    property string notificationBody: ""

    property int timeout: 5000

    signal closed
    signal activated

    color: "transparent"

    property real popupY: 0

    property bool hasActions: notification && notification.actions.length > 0
    property int baseHeight: 80
    property int actionButtonHeight: 32
    property int actionSpacing: 2
    implicitHeight: hasActions ? baseHeight + actionButtonHeight + actionSpacing : baseHeight

    Binding {
        target: notificationPopupWindow
        property: "anchor.rect.y"
        value: popupY
    }

    RectangularShadow {
        anchors.centerIn: parent
        width: parent.width - 6
        height: parent.height - 6
        blur: 8
        spread: 0.4
        opacity: 0.3
        radius: 12
        color: "#000000"
    }

    Timer {
        id: dismissTimer
        interval: timeout
        running: true
        repeat: false
        onTriggered: closePopup()
    }

    function closePopup() {
        exitAnimation.start();
    }

    ClippingRectangle {
        id: notificationContainer
        anchors.fill: parent
        radius: 14
        color: "#77" + Globals.colors.colors.color0
        opacity: 0
        anchors.margins: 4
        contentInsideBorder: true
        border {
            width: 2
            color: "#55" + Globals.colors.colors.color2
        }

        property real slideOffset: 0
        property real entranceOffset: 0
        property real entranceScale: 1.0

        x: slideOffset + entranceOffset
        scale: entranceScale

        layer.enabled: true

        ParallelAnimation {
            id: entranceAnimation
            running: true

            NumberAnimation {
                target: notificationContainer
                property: "opacity"
                from: 0
                to: 1
                duration: 300
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: notificationContainer
                property: "entranceOffset"
                from: 80
                to: 0
                duration: 400
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }

            NumberAnimation {
                target: notificationContainer
                property: "entranceScale"
                from: 0.85
                to: 1.0
                duration: 350
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }

        ParallelAnimation {
            id: exitAnimation

            NumberAnimation {
                target: notificationContainer
                property: "opacity"
                to: 0
                duration: 300
                easing.type: Easing.InCubic
            }

            NumberAnimation {
                target: notificationContainer
                property: "entranceOffset"
                to: 40
                duration: 300
                easing.type: Easing.InBack
                easing.overshoot: 1.5
            }

            NumberAnimation {
                target: notificationContainer
                property: "entranceScale"
                to: 0.7
                duration: 300
                easing.type: Easing.InBack
                easing.overshoot: 1.3
            }

            onFinished: {
                notificationPopupWindow.visible = false;
                closed();
            }
        }

        SequentialAnimation {
            id: slideRightAnimation

            NumberAnimation {
                target: notificationContainer
                property: "slideOffset"
                to: notificationPopupWindow.width
                duration: 300
                easing.type: Easing.OutCubic
            }

            ScriptAction {
                script: {
                    activated();
                    closePopup();
                }
            }
        }

        SequentialAnimation {
            id: slideLeftAnimation

            NumberAnimation {
                target: notificationContainer
                property: "slideOffset"
                to: -notificationPopupWindow.width
                duration: 300
                easing.type: Easing.OutCubic
            }

            ScriptAction {
                script: closePopup()
            }
        }

        NumberAnimation {
            id: restorePositionAnimation
            target: notificationContainer
            property: "slideOffset"
            to: 0
            duration: 200
            easing.type: Easing.OutCubic
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: hasActions ? baseHeight - 30 : -1
                Layout.fillHeight: !hasActions
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignVCenter
                    radius: 20
                    color: "#Aa303030"

                    Item {
                        anchors.fill: parent

                        Image {
                            id: appIconImage
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: {
                                if (notification && notification.image) {
                                    return notification.image;
                                } else if (notification && notification.appIcon) {
                                    return Quickshell.iconPath(notification.appIcon);
                                } else {
                                    return "";
                                }
                            }
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            cache: false

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.log("Failed to load icon: " + source);
                                } else if (status === Image.Ready) {
                                    console.log("Icon loaded successfully: " + source);
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: appIconImage.status !== Image.Ready
                            text: notificationAppName ? notificationAppName.charAt(0).toUpperCase() : "󰵙"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: 10
                    Layout.topMargin: 6
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: notificationSummary
                        color: "#A67676"
                        font.family: Globals.font
                        font.pixelSize: 14
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: notificationBody
                        color: "#B0B0B0"
                        font.family: Globals.font
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        wrapMode: Text.WordWrap
                        maximumLineCount: hasActions ? 1 : 2
                        textFormat: Text.PlainText
                    }
                }

                Item {
                    id: closeButton
                    z: 2
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignTop

                    Canvas {
                        id: countdownCanvas
                        anchors.fill: parent
                        antialiasing: true
                        property real progress: 0
                        onPaint: {
                            const ctx = getContext("2d");
                            const w = width;
                            const h = height;
                            const radius = w / 2 - 1.5;
                            const centerX = w / 2;
                            const centerY = h / 2;

                            ctx.clearRect(0, 0, w, h);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * progress, false);
                            ctx.strokeStyle = "#" + Globals.colors.colors.color6;
                            ctx.lineWidth = 2;
                            ctx.stroke();
                        }
                        onProgressChanged: requestPaint()
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        anchors.centerIn: parent
                        radius: 12
                        color: closeMouseArea.containsMouse ? "red" : "#404040"
                        z: 1

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                        }
                    }
                    MouseArea {
                        id: closeMouseArea

                        cursorShape: Qt.PointingHandCursor
                        z: 2
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: notificationPopupWindow.closePopup()
                    }

                    NumberAnimation {
                        id: countdownAnimation
                        target: countdownCanvas
                        property: "progress"
                        from: 0
                        to: 1
                        duration: timeout
                        running: true
                    }

                    Component.onCompleted: countdownAnimation.start()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: actionButtonHeight
                Layout.topMargin: hasActions ? actionSpacing : 0
                spacing: 8
                visible: hasActions

                Item {
                    Layout.fillWidth: true
                }

                Repeater {
                    model: notification ? notification.actions : []
                    delegate: ClippingRectangle {
                        Layout.preferredHeight: actionButtonHeight - 4
                        Layout.preferredWidth: Math.max(buttonText.implicitWidth + 16, 60)
                        radius: 6
                        color: actionMouseArea.containsMouse ? "#55" + Globals.colors.colors.color2 : "#44" + Globals.colors.colors.color1
                        border.width: 1
                        contentInsideBorder: true
                        border.color: "#66" + Globals.colors.colors.color2

                        Text {
                            id: buttonText
                            anchors.centerIn: parent
                            text: modelData.text
                            color: "#B0B0B0"
                            font.family: Globals.font
                            font.pixelSize: 11
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: actionMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.invoke();

                                if (notification && !notification.resident) {
                                    closePopup();
                                }
                            }
                        }

                        scale: actionMouseArea.pressed ? 0.95 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }
            }
        }

        Rectangle {
            id: activateIndicator
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: 8
            radius: 4
            color: "#4CAF50"
            opacity: notificationContainer.slideOffset > 0 ? Math.min(0.8, Math.abs(notificationContainer.slideOffset) / swipeArea.dismissThreshold) : 0
        }

        Rectangle {
            id: dismissIndicator
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 40
            width: 8
            radius: 4
            color: "#F44336"
            opacity: notificationContainer.slideOffset < 0 ? Math.min(0.8, Math.abs(notificationContainer.slideOffset) / swipeArea.dismissThreshold) : 0
        }
    }
}
