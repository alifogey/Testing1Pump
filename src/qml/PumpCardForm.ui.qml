import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 140

    // Aliases so parent pages can wire signals to inside controls
    property alias setBox: enableCheck         // <- maps to your CheckBox
    property alias flowSpin: flowField         // <- maps to your TextField
    property alias primeButton: primeButton
    property alias titleLabel: titleLabel

    // (Optional) also export the native names if you want to use them directly:
    property alias enableCheck: enableCheck
    property alias flowField: flowField     // <— new

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
            CheckBox { id: enableCheck }
            Label {
                id: titleLabel
                text: "Pump 1"
                font.bold: true
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            spacing: 10

            Label {
                text: "Flow:"
                Layout.alignment: Qt.AlignVCenter
            }

            TextField {
                id: flowField
                placeholderText: "0.00"
                text: "0.00"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 80
                // this requests digits + punctuation (period) keyboard
                inputMethodHints: Qt.ImhFormattedNumbersOnly | Qt.ImhPreferNumbers
            }

            Label {
                text: "µL/min"
                color: "#555"
                Layout.alignment: Qt.AlignVCenter
            }

            Button {
                id: primeButton
                text: "Prime"
                Layout.preferredWidth: 80
            }

            Item { Layout.fillWidth: true }
        }
    }
}


