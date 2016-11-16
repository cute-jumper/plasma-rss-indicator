import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root
    property int iconSize: units.iconSizes.smallMedium
    property int leftColumnWidth: iconSize + Math.round(units.gridUnit / 2)
    /* Plasmoid.compactRepresentation: CompactRepresentation { } */
    Plasmoid.fullRepresentation: FullRepresentation { }
}
