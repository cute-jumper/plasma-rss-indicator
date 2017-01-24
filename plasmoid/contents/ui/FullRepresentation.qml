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

    property alias heading: heading
    property int refresh: plasmoid.configuration.refresh * 1000
    property int maxItems: plasmoid.configuration.maxItems

    property alias activeRss: rssListPanel.activeRss

    Layout.minimumWidth: units.gridUnit * 12
    Layout.minimumHeight: units.gridUnit * 14
    width: 500
    height: 600

    PlasmaExtras.Heading {
        id: heading
        level: 2

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            leftMargin: activeRss ? root.leftColumnWidth : units.smallSpacing
        }

        height: paintedHeight

        horizontalAlignment: activeRss ? Text.AlignHCenter : Text.AlignLeft
        text: activeRss ? activeRss.sourceName : "RSS Indicator"
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

        visible: activeRss != null
        width: lineSvg.elementSize("vertical-line").width

        elementId: "vertical-line"

        svg: PlasmaCore.Svg {
            id: lineSvg;
            imagePath: "widgets/line"
        }
    }

    PlasmaExtras.ScrollArea {
        id: rssSourceScroll

        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            rightMargin: activeRss ? rssListPanel.width : 0
        }
        CurrentItemHighLight {
            target: activeRss
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
        }
    }

    property variant urls: plasmoid.configuration.urls.split('\n').filter(validUrl).map(urlFix)

    function validUrl(loc) {
        // FIXME
        return loc != "";
    }

    function urlFix(loc) {
        // FIXME
        return loc;
    }

    onUrlsChanged: {
        var newIndex = 0, oldIndex = 0;
        while (newIndex < urls.length && oldIndex < rssSourceModel.count) {
            var oldUrl = rssSourceModel.get(oldIndex).rssUrl;
            if (oldUrl != urls[newIndex]) {
                rssSourceModel.insert(oldIndex, {rssUrl: urls[newIndex]});
            }
            oldIndex++;
            newIndex++;
        }
        while (oldIndex < rssSourceModel.count) {
            rssSourceModel.remove(oldIndex);
        }
        while (newIndex < urls.length) {
            rssSourceModel.append({rssUrl: urls[newIndex]});
            newIndex++;
        }
        cleanUpTables();
    }

    property variant db
    Component.onCompleted: {
        initializeDb();
    }

    function initializeDb() {
        if (!db) {
            db = LocalStorage.openDatabaseSync("RssIndicatorDB", root.version, "SQLite for RssIndicator", 100);
        }
    }

    function cleanUpTables() {
        initializeDb();
        db.transaction(function (tx) {
            var rs = tx.executeSql("SELECT name FROM sqlite_master WHERE type=\"table\"");
            for (var i = 0; i < rs.rows.length; i++) {
                var tableName = rs.rows.item(i).name;
                if (urls.indexOf(tableName) == -1) {
                    tx.executeSql("DROP TABLE IF EXISTS [" + tableName + "]");
                }
            }
        })
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

        Item {
            id: emptyPage
        }

        onActiveRssChanged: {
            if (activeRss != null) {
                rssListPanel.replace({item: activeRss.feedList});
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
