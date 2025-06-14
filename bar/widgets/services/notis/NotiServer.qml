pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Services.Notifications

Singleton {
    id: root
    property alias notificationServer: notiServer

    Scope {

        NotificationServer {
            id: notiServer
            keepOnReload: true
            bodySupported: true
            imageSupported: true
            actionIconsSupported: true
            actionsSupported: true
            bodyImagesSupported: true

            onNotification: function (notification) {
                notification.tracked = true;
            }
        }
    }
}
