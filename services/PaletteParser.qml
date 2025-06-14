pragma Singleton
import Quickshell
import QtQuick

Singleton {
    signal newPaletteAdded(var palette)

    property string buffer: ""
    property string currentName: ""
    property var currentColors: []

    function addCurrentPalette() {
        if (currentName && currentColors.length > 0) {
            let newPalette = {
                "name": currentName,
                "colors": {
                    "pc": currentColors.slice()
                }
            };
            newPaletteAdded(newPalette);
            currentColors = [];
            currentName = "";
        }
    }

    function parseChunk(data) {
        buffer += data;
        let lines = buffer.split('\n');
        if (!buffer.endsWith('\n'))
            buffer = lines.pop();
        else
            buffer = "";
        for (let line of lines) {
            line = line.trim();
            if (!line)
                continue;

            if (line.startsWith("Name: ")) {
                addCurrentPalette();
                let parts = line.substring(6).split("#");
                currentName = parts[0].trim();
                currentColors = parts.slice(1).map(color => {
                    return "#" + color.trim();
                });
            } else if (line.match(/^#[0-9a-fA-F]{6}$/)) {
                currentColors.push(line);
            }
        }
        if (buffer === "")
            addCurrentPalette();
    }
}
