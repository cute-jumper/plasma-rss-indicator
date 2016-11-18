import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.XmlListModel 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

Item {
    id: fullRep

    property bool sourceClick: false
    property alias heading: heading

    Layout.minimumWidth: units.gridUnit * 12
    Layout.minimumHeight: units.gridUnit * 12

    PlasmaExtras.Heading {
        id: heading
        level: 1

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        height: paintedHeight

        horizontalAlignment: Text.AlignHCenter
        text: "RSS Indicator"
    }

    PlasmaCore.SvgItem {
        id: separator
        anchors {
            left: parent.left
            leftMargin: root.leftColumnWidth
            top: parent.top
            bottom: parent.bottom
        }

        visible: false
        width: lineSvg.elementSize("vertical-line").width

        elementId: "vertical-line"

        svg: PlasmaCore.Svg {
            id: lineSvg;
            imagePath: "widgets/line"
        }
    }

    PlasmaExtras.ScrollArea {
        id: rssSourceScroll

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        CurrentItemHighLight {
            target: rssListPanel.activeRss
            location: PlasmaCore.Types.LeftEdge
        }
        ListView {
            id: rssSourceList
            anchors.fill: parent
            clip: true
            model: ListModel {
                id: rssSourceModel
            }
            delegate: rssSourceDelegate
            snapMode: ListView.SnapToItem
            Component.onCompleted: {
                for (var i = 0; i < urls.length; i++) {
                    rssSourceModel.append({rssUrl: urls[i]});
                }
            }
        }
    }
    function getBaseUrl(url) {
        console.log("[getBaseUrl] " + url);
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

    function getFeedInfo(xml) {
        var node = null;
        var stop = false;
        for (var i = 0; i < xml.childNodes.length; i++) {
            if (xml.childNodes[i].tagName == "channel") {
                node = xml.childNodes[i];
                break;
            }
        }
        var info = {}
        if (node != null) {
            for (var i = 0; i < node.childNodes.length; i++) {
                var tagName = node.childNodes[i].tagName;
                if (tagName == "title" || tagName == "link"
                    || tagName == "description"
                    || tagName == "language"
                    || tagName == "pubDate") {
                    var child = node.childNodes[i].firstChild;
                    if (child) {
                        info[tagName] = child.nodeValue;
                    }
                }
            }
        }
        return info;
    }

    property variant urls
    property variant db
    Component.onCompleted: {
        urls = plasmoid.configuration.urls.split('\n');
        db = LocalStorage.openDatabaseSync("RssIndicatorDB", root.version, "SQLite for RssIndicator", 100);
        cleanUpTables();
    }

    function cleanUpTables() {
        //TODO
    }

    StackView {
        id: rssListPanel

        anchors {
            left: parent.left
            top: heading.bottom
            right: parent.right
            bottom: parent.bottom
            leftMargin: root.leftColumnWidth
        }

        property Item activeRss

        property Item currentItem

        Item {
            id: emptyPage
        }

        onActiveRssChanged: {
            if (activeRss != null) {
                currentItem = activeRss.feedList;
                rssListPanel.replace({item: currentItem});
            } else {
                rssListPanel.replace({item: emptyPage, immediate: true});
            }
        }
        delegate: StackViewDelegate {
            function transitionFinished(properties) {
                properties.exitItem.opacity = 1;
            }
            replaceTransition: StackViewTransition {
                ParallelAnimation {
                    PropertyAnimation {
                        target: enterItem
                        property: "x"
                        from: enterItem.width
                        to: 0
                        duration: units.longDuration
                    }
                    PropertyAnimation {
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: units.longDuration
                    }
                }
            }
        }
    }

    function getAllEntries(table) {
        var entries = []
        fullRep.db.transaction(
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
    function markEntryAsRead(table, sig) {
        db.transaction(
            function (tx) {
                console.log("table: " + table);
                console.log("sig: " + sig);
                tx.executeSql("INSERT INTO " + table + " VALUES(?)", [sig]);
            }
        );
    }
    function updateAllEntries(table, newEntries) {
        db.transaction(
            function (tx) {
                tx.executeSql("DELETE FROM " + table);
                for (var i = 0; i < newEntries.length; i++) {
                    tx.executeSql("INSERT INTO " + table + " VALUES(?)", [newEntries[i]]);
                }
            }
        );
    }
    function makeSourceName(title, unread, total) {
        return title + " (" + unread + "/" + total + ")";
    }


    function setSourceNameText(title, unread, total) {
        var item = rssListPanel.activeRss;
        item.rssSourceNameText = heading.text = makeSourceName(title, unread, total);
        item.rssSourceNameTextWeight = unread > 0 ? Font.Bold : Font.Normal;
    }

    Component {
        id: rssSourceDelegate
        PlasmaComponents.ListItem {
            id: listItem

            enabled: true
            checked: listItem.containsMouse && !fullRep.sourceClick

            property int currentIndex: index
            property string table: "[" + rssUrl + "]"
            property alias rssSourceNameText: rssSourceName.text
            property alias rssSourceNameTextWeight: rssSourceName.font.weight

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
                    height: root.iconSize
                    elide: Text.ElideRight
                    font.weight: Font.Normal
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    console.log(mouse.button);
                    if (mouse.button == Qt.LeftButton){
                        if (fullRep.sourceClick &&
                            currentIndex == rssListPanel.activeRss.currentIndex
                           ) {
                            rssListPanel.activeRss = null;
                            rssSourceScroll.anchors.rightMargin = 0;
                            separator.visible = false;
                            heading.text = "RSS Indicator";
                            heading.level = 1;
                            fullRep.sourceClick = false;
                        } else {
                            rssListPanel.activeRss = listItem;
                            rssSourceScroll.anchors.rightMargin = rssListPanel.width;
                            separator.visible = true;
                            heading.text = rssSourceNameText;
                            heading.level = 2;
                            fullRep.sourceClick = true;
                        }
                    } else if (mouse.button == Qt.RightButton) {
                        console.log("right");
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

            XmlListModel {
                id: feedXmlListModel

                query: "/rss/channel/item"

                XmlRole { name: "title"; query: "title/string()" }
                XmlRole { name: "pubDate"; query: "pubDate/string()" }
                XmlRole { name: "description"; query: "description/string()" }
                XmlRole { name: "link"; query: "link/string()" }

                onStatusChanged: {
                    if (status === XmlListModel.Error) {
                    }
                    if (status === XmlListModel.Ready) {
                        var readEntries = getAllEntries(table);
                        var newEntries = [];
                        console.log(readEntries);
                        for (var i = 0; i < count; i++) {
                            var item = get(i);
                            var sig = Qt.md5(item.title);
                            var read = true;
                            if (readEntries.indexOf(sig) == -1) {
                                read = false;
                            } else {
                                newEntries.push(sig);
                            }
                            feedListModel.append({title: item.title,
                                                  pubDate: item.pubDate,
                                                  description: item.description,
                                                  link: item.link,
                                                  read: read,
                                                  sig: sig
                                                 });
                        }
                        feedList.model = feedListModel;
                        var unread = count - newEntries.length;
                        feedList.unread = unread;
                        rssSourceName.text = makeSourceName(info.title, unread, count);
                        rssSourceName.font.weight = unread > 0 ? Font.Bold : Font.Normal;
                        updateAllEntries(table, newEntries);
                    }
                }

            }

            property variant info
            Component.onCompleted: {
                var req = new XMLHttpRequest();
                req.onreadystatechange = function () {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        info = getFeedInfo(req.responseXML.documentElement);
                        rssSourceName.text = info.title;
                        feedXmlListModel.xml = req.responseText;
                        feedList.rssTitle = info.title
                        feedList.table = table;
                        tooltip.mainText = info.title;
                        tooltip.subText = info.description ? info.description : "";
                        console.log("info: " + JSON.stringify(info));
                    }
                }
                req.open("GET", rssUrl);
                req.send();
            }
        }
    }
}
