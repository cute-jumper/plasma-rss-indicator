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
    PlasmaExtras.ScrollArea {
        anchors {
            top: heading.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        ListView {
            id: rssList
            anchors.fill: parent
            clip: true
            model: 3
            delegate: rssItemDelegate
            snapMode: ListView.SnapToItem
        }
    }
    StackView {
        id: rssDetails

        anchors {
            left: parent.left
            top: heading.bottom
            right: parent.right
            bottom: parent.bottom
            leftMargin: root.iconSize + units.smallSpacing
        }

        property Item activeRss

        Item {
            id: emptyPage
        }

        onActiveRssChanged: {
            if (activeRss != null) {

            }
        }

        Rectangle {
            anchors.fill: parent
            border.width: 2
        }
    }
    Component {
        id: rssItemDelegate
        PlasmaComponents.ListItem {
            id: listItem

            enabled: true
            checked: listItem.containsMouse

            height: rssSourceName.height + Math.round(units.gridUnit / 2)

            Image {
                id: rssSourceIcon
                width: root.iconSize
                height: width
                anchors.left: parent.left
                fillMode: Image.PreserveAspectCrop
                source: "http://www.ycombinator.com/images/ycombinator-logo-fb889e2e.png"
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
                text: "hackernews"
            }
            property bool click: true
            onClicked: {
                rssDetails
                rssSourceName.font.weight = click ? Font.DemiBold : Font.Normal;
                click = !click;
            }
        }
    }
}
