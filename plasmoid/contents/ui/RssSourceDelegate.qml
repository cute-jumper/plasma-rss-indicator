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

    height: root.iconSize + Math.round(units.gridUnit / 2)

    PlasmaCore.ToolTipArea {
        id: tooltip
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

        }
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
                unread = 0;
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
                if (fullRep.sourceClick &&
                    currentIndex == rssListPanel.activeRss.currentIndex) {
                    rssListPanel.activeRss = null;
                    rssSourceScroll.anchors.rightMargin = 0;
                    separator.visible = false;
                    heading.text = "RSS Indicator";
                    heading.anchors.leftMargin = units.smallSpacing;
                    fullRep.sourceClick = false;
                } else {
                    rssListPanel.activeRss = listItem;
                    rssSourceScroll.anchors.rightMargin = rssListPanel.width;
                    separator.visible = true;
                    heading.text = rssSourceName.text;
                    heading.anchors.leftMargin = root.leftColumnWidth + units.smallSpacing;
                    fullRep.sourceClick = true;
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
    property int unread: -1

    property variant info
    Component.onCompleted: {
        requestFeedsUpdate(function (xml) {
            // init readEntries
            readEntries = getReadEntriesFromDB();
            console.log(table + ": " + readEntries);
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
        });
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
            }
        }
        unread = allEntries.length - readEntries.length;
    }

    function markEntryAsRead(sig) {
        unread--;
        if (rssListPanel.activeRss) {
            heading.text = rssSourceName.text;
        }
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

}
