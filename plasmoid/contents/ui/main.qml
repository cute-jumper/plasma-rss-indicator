import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root
    property string appName: "rssIndicator"
    property string version: "0.1"
    property int iconSize: units.iconSizes.smallMedium
    property int leftColumnWidth: iconSize + Math.round(units.gridUnit / 2)
    property string appletIcon: "rssindicator.png"

    /* Plasmoid.compactRepresentation: CompactRepresentation { } */
    /* Plasmoid.fullRepresentation: FullRepresentationMock { } */
    Plasmoid.fullRepresentation: FullRepresentation { }

    PlasmaCore.DataSource {
        id: notificationSource
        engine: "notifications"
        connectedSources: "org.freedesktop.Notifications"
    }

    function createNotification(title, text) {
        var service = notificationSource.serviceForSource("notification");
        var operation = service.operationDescription("createNotification");

        operation.appName = root.appName
        operation["appIcon"] = root.appletIcon
        operation.summary = title;
        operation["body"] = text;
        // TODO
        operation["timeout"] = 2000;

        service.startOperationCall(operation);
    }
}
