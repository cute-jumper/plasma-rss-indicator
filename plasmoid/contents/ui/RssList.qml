import QtQuick 2.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: rssList
    property alias model: listView.model
    property string rssTitle
    property string table
    property int unread

    ListView {
        id: listView


        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        delegate: PlasmaComponents.ListItem {
            id: rssItem
            enabled: true
            checked: rssItem.containsMouse

            height: root.iconSize + Math.round(units.gridUnit / 2)
            width: parent.width
            PlasmaCore.ToolTipArea {
                id: feedTitle

                property alias fontWeight: feedTitleText.font.weight
                anchors.fill: parent

                mainText: title
                subText: (pubDate ? "<p>" + pubDate + "</p><br/>" : "") + description
                interactive: true
                location: PlasmaCore.Types.LeftEdge

                Text {
                    id: feedTitleText
                    text: title
                    /* font.pointSize: Math.max(10, theme.smallestFont.pointSize) */
                    wrapMode: Text.WordWrap
                    font {
                        weight: read ? Font.Normal : Font.Bold
                    }
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        if (feedTitle.fontWeight != Font.Normal) {
                            feedTitle.fontWeight = Font.Normal;
                            /* fullRep.markEntryAsRead(table, sig); */
                            unread--;
                            fullRep.setSourceNameText(rssTitle, unread, listView.model.count);
                        }
                    } else if (mouse.button == Qt.RightButton) {
                        if (link) {
                            Qt.openUrlExternally(link);
                        }
                    }
                }
            }
        }
        snapMode: ListView.SnapToItem
    }
}
