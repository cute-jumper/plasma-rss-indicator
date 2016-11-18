import QtQuick 2.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    property alias model: listView.model
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
                anchors.fill: parent

                mainText: title
                subText: (pubDate ? "<p>" + pubDate + "</p><br/>" : "") + description
                interactive: true
                location: PlasmaCore.Types.LeftEdge

                Text {
                    text: title
                    /* font.pointSize: Math.max(10, theme.smallestFont.pointSize) */
                    wrapMode: Text.WordWrap
                }
            }
            onClicked: {
                Qt.openUrlExternally(link);
            }
        }
        snapMode: ListView.SnapToItem
    }
}
