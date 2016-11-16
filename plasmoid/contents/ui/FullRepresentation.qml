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
            model: 3
            delegate: rssSourceDelegate
            snapMode: ListView.SnapToItem
        }
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
