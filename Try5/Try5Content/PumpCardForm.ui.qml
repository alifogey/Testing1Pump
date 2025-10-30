import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: form
    implicitWidth: 360
    implicitHeight: 140

    property alias titleLabel: titleLabel
    property alias flowField: flowField
    property alias enableCheck: enableCheck
    property alias primeButton: primeButton

    Rectangle { anchors.fill: parent; radius: 10; color: "#f7f9fb"; border.color: "#d0d0d5" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            spacing: 8
            CheckBox { id: enableCheck; text: "" }
            Label { id: titleLabel; text: "Pump"; font.bold: true }
            Item { Layout.fillWidth: true }
            Button { id: primeButton; text: "Prime" }
        }

        RowLayout {
            spacing: 8
            Label { text: "Flow (µL/min):" }
            TextField { id: flowField; text: "0"; Layout.preferredWidth: 100 }
        }
    }
}
