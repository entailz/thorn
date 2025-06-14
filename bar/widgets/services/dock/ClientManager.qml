pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: clientManager
    property var clients: []
    property string buffer: ""
    property bool updating: false

    signal clientsUpdated

    Process {
        id: fetchClients
        command: ["hyprctl", "-j", "clients"]
        stdout: SplitParser {
            onRead: line => {
                clientManager.buffer += line;
            }
        }
        onExited: (code, status) => {
            clientManager.updating = false;
            if (code !== 0) {
                return;
            }
            clients = JSON.parse(clientManager.buffer);
            clientManager.clientsUpdated();
            clientManager.buffer = "";
        }
    }

    function updateClients() {
        if (!updating) {
            updating = true;
            fetchClients.running = true;
        }
    }

    function findClientByAddress(address) {
        for (let i = 0; i < clients.length; i++) {
            if (clients[i].address === address) {
                return clients[i];
            }
        }
        return null;
    }

    function findClientForToplevel(toplevel) {
        if (!toplevel)
            return null;

        for (let i = 0; i < clients.length; i++) {
            const client = clients[i];
            if ((toplevel.appId && client.class && toplevel.appId === client.class) || (toplevel.title && client.title && toplevel.title === client.title)) {
                return client;
            }
        }
        return null;
    }

    function findToplevelForClient(client) {
        if (!client || !ToplevelManager || !ToplevelManager.toplevels)
            return null;

        const toplevels = [...ToplevelManager.toplevels.values];
        for (let i = 0; i < toplevels.length; i++) {
            const toplevel = toplevels[i];
            if ((toplevel.appId && client.class && toplevel.appId === client.class) || (toplevel.title && client.title && toplevel.title === client.title)) {
                return toplevel;
            }
        }
        return null;
    }

    function getClientsForWorkspace(workspaceId) {
        return clients.filter(client => client.workspace.id === workspaceId);
    }

    Component.onCompleted: {
        updateClients();

        if (Hyprland) {
            Hyprland.rawEvent.connect(event => {
                const eventName = event.name;
                if (eventName === "changefloatingmode" || event.event === "activewindow" || event.event === "activewindowv2" || event.event === "closewindow" || event.event === "openlayer") {
                    updateClients();
                }
            });
        }
    }
}
