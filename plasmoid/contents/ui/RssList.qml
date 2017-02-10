import QtQuick 2.4
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: rssList
    property alias model: listView.model
    property bool bulkChangeRead

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

            property bool read: model.read

            Component.onCompleted: {
                rssItem.onReadChanged.connect(function() {
                    if (read && !bulkChangeRead) {
                        listItem.markEntryAsRead(sig);
                    }
                });
            }

            PlasmaCore.ToolTipArea {
                id: feedTitle

                active: plasmoid.configuration.itemTooltip

                property alias fontWeight: feedTitleText.font.weight
                anchors.fill: parent

                mainText: title
                subText: (pubDate ? "<p>" + pubDate + "</p><br/>" : "") + description
                interactive: true
                location: PlasmaCore.Types.LeftEdge

                Text {
                    id: feedTitleText
                    text: title
                    anchors {
                        left: parent.left
                        leftMargin: units.smallSpacing
                        verticalCenter: parent.verticalCenter
                    }
                    color: theme.textColor
                    wrapMode: Text.WordWrap
                    font {
                        /*     pointSize: Math.max(10, theme.smallestFont.pointSize) */
                        weight: read ? Font.Normal : Font.Bold
                    }
                }
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                property int leftButtonBehavior
                property int rightButtonBehavior

                Component.onCompleted: {
                    leftButtonBehavior = Qt.binding(function () {
                        if (plasmoid.configuration.leftClickMark)
                            return 1; // mark as read
                        else if (plasmoid.configuration.leftClickOpen)
                            return 2; // open url
                        return 0;
                    });
                    rightButtonBehavior = Qt.binding(function () {
                        if (plasmoid.configuration.rightClickMark)
                            return 1; // mark as read
                        else if (plasmoid.configuration.rightClickOpen)
                            return 2; // open url
                        return 0;
                    });
                }

                onClicked: {
                    var behavior = -1;
                    if (mouse.button == Qt.LeftButton) {
                        behavior = leftButtonBehavior;
                    } else if (mouse.button == Qt.RightButton) {
                        behavior = rightButtonBehavior;
                    }
                    if (behavior > 0) {
                        if (!read) {
                            read = true;
                        }
                        if (behavior == 2 && link) {
                            Qt.openUrlExternally(link);
                        }
                    }
                }
            }
        }
        snapMode: ListView.SnapToItem
    }
}
