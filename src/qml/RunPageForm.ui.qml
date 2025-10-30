import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 1200
    implicitHeight: 700

    property alias runTimeLabel: runTimeLabel
    property alias startButton: startButton
    property alias pauseButton: pauseButton
    property alias stopButton: stopButton
    property alias pauseSelectedButton: pauseSelectedButton
    property alias resumeSelectedButton: resumeSelectedButton

    property alias r1: r1
    property alias r2: r2
    property alias r3: r3
    property alias r4: r4
    property alias r5: r5
    property alias r6: r6
    property alias r7: r7
    property alias r8: r8
    property alias r9: r9

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Label {
            id: runTimeLabel
            text: "00:00:00"
            font.pointSize: 40
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            Button { id: startButton; text: "Start" }
            Button { id: pauseButton; text: "Pause All" }
            Button { id: stopButton;  text: "Stop All"  }
            Item { Layout.preferredWidth: 24 }
            Button { id: pauseSelectedButton;  text: "Pause Selected"  }
            Button { id: resumeSelectedButton; text: "Resume Selected" }
        }

        GridLayout {
            columns: 3
            rowSpacing: 18
            columnSpacing: 18
            Layout.fillWidth: true
            Layout.fillHeight: true

            RunPumpCardForm { id: r1; visible: false }
            RunPumpCardForm { id: r2; visible: false }
            RunPumpCardForm { id: r3; visible: false }
            RunPumpCardForm { id: r4; visible: false }
            RunPumpCardForm { id: r5; visible: false }
            RunPumpCardForm { id: r6; visible: false }
            RunPumpCardForm { id: r7; visible: false }
            RunPumpCardForm { id: r8; visible: false }
            RunPumpCardForm { id: r9; visible: false }
        }
    }
}
