import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 1200
    implicitHeight: 700

    /* Expose key fields so backend/Main can bind without JS */
    property alias groupFlowField: groupFlowField
    property alias applyGroupButton: applyGroupButton
    property alias loadPresetButton: loadPresetButton
    property alias savePresetButton: savePresetButton
    property alias readyToRunButton: readyToRunButton

    /* Expose each pump card instance */
    property alias pump1: pc1
    property alias pump2: pc2
    property alias pump3: pc3
    property alias pump4: pc4
    property alias pump5: pc5
    property alias pump6: pc6
    property alias pump7: pc7
    property alias pump8: pc8
    property alias pump9: pc9

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // --- GROUP CONTROLS SECTION ---
        GroupBox {
            title: "Group Controls"
            Layout.fillWidth: true
            Layout.preferredHeight: 90

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Label { text: "Flow:" }

                TextField {
                    id: groupFlowField
                    text: "0.00"
                    placeholderText: "0.00"
                    validator: DoubleValidator { bottom: 0; decimals: 2 }
                    Layout.preferredWidth: 100
                    inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhPreferNumbers
                }
                Label {
                    text: "µL/min"
                    color: "#555"
                }

                Button {
                    id: applyGroupButton
                    text: "Apply to Selected"
                    Layout.preferredWidth: 180
                }

                Button {
                    id: readyToRunButton
                    text: "Ready to Run"
                    Layout.preferredWidth: 180
                }

                Item { Layout.fillWidth: true }

                Button {
                    id: loadPresetButton
                    text: "Load Preset"
                    Layout.preferredWidth: 160
                }

                Button {
                    id: savePresetButton
                    text: "Save Preset"
                    Layout.preferredWidth: 160
                }
            }
        }


        // --- GRID OF PUMPS ---
        GridLayout {
            id: grid
            columns: 3
            rowSpacing: 18
            columnSpacing: 18
            Layout.fillWidth: true
            Layout.fillHeight: true

            PumpCardForm { id: pc1; titleLabel.text: "Pump 1" }
            PumpCardForm { id: pc2; titleLabel.text: "Pump 2" }
            PumpCardForm { id: pc3; titleLabel.text: "Pump 3" }
            PumpCardForm { id: pc4; titleLabel.text: "Pump 4" }
            PumpCardForm { id: pc5; titleLabel.text: "Pump 5" }
            PumpCardForm { id: pc6; titleLabel.text: "Pump 6" }
            PumpCardForm { id: pc7; titleLabel.text: "Pump 7" }
            PumpCardForm { id: pc8; titleLabel.text: "Pump 8" }
            PumpCardForm { id: pc9; titleLabel.text: "Pump 9" }
        }
    }
}



