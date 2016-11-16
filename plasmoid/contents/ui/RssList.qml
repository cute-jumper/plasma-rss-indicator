import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    ListView {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        model: 10
        delegate: PlasmaComponents.ListItem {
            id: rssItem
            enabled: true
            checked: rssItem.containsMouse

            height: root.iconSize + Math.round(units.gridUnit / 2)
            width: parent.width
            Text {
                text: index
            }
        }
        snapMode: ListView.SnapToItem
    }
}
