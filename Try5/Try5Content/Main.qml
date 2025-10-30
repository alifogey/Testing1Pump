import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15
import Qt.labs.settings 1.1
import QtQuick.VirtualKeyboard 2.4

ApplicationWindow {
    id: app
    visible: true
    width: 1280
    height: 800
    title: "Microfluidic Pump Controller"

    header: TabBar {
        id: tabs
        TabButton { text: "Set up" }
        TabButton { text: "Run" }
    }
    Component.onCompleted: {
        console.log("typeof backend.prime =", typeof backend.prime)
    }
    StackLayout {
        id: stack
        anchors.fill: parent
        currentIndex: tabs.currentIndex
        SetupPageForm { id: setup }
        RunPageForm   { id: run   }
    }

    property int elapsedSec: 0
    Timer {
        id: runTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            elapsedSec += 1
            var h = Math.floor(elapsedSec/3600)
            var m = Math.floor((elapsedSec%3600)/60)
            var s = elapsedSec%60
            var hh = (h < 10 ? "0" : "") + h
            var mm = (m < 10 ? "0" : "") + m
            var ss = (s < 10 ? "0" : "") + s
            run.runTimeLabel.text = hh + ":" + mm + ":" + ss
        }
    }

    InputPanel {
        id: kb
        z: 9999
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: Qt.inputMethod.visible
    }

    QtObject {
        id: helper
        function setupCards() {
            return [setup.pump1, setup.pump2, setup.pump3,
                    setup.pump4, setup.pump5, setup.pump6,
                    setup.pump7, setup.pump8, setup.pump9];
        }
        function runCards() {
            return [run.r1, run.r2, run.r3, run.r4, run.r5, run.r6, run.r7, run.r8, run.r9];
        }
        function num(txt) {
            var v = Number.fromLocaleString(Qt.locale(), txt);
            return (isNaN(v) || v < 0) ? 0 : v;
        }
    }

    function parseFlow(txt) {
        var v = Number.fromLocaleString(Qt.locale(), txt)
        return (isNaN(v) || v <= 0) ? 0 : v
    }
    function forEachRunCard(fn) {
        var rc = helper.runCards()
        for (var i = 0; i < rc.length; ++i) {
            if (rc[i].visible) {
                var pump = rc[i].pumpNumber ? rc[i].pumpNumber : (i+1)
                fn(rc[i], pump)
            }
        }
    }

    Settings {
        id: presetSettings
        fileName: "presets.ini"
        category: "Presets"
        property string presetStore: "{}"
    }
    property var presetMap: (function(){ try { return JSON.parse(presetSettings.presetStore) } catch(e){ return {} } })()
    function persistPresets(){ presetSettings.presetStore = JSON.stringify(presetMap) }

    function readCurrentConfig() {
        var cards = helper.setupCards()
        var flows = [], checked = []
        for (var i = 0; i < cards.length; ++i) {
            flows.push(cards[i].flowField.text)
            checked.push(cards[i].enableCheck.checked)
        }
        return { flows: flows, checked: checked }
    }
    function applyConfig(cfg) {
        if (!cfg || !cfg.flows || cfg.flows.length !== 9) return
        var cards = helper.setupCards()
        for (var i = 0; i < 9; ++i) {
            cards[i].flowField.text = cfg.flows[i]
            if (cfg.checked && cfg.checked.length === 9)
                cards[i].enableCheck.checked = cfg.checked[i]
        }
    }

    Dialog {
        id: savePresetDialog
        modal: true
        title: "Save Preset"
        standardButtons: Dialog.Ok | Dialog.Cancel
        contentItem: ColumnLayout {
            spacing: 8; anchors.margins: 12
            Label { text: "Preset name:" }
            TextField { id: presetNameField; placeholderText: "e.g., Example One"; Layout.preferredWidth: 260 }
        }
        onAccepted: {
            var name = presetNameField.text.trim()
            if (!name.length) return
            if (presetMap.hasOwnProperty(name)) {
                overwriteDialog.pendingName = name
                overwriteDialog.open()
            } else {
                presetMap[name] = readCurrentConfig()
                persistPresets()
            }
        }
    }

    Dialog {
        id: overwriteDialog
        modal: true
        title: "Overwrite preset?"
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string pendingName: ""
        contentItem: ColumnLayout {
            anchors.margins: 12; spacing: 8
            Label { text: "A preset with this name already exists. Overwrite?" }
        }
        onAccepted: {
            if (pendingName.length) {
                presetMap[pendingName] = readCurrentConfig()
                persistPresets()
            }
            pendingName = ""
        }
        onRejected: pendingName = ""
    }

    ListModel { id: presetNamesModel }

    Dialog {
        id: loadPresetDialog
        modal: true
        title: "Load Preset"
        standardButtons: Dialog.Ok | Dialog.Cancel
        property int selectedIndex: -1

        contentItem: ColumnLayout {
            spacing: 10; anchors.margins: 12

            ListView {
                id: presetList
                model: presetNamesModel
                clip: true
                Layout.preferredWidth: 360
                Layout.preferredHeight: 260
                delegate: ItemDelegate {
                    width: ListView.view.width
                    text: name
                    onClicked: { loadPresetDialog.selectedIndex = index; presetList.currentIndex = index }
                }
            }

            RowLayout {
                spacing: 8
                Button { id: renameBtn; text: "Rename"; enabled: loadPresetDialog.selectedIndex >= 0 }
                Button { id: deleteBtn; text: "Delete"; enabled: loadPresetDialog.selectedIndex >= 0 }
                Item { Layout.fillWidth: true }
            }
        }

        function refreshList() {
            presetNamesModel.clear()
            var keys = Object.keys(presetMap).sort()
            for (var i = 0; i < keys.length; ++i)
                presetNamesModel.append({ "name": keys[i] })
            selectedIndex = presetList.currentIndex = (presetNamesModel.count ? 0 : -1)
        }

        onOpened: refreshList()
        onAccepted: {
            if (selectedIndex < 0 || selectedIndex >= presetNamesModel.count) return
            var chosen = presetNamesModel.get(selectedIndex).name
            applyConfig(presetMap[chosen])
        }
    }

    Dialog {
        id: renameDialog
        modal: true
        title: "Rename Preset"
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string oldName: ""
        contentItem: ColumnLayout {
            spacing: 8; anchors.margins: 12
            Label { text: "New name:" }
            TextField { id: renameNameField; Layout.preferredWidth: 260 }
        }
        onAccepted: {
            var newName = renameNameField.text.trim()
            if (!newName.length || !presetMap.hasOwnProperty(oldName)) return
            presetMap[newName] = presetMap[oldName]
            delete presetMap[oldName]
            persistPresets()
            loadPresetDialog.refreshList()
        }
    }

    Dialog {
        id: deleteDialog
        modal: true
        title: "Delete Preset"
        standardButtons: Dialog.Ok | Dialog.Cancel
        property string targetName: ""
        contentItem: ColumnLayout {
            anchors.margins: 12; spacing: 8
            Label { text: "Delete preset \"" + deleteDialog.targetName + "\"?" }
        }
        onAccepted: {
            if (presetMap.hasOwnProperty(targetName)) {
                delete presetMap[targetName]
                persistPresets()
                loadPresetDialog.refreshList()
            }
            targetName = ""
        }
        onRejected: targetName = ""
    }

    Connections {
        target: setup.savePresetButton
        function onClicked() {
            presetNameField.text = ""
            savePresetDialog.open()
        }
    }
    Connections {
        target: setup.loadPresetButton
        function onClicked() {
            loadPresetDialog.refreshList()
            loadPresetDialog.open()
        }
    }

    Connections {
        target: setup.applyGroupButton
        function onClicked() {
            var v = setup.groupFlowField.text
            var sc = helper.setupCards()
            for (var i = 0; i < sc.length; ++i)
                if (sc[i].enableCheck.checked)
                    sc[i].flowField.text = v
        }
    }

    Connections {
        target: setup.readyToRunButton
        function onClicked() {
            var rc = helper.runCards()
            for (var k = 0; k < rc.length; ++k) {
                rc[k].visible = false
                rc[k].selectCheck.checked = false
                rc[k].currentValue.text = "--"
                rc[k].lastFlow = 0
                rc[k].pumpNumber = k+1
            }
            var sc = helper.setupCards()
            for (var i = 0; i < sc.length && i < rc.length; ++i) {
                var f = helper.num(sc[i].flowField.text)
                if (sc[i].enableCheck.checked || f > 0) {
                    rc[i].visible = true
                    rc[i].titleLabel.text = sc[i].titleLabel.text
                    rc[i].setFlowValue.text = Number(f).toFixed(2)
                    rc[i].lastFlow = f
                    rc[i].pumpNumber = i+1
                }
            }
            elapsedSec = 0
            run.runTimeLabel.text = "00:00:00"
            tabs.currentIndex = 1
        }
    }

    Connections {
        target: run.startButton
        function onClicked() {
            var any = false
            forEachRunCard(function(card, pump) {
                var f = parseFlow(card.setFlowValue.text)
                card.lastFlow = f
                if (f > 0) { backend.set_flow(pump, f); any = true }
            })
            if (any && !runTimer.running) runTimer.start()
        }
    }
    Connections { target: run.pauseButton; function onClicked() { backend.stop_all(); runTimer.stop() } }
    Connections {
        target: run.stopButton
        function onClicked() { backend.stop_all(); runTimer.stop(); elapsedSec = 0; run.runTimeLabel.text = "00:00:00" }
    }
    Connections {
        target: run.pauseSelectedButton
        function onClicked() { forEachRunCard(function(card, pump) { if (card.selectCheck.checked) backend.stop(pump) }) }
    }
    Connections {
        target: run.resumeSelectedButton
        function onClicked() {
            forEachRunCard(function(card, pump) {
                if (card.selectCheck.checked) {
                    var f = parseFlow(card.setFlowValue.text)
                    if (f <= 0) f = card.lastFlow
                    if (f > 0) backend.set_flow(pump, f)
                }
            })
        }
    }

    Connections { target: setup.pump1.primeButton; function onClicked(){ backend.prime(1) } }
    Connections { target: setup.pump2.primeButton; function onClicked(){ backend.prime(2) } }
    Connections { target: setup.pump3.primeButton; function onClicked(){ backend.prime(3) } }
    Connections { target: setup.pump4.primeButton; function onClicked(){ backend.prime(4) } }
    Connections { target: setup.pump5.primeButton; function onClicked(){ backend.prime(5) } }
    Connections { target: setup.pump6.primeButton; function onClicked(){ backend.prime(6) } }
    Connections { target: setup.pump7.primeButton; function onClicked(){ backend.prime(7) } }
    Connections { target: setup.pump8.primeButton; function onClicked(){ backend.prime(8) } }
    Connections { target: setup.pump9.primeButton; function onClicked(){ backend.prime(9) } }

    Connections { target: setup.pump1.flowField; function onEditingFinished(){ var v=helper.num(setup.pump1.flowField.text); run.r1.lastFlow=v; run.r1.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump2.flowField; function onEditingFinished(){ var v=helper.num(setup.pump2.flowField.text); run.r2.lastFlow=v; run.r2.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump3.flowField; function onEditingFinished(){ var v=helper.num(setup.pump3.flowField.text); run.r3.lastFlow=v; run.r3.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump4.flowField; function onEditingFinished(){ var v=helper.num(setup.pump4.flowField.text); run.r4.lastFlow=v; run.r4.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump5.flowField; function onEditingFinished(){ var v=helper.num(setup.pump5.flowField.text); run.r5.lastFlow=v; run.r5.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump6.flowField; function onEditingFinished(){ var v=helper.num(setup.pump6.flowField.text); run.r6.lastFlow=v; run.r6.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump7.flowField; function onEditingFinished(){ var v=helper.num(setup.pump7.flowField.text); run.r7.lastFlow=v; run.r7.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump8.flowField; function onEditingFinished(){ var v=helper.num(setup.pump8.flowField.text); run.r8.lastFlow=v; run.r8.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
    Connections { target: setup.pump9.flowField; function onEditingFinished(){ var v=helper.num(setup.pump9.flowField.text); run.r9.lastFlow=v; run.r9.setFlowValue.text=Number(v).toFixed(2) } function onAccepted(){ onEditingFinished() } }
}
