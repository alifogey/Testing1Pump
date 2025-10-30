import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 1200
    implicitHeight: 700

    property alias savePresetButton: savePresetButton
    property alias loadPresetButton: loadPresetButton
    property alias applyGroupButton: applyGroupButton
    property alias readyToRunButton: readyToRunButton

    property alias groupFlowField: groupFlowField

    property alias pump1: pump1
    property alias pump2: pump2
    property alias pump3: pump3
    property alias pump4: pump4
    property alias pump5: pump5
    property alias pump6: pump6
    property alias pump7: pump7
    property alias pump8: pump8
    property alias pump9: pump9

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            spacing: 8
            Button { id: savePresetButton; text: "Save Preset" }
            Button { id: loadPresetButton; text: "Load Preset" }
            Item { Layout.fillWidth: true }
            Label { text: "Group flow:" }
            TextField { id: groupFlowField; text: "0"; Layout.preferredWidth: 100 }
            Button { id: applyGroupButton; text: "Apply to checked" }
            Button { id: readyToRunButton; text: "Ready to Run" }
        }

        GridLayout {
            columns: 3
            rowSpacing: 18
            columnSpacing: 18
            Layout.fillWidth: true
            Layout.fillHeight: true

            PumpCardForm { id: pump1;  titleLabel.text: "Pump 1" }
            PumpCardForm { id: pump2;  titleLabel.text: "Pump 2" }
            PumpCardForm { id: pump3;  titleLabel.text: "Pump 3" }
            PumpCardForm { id: pump4;  titleLabel.text: "Pump 4" }
            PumpCardForm { id: pump5;  titleLabel.text: "Pump 5" }
            PumpCardForm { id: pump6;  titleLabel.text: "Pump 6" }
            PumpCardForm { id: pump7;  titleLabel.text: "Pump 7" }
            PumpCardForm { id: pump8;  titleLabel.text: "Pump 8" }
            PumpCardForm { id: pump9;  titleLabel.text: "Pump 9" }
        }
    }
}
