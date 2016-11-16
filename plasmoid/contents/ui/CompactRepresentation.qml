import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddons

Item {
    id: compactRep

    Layout.minimumWidth: units.gridUnit * 8
    Layout.minimumHeight: units.iconSizes.small
PlasmaComponents.Label {
    Layout.minimumWidth : formFactor == PlasmaCore.Types.Horizontal ? height : 1
    Layout. minimumHeight : formFactor == PlasmaCore.Types.Vertical ? width  : 1
    text: "Hello world in plasma5 ";
}
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: plasmoid.expanded = !plasmoid.expanded
    }
}

