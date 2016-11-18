import QtQuick 2.4
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
            Text {
                text: title
            }
        }
        snapMode: ListView.SnapToItem

        onModelChanged: {
            console.log("model: " + model);
        }
    }
}
