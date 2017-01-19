import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {

    property alias cfg_refresh: refresh.value
    property alias cfg_urls: urls.text
    property alias cfg_maxItems: maxItems.value
    property alias cfg_sourceTooltip: sourceTooltip.checked
    property alias cfg_itemTooltip: itemTooltip.checked


    GridLayout {
        id: firstGrid

        Layout.fillWidth: true
        rowSpacing: 10
        columnSpacing: 10
        columns: 2

        Text {
            text: "Refresh time (seconds)"
        }
        SpinBox {
            id: refresh
            decimals: 0
            stepSize: 100
            minimumValue: 1
            maximumValue: 86400
        }

        Text {
            text: "URLs (one per line)"
            Layout.alignment: Qt.AlignTop
        }
        TextArea {
            Layout.fillWidth: true
            Layout.minimumWidth: 400
            id: urls
        }

        Text {
            text: "Number of items to show"
            Layout.alignment: Qt.AlignTop
        }
        SpinBox {
            id: maxItems
            decimals: 0
            stepSize: 1
            minimumValue: 1
            maximumValue: 200
        }
    }

    Column {
        Layout.fillWidth: true
        anchors {
            top: firstGrid.bottom
            topMargin: Math.round(units.gridUnit / 3)
        }
        spacing: 10

        CheckBox {
            id: sourceTooltip
            text: i18n("Show tooltip when hovering over a feed title")
        }

        CheckBox {
            id: itemTooltip
            text: i18n("Show tooltip when hovering over an item")
        }

    }
}
