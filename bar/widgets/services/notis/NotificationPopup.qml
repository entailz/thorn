import QtQuick

Item {
    id: notificationPopupManager

    property int maxNotifications: 8
    property int notificationTimeout: 5000
    property int notificationSpacing: 0
    property int notificationWidth: 320
    property int baseNotificationHeight: 100
    property int actionButtonHeight: 12
    property int actionSpacing: 8
    property int offset: 20
    property bool silenced: false
    property var notificationServer: null
    property var parentQsWindow: null

    ListModel {
        id: notificationModel
    }

    function clearAllNotifications() {
        for (var i = 0; i < notificationModel.count; i++) {
            var item = notificationModel.get(i);
            if (item) {
                item.closing = true;
            }
        }

        clearTimer.start();
    }

    Timer {
        id: clearTimer
        interval: 50
        onTriggered: {
            notificationModel.clear();
        }
    }

    function getNotificationHeight(notification) {
        var hasActions = notification && notification.actions && notification.actions.length > 0;
        return hasActions ? baseNotificationHeight + actionButtonHeight + actionSpacing : baseNotificationHeight;
    }

    function showNotification(notification) {
        if (silenced) {
            return;
        }

        if (!parentQsWindow) {
            return;
        }

        while (notificationModel.count >= maxNotifications) {
            var oldItem = notificationModel.get(0);
            if (oldItem) {
                oldItem.closing = true;
            }
            notificationModel.remove(0);
        }

        notificationModel.append({
            "notification": notification,
            "notificationId": Date.now() + Math.random(),
            "appIcon": notification.appIcon || "",
            "summary": notification.summary || "Notification",
            "body": notification.body || "",
            "appName": notification.appName || "",
            "height": getNotificationHeight(notification),
            "closing": false
        });

        notification.closed.connect(function () {
            removeNotification(notification);
        });
    }

    function removeNotification(notification) {
        for (var i = 0; i < notificationModel.count; i++) {
            var item = notificationModel.get(i);
            if (item && item.notification === notification) {
                item.closing = true;
                removeTimer.targetIndex = i;
                removeTimer.start();
                break;
            }
        }
    }

    function removeNotificationById(id) {
        for (var i = 0; i < notificationModel.count; i++) {
            var item = notificationModel.get(i);
            if (item && item.notificationId === id) {
                item.closing = true;
                removeTimer.targetIndex = i;
                removeTimer.start();
                break;
            }
        }
    }

    Timer {
        id: removeTimer
        property int targetIndex: -1
        interval: 100
        onTriggered: {
            if (targetIndex >= 0 && targetIndex < notificationModel.count) {
                notificationModel.remove(targetIndex);
            }
            targetIndex = -1;
        }
    }

    Repeater {
        model: notificationModel

        delegate: Item {
            id: delegateItem

            property var notificationData: model
            property bool isClosing: model.closing || false

            Loader {
                id: popupLoader
                active: !delegateItem.isClosing && parentQsWindow !== null

                sourceComponent: Component {
                    NotificationPopupItem {
                        id: popupItem

                        notification: delegateItem.notificationData.notification
                        notificationAppIcon: delegateItem.notificationData.appIcon
                        notificationSummary: delegateItem.notificationData.summary
                        notificationBody: delegateItem.notificationData.body
                        notificationAppName: delegateItem.notificationData.appName
                        timeout: notificationTimeout

                        implicitWidth: notificationWidth
                        implicitHeight: delegateItem.notificationData.height

                        popupY: {
                            var y = offset;
                            for (var i = 0; i < index; i++) {
                                if (i < notificationModel.count) {
                                    var prevItem = notificationModel.get(i);
                                    if (prevItem && !prevItem.closing) {
                                        y += prevItem.height + notificationSpacing;
                                    }
                                }
                            }
                            return y;
                        }

                        Component.onCompleted: {
                            if (parentQsWindow) {
                                anchor.window = parentQsWindow;
                                anchor.rect.x = parentQsWindow.width - notificationWidth - 16;
                                visible = true;
                            }
                        }

                        onClosed: {
                            if (!delegateItem.isClosing) {
                                removeNotificationById(delegateItem.notificationData.notificationId);
                            }
                        }

                        onActivated: {
                            if (!delegateItem.isClosing && delegateItem.notificationData.notification && delegateItem.notificationData.notification.hasDefaultAction) {
                                delegateItem.notificationData.notification.invokeDefaultAction();
                            }
                        }

                        Behavior on popupY {
                            enabled: !delegateItem.isClosing
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }

                        Component.onDestruction: {
                            if (visible) {
                                visible = false;
                            }
                        }
                    }
                }

                onActiveChanged: {
                    if (!active && item) {
                        item.visible = false;
                    }
                }
            }

            onIsClosingChanged: {
                if (isClosing && popupLoader.item) {
                    popupLoader.item.closePopup();
                }
            }
        }
    }

    property var previousTrackedCount: 0

    Timer {
        interval: 500
        running: notificationServer !== null
        repeat: true
        onTriggered: {
            if (notificationServer) {
                var currentCount = notificationServer.trackedNotifications.count;
                if (previousTrackedCount > 0 && currentCount === 0) {
                    clearAllNotifications();
                }
                previousTrackedCount = currentCount;
            }
        }
    }

    Component.onCompleted: {
        if (notificationServer) {
            previousTrackedCount = notificationServer.trackedNotifications.count;

            notificationServer.notification.connect(function (notification) {
                notification.tracked = true;
                if (!silenced) {
                    showNotification(notification);
                }
            });
        }
    }

    onSilencedChanged: {
        if (silenced) {
            clearAllNotifications();
        }
    }

    Component.onDestruction: {
        clearAllNotifications();
    }
}
