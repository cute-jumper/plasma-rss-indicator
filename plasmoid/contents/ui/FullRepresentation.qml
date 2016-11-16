import QtQuick 2.0
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
                    console.log("[ListView onCompleted] " + getFaviconUrl(urls[i]));
                    console.log("[ListView onCompleted]: " + urls[i]);
                    var feed = new XMLHttpRequest();
                    feed.onreadystatechange = function () {
                        if (feed.readyState == XMLHttpRequest.DONE) {
                            getFeedTitle(feed.responseXML.documentElement);
                            var a = feed.responseXML.documentElement;
                            for (var ii = 0; ii < a.childNodes.length; ++ii) {
                                /* console.log(a.childNodes[ii].nodeName); */
                            }
                        }
                    }
                    feed.open("GET", urls[i]);
                    feed.send();
                    rssSourceModel.append({imageSource: getFaviconUrl(urls[i]),
                                           rssUrl: urls[i]
                                          });
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

    function getFeedTitle(xml) {
        var node = xml;
        var stop = false;
        for (var i = 0; i < node.childNodes.length; i++) {
            if (node.childNodes[i].tagName == "channel") {
                node = xml.childNodes[i];
                break;
            }
        }
        console.log(node.childNodes.length);
        for (var i = 0; i < node.childNodes.length; i++) {
            /* console.log(node.childNodes[i].tagName); */
            if (node.childNodes[i].tagName == "title") {
                console.log("yes!" + node.childNodes[i].firstChild.nodeValue);
                return node.childNodes[i].firstChild.nodeValue;
            }
        }
    }

    property variant urls

    Component.onCompleted: {
        urls = plasmoid.configuration.urls.split('\n');
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

        property Component currentComponent

        Item {
            id: emptyPage
        }

        onActiveRssChanged: {
            if (activeRss != null) {
                console.log("" + activeRss.currentIndex);
                currentComponent = Qt.createComponent("RssList.qml");
                rssListPanel.replace({item: currentComponent});
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
    Component {
        id: rssSourceDelegate
        PlasmaComponents.ListItem {
            id: listItem

            enabled: true
            checked: listItem.containsMouse && !fullRep.sourceClick

            property int currentIndex: index

            height: root.iconSize + Math.round(units.gridUnit / 2)

            XmlListModel {
                id: rssDetailsModel
                query: "/rss/channel/item"
                source: "https://dot.kde.org/rss.xml"

                XmlRole { name: "title"; query: "title/string()" }
                XmlRole { name: "pubDate"; query: "pubDate/string()" }
                XmlRole { name: "description"; query: "description/string()" }
                XmlRole { name: "link"; query: "link/string()" }

                onStatusChanged: {
                    if (status == XmlListModel.Ready) {
                        console.log("title: " + rssDetailsModel.get(0).title);
                    }
                }
            }

            Image {
                id: rssSourceIcon
                width: root.iconSize
                height: width
                anchors.left: parent.left
                fillMode: Image.PreserveAspectCrop
                source: imageSource

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
                text: "TODO"
            }

            onClicked: {
                if (fullRep.sourceClick) {
                    rssListPanel.activeRss = null;
                    rssSourceScroll.anchors.rightMargin = 0;
                    separator.visible = false;
                    heading.text = "RSS Indicator"
                } else {
                    rssListPanel.activeRss = listItem;
                    rssSourceScroll.anchors.rightMargin = rssListPanel.width;
                    separator.visible = true;
                    heading.text = "Details"
                }
                fullRep.sourceClick = !fullRep.sourceClick;
            }
        }
    }
}
