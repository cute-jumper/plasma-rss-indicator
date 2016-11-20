import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

Item {
    id: compactRep

    Image {
        id: compactIcon
        source: root.appletIcon
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
        anchors.margins: units.smallSpacing

    }

    Rectangle {
        id: circle
        width: 20
        height: width
        radius: Math.round(width / 2)
        color: "Black"
        opacity: 0.7
        visible: root.totalUnread > 0
        anchors {
            right: parent.right
            top: parent.top
        }
    }

    Text {
        text: root.totalUnread > 99 ? "99+" : root.totalUnread
        font.pointSize: 6
        color: "White"
        anchors.centerIn: circle
        visible: circle.visible
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: plasmoid.expanded = !plasmoid.expanded
        hoverEnabled: true
    }
}

