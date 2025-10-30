import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 140
    property int pumpNumber:1
    property real lastFlow: 0.0
    /* Expose controls (no JS here) */
    property alias selectCheck: selectCheck
    property alias titleLabel: titleLabel
    property alias setFlowValue: setFlowValue
    property alias currentValue: currentValue

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: "#ffffff"
        border.color: "#cfd8dc"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            spacing: 8
            CheckBox { id: selectCheck } // for “pause selected” etc.
            Label {
                id: titleLabel
                text: "Pump 1"
                font.bold: true
            }
            Item { Layout.fillWidth: true }
        }

        // Read-only values
        ColumnLayout {
            spacing: 6

            RowLayout {
                spacing: 8
                Label { text: "Set Flow:" }
                Label { id: setFlowValue; text: "0.00"; font.bold: true }
                Label { text: "µL/min"; color: "#555" }
                Item { Layout.fillWidth: true }
            }

            RowLayout {
                spacing: 8
                Label { text: "Current:" }
                Label { id: currentValue; text: "--"; font.bold: true }
                Label { text: "mA"; color: "#555" }
                Item { Layout.fillWidth: true }
            }
        }
    }
}



