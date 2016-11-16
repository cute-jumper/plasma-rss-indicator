import QtQuick 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.FrameSvgItem {
    id: expandedItem

    property Item visualParent
    property Item target
    property int location

    x: Math.max(0, (target ? target.x : 0) + (visualParent ? visualParent.x : 0))
    y: Math.max(0, (target ? target.y : 0) + (visualParent ? visualParent.y : 0))
    width: Math.min(parent.width, target ? target.width : 0)
    height: Math.min(parent.height, target ? target.height : 0)

    imagePath: "widgets/tabbar"
    prefix: {
        var prefix = ""
        switch (location) {
            case PlasmaCore.Types.LeftEdge:
                prefix = "west-active-tab";
                break;
            case PlasmaCore.Types.TopEdge:
                prefix = "north-active-tab";
                break;
            case PlasmaCore.Types.RightEdge:
                prefix = "east-active-tab";
                break;
            default:
                prefix = "south-active-tab";
            }
            if (!hasElementPrefix(prefix)) {
                prefix = "active-tab";
            }
            return prefix;
        }
    opacity: 1
    Behavior on opacity {
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on x {
        enabled: target && expandedItem.opacity == 1
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on y {
        enabled: target && expandedItem.opacity == 1
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on width {
        enabled: target && expandedItem.opacity == 1
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on height {
        enabled: target && expandedItem.opacity == 1
        NumberAnimation {
            duration: units.longDuration
            easing.type: Easing.InOutQuad
        }
    }
}
