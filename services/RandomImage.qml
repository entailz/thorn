pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "root:/"

Singleton {
    id: root
    readonly property string jsonPath: Globals.homeDir + "/paper/output.json"
    property var imagePaths: []
    property var jsonData: null
    property var imageData: ({})
    property bool preventWallpaperChange: false
    property bool isInitialLoad: true
    property var origin: ""

    signal randomImageSelected(string imagePath)
    readonly property var getRandomImage: function () {
        if (imagePaths.length === 0) {
            return "";
        }
        const randomImage = imagePaths[Math.floor(Math.random() * imagePaths.length)];
        return randomImage;
    }

    property FileView jsonFile
    signal reloadTriggered
    signal imagesChanged
    signal fileReload

    function parseJson() {
        if (!jsonFile.loaded) {
            return;
        }
        try {
            jsonData = JSON.parse(jsonFile.text());
            imagePaths = [];
            imageData = {};
            if (jsonData.images && Object.keys(jsonData.images).length > 0) {
                for (let key in jsonData.images) {
                    if (jsonData.images[key].path) {
                        imagePaths.push(jsonData.images[key].path);
                        imageData[key] = jsonData.images[key];
                    }
                }
            }

            imagesChanged();

            if (isInitialLoad) {
                isInitialLoad = false;
            }
        } catch (e) {
            console.error("Error parsing JSON:", e);
        }
    }

    function selectRandomImage() {
        var newPath = getRandomImage();
        if (newPath) {
            randomImageSelected(newPath);
            return newPath;
        } else {
            return "";
        }
    }
    function addImageToJson(imagePath, palette) {
        let currentContent = jsonFile.text().trim();
        if (!currentContent)
            currentContent = '{"images":{}}';
        try {
            let jsonData = JSON.parse(currentContent);
            let imageName = imagePath.split('/').pop().split('.')[0];
            if (!jsonData.images[imageName]) {
                jsonData.images[imageName] = {
                    "path": imagePath,
                    "palette": palette
                };
                let updatedContent = JSON.stringify(jsonData, null, 4);
                if (updatedContent !== currentContent) {
                    preventWallpaperChange = true;
                    jsonFile.setText(updatedContent);
                }
            }
        } catch (e) {
            console.error("Error parsing JSON:", e);
        }
    }

    Component.onCompleted: {
        parseJson();
    }

    jsonFile: FileView {
        id: files
        path: root.jsonPath
        blockLoading: false
        watchChanges: true
        atomicWrites: true
        printErrors: true
        preload: true
        onTextChanged: {
            if (loaded) {
                const shouldPrevent = root.preventWallpaperChange;
                root.parseJson();
                if (shouldPrevent) {
                    return;
                }

                if (!root.isInitialLoad) {
                    root.selectRandomImage();
                }
            }
        }
    }
}
