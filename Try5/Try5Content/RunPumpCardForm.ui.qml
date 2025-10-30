import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: card
    implicitWidth: 360
    implicitHeight: 120

    property alias titleLabel: title
    property alias selectCheck: selectCheck
    property alias setFlowValue: setFlowValue
    property alias currentValue: currentValue

    property int pumpNumber: 0
    property real lastFlow: 0

    Rectangle { anchors.fill: parent; radius: 10; color: "#f5f5f7"; border.color: "#d0d0d5" }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        CheckBox { id: selectCheck; text: "" }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Label { id: title; text: "Pump"; font.bold: true }
            RowLayout {
                spacing: 8
                Label { text: "Set flow (µL/min):" }
                TextField { id: setFlowValue; text: "0"; Layout.preferredWidth: 100 }
                Label { text: "Current:" }
                Label { id: currentValue; text: "--" }
            }
        }
    }
}
