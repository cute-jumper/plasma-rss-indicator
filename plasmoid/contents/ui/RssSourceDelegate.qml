import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

PlasmaComponents.ListItem {
    id: listItem

    enabled: true
    checked: listItem.containsMouse && !fullRep.sourceClick

    separatorVisible: false

    property int currentIndex: index
    property string table: "[" + rssUrl + "]"
    property bool timerStart: false
    property alias sourceName: rssSourceName.text

    height: root.iconSize + Math.round(units.gridUnit / 2)

    PlasmaCore.ToolTipArea {
        id: tooltip

        active: plasmoid.configuration.sourceTooltip

        anchors.fill: parent
        Image {
            id: rssSourceIcon
            width: root.iconSize
            height: width
            anchors.left: parent.left
            fillMode: Image.PreserveAspectCrop
            source: getFaviconUrl(rssUrl)

            onStatusChanged: {
                if (status == Image.Error) {
                    source = root.appletIcon;
                }
            }
        }

        PlasmaComponents.Label {
            id: rssSourceName

            anchors {
                left: rssSourceIcon.right
                leftMargin: Math.round(units.gridUnit / 2)
                right: parent.right
            }

            text: {
                if (info && info.title) {
                    return (info.title) + " (" + unread + "/" + allEntries.length + ")";
                } else {
                    return "";
                }
            }
            height: root.iconSize
            elide: Text.ElideRight
            font {
                weight: unread > 0 ? Font.Bold : Font.Normal
            }
        }
    }

    PlasmaComponents.ToolButton {
        id: updateFeedButton

        anchors {
            right: parent.right
            rightMargin: Math.round(units.gridUnit / 3)
            verticalCenter: parent.verticalCenter
        }

        iconSource: "view-refresh"
        tooltip: i18n("Update feeds")

        opacity: listItem.containsMouse ? 1 : 0
        visible: opacity != 0 && !rssListPanel.activeRss

        onClicked: {
            refreshFeeds(true);
        }
    }

    Timer {
        id: refreshTimer
        interval: fullRep.refresh
        running: timerStart && !plasmoid.userConfiguring
        repeat: true
        onTriggered: { refreshFeeds(false); }
    }

    function refreshFeeds(force) {
        requestFeedsUpdate(function (xml) {
            var channel = getFeedChannel(xml);
            var items = getFeedItemsFromChannel(channel);
            var added = updateUIByItems(items);
            if (added.length > 0) {
                var text = "";
                for (var i = 0; i < added.length; i++) {
                    text += added[i].title + "\n";
                }
                root.createNotification(info.title, text, rssSourceIcon.source);
            } else if (force) {
                root.createNotification(info.title, "No new items", rssSourceIcon.source);
            }
        });
    }

    PlasmaComponents.ToolButton {
        id: markReadButton

        anchors {
            right: updateFeedButton.left
            verticalCenter: parent.verticalCenter
        }

        iconSource: "mail-mark-read"
        tooltip: i18n("Mark as read")

        opacity: listItem.containsMouse ? 1 : 0
        visible: opacity != 0 && !rssListPanel.activeRss

        onClicked: {
            if (feedList.model) {
                feedList.bulkChangeRead = true;
                for (var i = 0; i < feedList.model.count; i++) {
                    feedList.model.get(i).read = true;
                }
                feedList.bulkChangeRead = false;
                changeUnread(function (_) {return 0;});
                // update cache and db
                readEntries = allEntries;
                updateAllEntries(allEntries);
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {
            if (mouse.button == Qt.LeftButton){
                if (rssListPanel.activeRss != null &&
                    currentIndex == rssListPanel.activeRss.currentIndex) {
                    rssListPanel.activeRss = null;
                } else {
                    rssListPanel.activeRss = listItem;
                }
            } else if (mouse.button == Qt.RightButton) {
                if (info.link) {
                    Qt.openUrlExternally(info.link);
                }
            }
        }
    }

    property alias feedList: feedList
    RssList {
        id: feedList
    }

    ListModel {
        id: feedListModel
    }

    property variant readEntries
    property variant allEntries: []
    // -1 is to make sure the rssSourceName.text can be updated when unread -> 0
    property int unread: -1

    Timer {
        id: timerStarter
        running: false
        repeat: false
        interval: currentIndex * (root.notificationTimeout + root.notificationGap)
        onTriggered: {
            timerStart = true;
        }
    }

    property variant info
    Component.onCompleted: {
        requestFeedsUpdate(function (xml) {
            // init readEntries
            readEntries = getReadEntriesFromDB();
            var channel = getFeedChannel(xml);
            // init info, tooltip
            info = getFeedInfoFromChannel(channel);
            tooltip.mainText = info.title;
            tooltip.subText = info.description ? info.description : "";
            // update UI
            var items = getFeedItemsFromChannel(channel);
            updateUIByItems(items);
            // feedListModel is complete now
            feedList.model = feedListModel;
            // start Timer
            timerStarter.running = true;
        });
    }

    function changeUnread(f) {
        var oldUnread = unread;
        unread = f(unread);
        if (oldUnread != unread) {
            var newTotalUnread = root.totalUnread;
            newTotalUnread += unread;
            if (oldUnread != -1) {
                newTotalUnread -= oldUnread;
            }
            root.totalUnread = newTotalUnread;
        }
    }

    function requestFeedsUpdate (callback) {
        var req = new XMLHttpRequest();
        req.onreadystatechange = function () {
            if (req.readyState == XMLHttpRequest.DONE) {
                callback(req.responseXML.documentElement);
            }
        }
        req.open("GET", rssUrl);
        req.send();
    }

    function updateUIByItems(items) {
        var added = [];
        for (var i = 0; i < items.length; i++) {
            var sig = Qt.md5(items[i].title);
            if (allEntries.indexOf(sig) == -1) {
                allEntries.push(sig);
                feedListModel.append({title: items[i].title,
                                      pubDate: items[i].pubDate,
                                      description: items[i].description,
                                      link: items[i].link,
                                      read: readEntries.indexOf(sig) != -1,
                                      sig: sig});
                added.push(items[i]);
            }
        }
        if (allEntries.length > fullRep.maxItems) {
            //Remove old entries
            var removeCount = allEntries.length - fullRep.maxItems;
            allEntries.splice(0, removeCount);
            feedListModel.remove(0, removeCount);
        }
        var newReadEntries = [];
        for (var i = 0; i < allEntries.length; i++) {
            if (readEntries.indexOf(allEntries[i]) != -1) {
                newReadEntries.push(allEntries[i]);
            }
        }
        readEntries = newReadEntries;
        updateAllEntries(readEntries);
        changeUnread(function (_) { return allEntries.length - readEntries.length; });
        return added;
    }

    function markEntryAsRead(sig) {
        changeUnread(function (x) {return x - 1;});
        // FIXME update cache and db
        readEntries.push(sig);
        insertReadEntryIntoDB(sig);
    }

    function insertReadEntryIntoDB(sig) {
        db.transaction(
            function (tx) {
                tx.executeSql("INSERT INTO " + table + " VALUES(?)", [sig]);
            }
        );
    }

    function getReadEntriesFromDB() {
        var entries = []
        db.transaction(
            function (tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS " + table + " (sig TEXT)");
                var rs = tx.executeSql("SELECT * FROM " + table);
                for(var i = 0; i < rs.rows.length; i++) {
                    entries.push(rs.rows.item(i).sig);
                }
            }
        )
        return entries;
    }

    function updateAllEntries(entries) {
        db.transaction(
            function (tx) {
                tx.executeSql("DELETE FROM " + table);
                for (var i = 0; i < entries.length; i++) {
                    tx.executeSql("INSERT INTO " + table + " VALUES(?)", [entries[i]]);
                }
            }
        );
    }

    function getBaseUrl(url) {
        if (!url.match("^http")) {
            url = "http://" + url;
        }
        var regex = new RegExp('^(https?://[^/?#]*).*');
        var m = url.match(regex);
        if (typeof m[1])
            return m[1];
        return null;
    }

    function getFaviconUrl(url) {
        return getBaseUrl(url) + "/favicon.ico";
    }

    function getFeedChannel(xml) {
        for (var i = 0; i < xml.childNodes.length; i++) {
            if (xml.childNodes[i].tagName == "channel") {
                return xml.childNodes[i];
            }
        }
    }

    function getEntry(root, tagNameList) {
        var entry = {};
        for (var i = 0; i < root.childNodes.length; i++) {
            var tagName = root.childNodes[i].tagName;
            if (tagNameList.indexOf(tagName) != -1) {
                var text = "";
                var nodes = root.childNodes[i].childNodes;
                for (var j = 0; j < nodes.length; j++) {
                    text += nodes[j].nodeValue;
                }
                entry[tagName] = text;
            }
        }
        return entry;
    }


    property variant feedTagNameList: ["title", "link", "description", "language", "pubDate"]
    function getFeedInfoFromChannel(channel) {
        var stop = false;
        if (channel != null) {
            return getEntry(channel, feedTagNameList);
        }
        return {};
    }

    property variant itemTagNameList: ["title", "link", "description", "pubDate"]
    function getFeedItemsFromChannel(channel) {
        var items = [];
        for (var i = 0; i < channel.childNodes.length; i++) {
            var tagName = channel.childNodes[i].tagName;
            if (tagName == "item") {
                items.push(getEntry(channel.childNodes[i], itemTagNameList));
            }
        }
        return items;
    }

}
