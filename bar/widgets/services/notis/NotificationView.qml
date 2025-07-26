import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../../components" as Components
import "root:/"

Rectangle {
    id: notificationRoot
    color: "transparent"
    radius: 8
    property var colors: ({})
    property var notificationServer: null

    property bool notificationsEnabled: Globals.notificationsEnabled
    property bool isVisible: false
    property bool animationsTriggered: false

    function toggleNotifications() {
        Globals.notificationsEnabled = !Globals.notificationsEnabled;
        if (Globals.notificationsEnabled && notificationRoot.isVisible) {
            animationsTriggered = false;
            resetAnimationTimer.start();
        }
    }

    onIsVisibleChanged: {
        if (isVisible && Globals.notificationsEnabled) {
            animationsTriggered = false;
            resetAnimationTimer.start();
        } else {
            animationsTriggered = false;
            for (let i = 0; i < notificationListView.count; i++) {
                let item = notificationListView.itemAtIndex(i);
                if (item) {
                    item.forceResetPosition();
                }
            }
        }
    }

    Timer {
        id: resetAnimationTimer
        interval: 50
        onTriggered: {
            if (notificationListView.count > 0) {
                for (let i = 0; i < notificationListView.count; i++) {
                    let item = notificationListView.itemAtIndex(i);
                    if (item) {
                        item.resetForAnimation();
                    }
                }
                startAnimationsTimer.start();
            }
        }
    }

    Timer {
        id: startAnimationsTimer
        interval: 100
        onTriggered: {
            for (let i = 0; i < notificationListView.count; i++) {
                let item = notificationListView.itemAtIndex(i);
                if (item) {
                    item.startSlideAnimation(i * 150);
                }
            }
            animationsTriggered = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            color: "#11" + Globals.colors.colors.color4
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12

                Text {
                    text: ""
                    color: "#" + Globals.colors.colors.color1
                    font.family: Globals.font
                    font.pixelSize: 20
                    Layout.preferredWidth: 20
                }
                Text {
                    text: "Notifications"
                    color: "#" + Globals.colors.colors.color6
                    font.family: Globals.font
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    Layout.fillWidth: true
                }

                Rectangle {
                    id: silenceToggle
                    width: 60
                    height: 24
                    radius: 14
                    color: Globals.notificationsEnabled ? "#40" + Globals.colors.colors.color2 : "#40404040"
                    border.color: Globals.notificationsEnabled ? "#" + Globals.colors.colors.color2 : "#606060"
                    border.width: 1

                    Rectangle {
                        id: toggleHandle
                        width: 20
                        height: 18
                        radius: 10
                        color: Globals.notificationsEnabled ? "#" + Globals.colors.colors.color2 : "#808080"
                        anchors.verticalCenter: parent.verticalCenter
                        x: Globals.notificationsEnabled ? parent.width - width - 3 : 3

                        Behavior on x {
                            SmoothedAnimation {
                                duration: 200
                                velocity: 200
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: Globals.notificationsEnabled ? "ON" : "OFF"
                        color: "#" + Globals.colors.colors.color2
                        font.pixelSize: 9
                        font.bold: true
                        font.family: Globals.font
                        opacity: 0.8
                    }

                    MouseArea {
                        cursorShape: Qt.PointingHandCursor
                        anchors.fill: parent
                        onClicked: toggleNotifications()
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !Globals.notificationsEnabled

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12

                Components.IconButton {
                    icon: "notifications_off"
                    useVariableFill: true
                    size: 64
                    // font.pixelSize: 48
                    iconColor: "#606060"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Notifications Silenced"
                    color: "#808080"
                    font.family: Globals.font
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Use the toggle above to enable notifications"
                    color: "#606060"
                    font.family: Globals.font
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    width: 200
                    wrapMode: Text.WordWrap
                }
            }
        }

        ListView {
            id: notificationListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            visible: Globals.notificationsEnabled

            Item {
                id: noNotificationsState
                anchors.fill: parent
                visible: notificationListView.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Components.IconButton {
                        icon: "notifications"
                        size: 64
                        iconColor: "#606060"
                        useVariableFill: true
                        clickable: false
                        // text: "󰂚"
                        // font.pixelSize: 48
                        // color: "#606060"
                        // horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "No Notifications"
                        color: "#808080"
                        font.family: Globals.font
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            model: notificationRoot.notificationServer ? notificationRoot.notificationServer.trackedNotifications : null
            delegate: Item {
                id: notificationWrapper
                width: notificationListView.width
                height: notificationItem.height
                property var notification: modelData
                property real swipeDistance: 0
                property bool isBeingDismissed: false

                property real animationX: notificationListView.width + 50
                property real animationOpacity: 0
                property bool animationInitialized: false

                function forceResetPosition() {
                    animationX = notificationListView.width + 50;
                    animationOpacity = 0;
                    animationInitialized = false;
                }

                function resetForAnimation() {
                    slideAnimation.stop();
                    slideAnimationTimer.stop();

                    animationX = notificationListView.width + 50;
                    animationOpacity = 0;
                    animationInitialized = true;
                }

                function startSlideAnimation(delay) {
                    if (notificationRoot.isVisible && animationInitialized) {
                        slideAnimationTimer.interval = delay;
                        slideAnimationTimer.start();
                    }
                }

                Timer {
                    id: slideAnimationTimer
                    onTriggered: {
                        if (notificationRoot.isVisible && animationInitialized) {
                            slideAnimation.start();
                        }
                    }
                }

                ParallelAnimation {
                    id: slideAnimation

                    NumberAnimation {
                        target: notificationWrapper
                        property: "animationX"
                        to: 0
                        duration: 750
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }

                    NumberAnimation {
                        target: notificationWrapper
                        property: "animationOpacity"
                        to: 1
                        duration: 600
                        easing.type: Easing.OutQuart
                    }
                }

                ClippingRectangle {
                    id: notificationItem
                    width: parent.width
                    height: contentLayout.implicitHeight + 16
                    color: "#99" + Globals.colors.colors.color0
                    contentInsideBorder: true
                    radius: 4
                    x: parent.swipeDistance + parent.animationX
                    opacity: Math.max(parent.animationOpacity * (1.0 - (Math.abs(parent.swipeDistance) / (parent.width * 0.8))), 0)

                    Behavior on x {
                        enabled: !notificationDragArea.drag.active && !slideAnimation.running
                        SpringAnimation {
                            spring: 2
                            damping: 0.2
                            duration: 300
                        }
                    }

                    Rectangle {
                        width: 4
                        height: parent.height
                        color: {
                            if (notification.urgency === NotificationUrgency.Critical) {
                                return "#FF5555";
                            } else if (notification.urgency === NotificationUrgency.Low) {
                                return "#" + Globals.colors.colors.color4;
                            } else {
                                return "#" + Globals.colors.colors.color6;
                            }
                        }
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        radius: 4
                    }

                    ColumnLayout {
                        id: contentLayout
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                Layout.alignment: Qt.AlignTop
                                radius: 10
                                color: "#303030"

                                Image {
                                    id: notificationIcon
                                    anchors.centerIn: parent
                                    width: 28
                                    height: 28
                                    source: {
                                        if (notification.image) {
                                            return notification.image;
                                        } else if (notification.appIcon) {
                                            return Quickshell.iconPath(notification.appIcon);
                                        } else {
                                            return ""; // glyph fallback
                                        }
                                    }
                                    fillMode: Image.PreserveAspectFit
                                    visible: source !== "" && status === Image.Ready
                                    cache: false
                                    asynchronous: true
                                    smooth: true
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰵙"
                                    font.pixelSize: 20
                                    color: "#A0A0A0"
                                    visible: !notificationIcon.visible
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    Layout.fillWidth: true
                                    text: notification.summary
                                    color: "#A67676"
                                    font.family: Globals.font
                                    font.pixelSize: 16
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notification.body
                                    color: "#A0A0A0"
                                    font.family: Globals.font
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                    wrapMode: Text.WordWrap
                                    visible: notification.body !== ""
                                }
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: actionsFlow.height
                            visible: notification.actions && notification.actions.length > 0

                            Flow {
                                id: actionsFlow
                                anchors.horizontalCenter: parent.horizontalCenter
                                Layout.fillWidth: true
                                spacing: 8
                                visible: notification.actions && notification.actions.length > 0

                                Repeater {
                                    model: notification.actions
                                    delegate: Button {
                                        text: modelData.text || "Action"
                                        background: Rectangle {
                                            id: actionButton
                                            implicitHeight: 26
                                            implicitWidth: 60
                                            radius: 6
                                            color: parent.hovered ? "#404040" : "#303030"
                                            border.color: "#404040"
                                            border.width: 1
                                        }
                                        contentItem: Text {
                                            text: parent.text
                                            font.family: Globals.font
                                            font.pixelSize: 12
                                            color: "#C0C0C0"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: {
                                            modelData.invoke();
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: notificationWrapper.swipeDistance > 0 ? "#" + Globals.colors.colors.color6 : "#663333"
                        opacity: Math.min(Math.abs(notificationWrapper.swipeDistance) / (width * 0.3), 1)
                        z: -1
                    }
                }

                MouseArea {
                    id: notificationDragArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    drag.target: notificationWrapper.isBeingDismissed ? null : notificationItem
                    drag.axis: Drag.XAxis
                    drag.minimumX: -parent.width
                    drag.maximumX: parent.width

                    property real startX: 0
                    property bool isDragging: false

                    onPressed: {
                        startX = mouseX;
                        isDragging = false;

                        if (actionsFlow.visible) {
                            const mappedPos = mapToItem(actionsFlow, mouseX, mouseY);
                            if (mappedPos.x >= 0 && mappedPos.x < actionsFlow.width && mappedPos.y >= 0 && mappedPos.y < actionsFlow.height) {
                                mouse.accepted = false;
                                return;
                            }
                        }
                    }

                    onPositionChanged: {
                        if (Math.abs(mouseX - startX) > 10) {
                            isDragging = true;
                        }
                        notificationWrapper.swipeDistance = notificationItem.x;
                    }

                    onReleased: {
                        if (Math.abs(notificationItem.x) > width * 0.4) {
                            notificationWrapper.isBeingDismissed = true;
                            var direction = notificationItem.x > 0 ? 1 : -1;
                            var animation = dismissAnimation;
                            animation.to = direction * width * 1.5;
                            animation.start();
                        } else {
                            notificationItem.x = 0;
                            notificationWrapper.swipeDistance = 0;
                        }
                    }

                    onClicked: {
                        if (!isDragging) {
                            if (notification.actions && notification.actions.length > 0) {
                                notification.actions[0].invoke();
                            } else {
                                notification.dismiss();
                            }
                        }
                    }
                }

                NumberAnimation {
                    id: dismissAnimation
                    target: notificationItem
                    property: "x"
                    duration: 300
                    easing.type: Easing.InQuad
                    onFinished: {
                        if (notificationItem.x > 0) {
                            if (notification.actions && notification.actions.length > 0) {
                                notification.actions[0].invoke();
                            } else {
                                notification.dismiss();
                            }
                        } else {
                            notification.dismiss();
                        }
                    }
                }
            }
        }
    }
}
