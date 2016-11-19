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
        level: 2

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            leftMargin: units.smallSpacing
        }

        height: paintedHeight

        horizontalAlignment: Text.AlignLeft
        text: "RSS Indicator"
    }

    PlasmaCore.SvgItem {
        id: separator
        anchors {
            left: parent.left
            leftMargin: root.leftColumnWidth
            top: parent.top
            bottom: parent.bottom
            margins: -units.gridUnit
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
            delegate: RssSourceDelegate {}
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
                var child = root.childNodes[i].firstChild
                if (child) {
                    entry[tagName] = child.nodeValue;
                }
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
}
