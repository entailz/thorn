pragma Singleton
import QtQuick
import Quickshell
import Qt.labs.folderlistmodel
import qs

Singleton {
    id: root

    readonly property string imageFolderPath: Globals.imageFolder

    property var imagePaths: []
    property var imageData: ({})
    property bool preventWallpaperChange: false
    property bool isInitialLoad: true
    property string currentPalette: "all"
    property var origin: "0.5, 0.5"

    signal randomImageSelected(string imagePath)
    signal imagesChanged
    signal reloadTriggered

    readonly property var getRandomImage: function () {
        const filteredPaths = getFilteredPaths();
        if (filteredPaths.length === 0) {
            return "";
        }
        const randomImage = filteredPaths[Math.floor(Math.random() * filteredPaths.length)];
        return randomImage;
    }

    function getFilteredPaths() {
        if (currentPalette === "all") {
            return imagePaths;
        }

        const filtered = [];
        for (let key in imageData) {
            if (imageData[key].palette === currentPalette) {
                filtered.push(imageData[key].path);
            }
        }
        return filtered;
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
        let imageName = imagePath.split('/').pop().split('.')[0];
        imageData[imageName] = {
            "path": imagePath,
            "palette": palette || "default"
        };

        if (!imagePaths.includes(imagePath)) {
            imagePaths.push(imagePath);
            imagesChanged();
        }
    }

    FolderListModel {
        id: folderModel
        folder: Qt.resolvedUrl(root.imageFolderPath)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.bmp", "*.gif"]
        sortField: FolderListModel.Name

        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                loadImagesFromFolder();
            }
        }
    }

    function loadImagesFromFolder() {
        imagePaths = [];
        imageData = {};

        for (let i = 0; i < folderModel.count; i++) {
            const fileUrl = folderModel.get(i, "fileUrl").toString();
            const fileName = folderModel.get(i, "fileName");
            const filePath = fileUrl.replace("file://", "");
            const isDir = folderModel.get(i, "fileIsDir");

            if (isDir) {
                continue;
            }

            imagePaths.push(filePath);

            const imageName = fileName.split('.')[0];
            imageData[imageName] = {
                "path": filePath
                // add palettes back at some point when i add lutgen generator
                // "palette": "default"
            };
        }

        imagesChanged();

        if (isInitialLoad) {
            isInitialLoad = false;
        }
    }

    function reloadImages() {
        folderModel.folder = "";
        folderModel.folder = Qt.resolvedUrl(root.imageFolderPath);
        reloadTriggered();
    }
}
