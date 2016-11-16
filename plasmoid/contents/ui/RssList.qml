import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    ListView {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            bottom: parent.bottom
            leftMargin: root.leftColumnWidth
        }
        clip: true
        model: 10
        header: rssListHeader
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
    Component {
        id: rssListHeader
        PlasmaExtras.Heading {
            id: heading
            level: 1

            height: paintedHeight

            horizontalAlignment: Text.AlignHCenter
            text: "Details"
        }
    }

}
