import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    
    property alias cfg_refresh: refresh.value
    property alias cfg_urls: urls.text

    GridLayout {
       Layout.fillWidth: true
       rowSpacing: 10
       columnSpacing: 10
       columns: 2
        
       Text {
           text: "Reload time (seconds)"
       }
       SpinBox {
            id: refresh
            decimals: 0
            stepSize: 1
            minimumValue: 1
            maximumValue: 1800
            
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
    }
    
}
