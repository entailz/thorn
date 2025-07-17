pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs

Singleton {
    id: appModelSingleton

    property string filterText: ""
    property string sortMode: "frequency" // default sort mode
    property bool showCategories: true

    function getFilteredAndSortedApps() {
        var apps = DesktopEntries.applications.values.filter(entry => {
            if (entry.noDisplay)
                return false;

            var searchText = filterText.toLowerCase();
            if (searchText === "")
                return true;

            return entry.name.toLowerCase().indexOf(searchText) !== -1 || (entry.genericName && entry.genericName.toLowerCase().indexOf(searchText) !== -1) || (entry.comment && entry.comment.toLowerCase().indexOf(searchText) !== -1) || (entry.keywords && entry.keywords.some(keyword => keyword.toLowerCase().indexOf(searchText) !== -1));
        });

        if (sortMode === "name") {
            apps.sort((a, b) => a.name.localeCompare(b.name));
        } else if (sortMode === "category") {
            apps.sort((a, b) => {
                var aCat = a.categories.length > 0 ? a.categories[0] : "Other";
                var bCat = b.categories.length > 0 ? b.categories[0] : "Other";
                var catCompare = aCat.localeCompare(bCat);
                return catCompare !== 0 ? catCompare : a.name.localeCompare(b.name);
            });
        } else if (sortMode === "frequency") {
            apps = Frequency.sortByFrequency(apps);
        }

        if (sortMode === "category" && showCategories) {
            var result = [];
            var currentCategory = "";

            apps.forEach(entry => {
                var category = entry.categories.length > 0 ? entry.categories[0] : "Other";

                if (category !== currentCategory) {
                    result.push({
                        "id": "header_" + category,
                        "isHeader": true,
                        "category": category,
                        "name": category
                    });
                    currentCategory = category;
                }

                var searchText = filterText.toLowerCase();
                var highlightedName = entry.name;
                if (searchText !== "") {
                    highlightedName = entry.name.replace(new RegExp(searchText, "ig"), `<span style="color: #${Globals.colors.colors.color5};">$&</span>`);
                }

                result.push({
                    "id": entry.id,
                    "isHeader": false,
                    "name": entry.name,
                    "genericName": entry.genericName,
                    "comment": entry.comment,
                    "icon": entry.icon,
                    "categories": entry.categories,
                    "category": category,
                    "actions": entry.actions,
                    "highlightedName": highlightedName,
                    "entry": entry,
                    "usageCount": Frequency.getCount(entry.name || entry.id)
                });
            });

            return result;
        } else {
            return apps.map(entry => {
                var searchText = filterText.toLowerCase();
                var highlightedName = entry.name;
                if (searchText !== "") {
                    highlightedName = entry.name.replace(new RegExp(searchText, "ig"), `<span style="color: #${Globals.colors.colors.color5};">$&</span>`);
                }

                var primaryCategory = entry.categories.length > 0 ? entry.categories[0] : "Other";

                return {
                    "id": entry.id,
                    "isHeader": false,
                    "name": entry.name,
                    "genericName": entry.genericName,
                    "comment": entry.comment,
                    "icon": entry.icon,
                    "categories": entry.categories,
                    "category": primaryCategory,
                    "actions": entry.actions,
                    "highlightedName": highlightedName,
                    "entry": entry,
                    "usageCount": Frequency.getCount(entry.name || entry.id)
                };
            });
        }
    }

    ScriptModel {
        id: model
        objectProp: "id"
        property int count: values ? values.length : 0
        values: appModelSingleton.getFilteredAndSortedApps()
    }

    readonly property alias appModel: model
}
