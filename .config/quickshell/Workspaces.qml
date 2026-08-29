import Quickshell
import Niri
import QtQuick

// Wariant C — w pełni deklaratywny potok filter/map/reduce, bez forów i bez imperatywnego cache.
// Tożsamość kolumny = columnKey (sorted windowIds), pozycje i rozmiary liczone czysto funkcyjnie.
// Mostek windowBridge pozostaje minimalny (plugin nie udostępnia get()), ale cała logika
// transformacji to deklaratywne wyrażenie zależne od layoutRevision.
Item {
    id: root
    implicitWidth: workspaceIndexLabel.implicitWidth + 10 + previewMaxWidth
    implicitHeight: 16

    readonly property int pillHeight: 9
    readonly property int columnGap: 4
    readonly property int segmentGap: 1
    readonly property int previewMaxWidth: 256
    readonly property int pillBaseUnit: 40
    readonly property int rowHeight: 14
    readonly property int animationDuration: 100

    Niri {
        id: niri
        Component.onCompleted: connect()
        onConnected: coalesceTimer.restart()
        onRawEventReceived: coalesceTimer.restart()
    }

    Timer {
        id: coalesceTimer
        interval: 32
        repeat: false
        onTriggered: layoutRevision++
    }

    property int layoutRevision: 0
    property var _windowsSnapshot: []

    onLayoutRevisionChanged: {
        // snapshot windowBridge after coalesced update - avoids intermediate states
        const snap = []
        for (let i = 0; i < windowBridge.count; i++) {
            const d = windowBridge.objectAt(i)
            if (d) snap.push({ windowId: d.windowId, workspaceId: d.workspaceId, columnIndex: d.columnIndex, tileIndex: d.tileIndex, tileWidth: d.tileWidth, isFocused: d.isFocused, isFloating: d.isFloating })
        }
        _windowsSnapshot = snap
    }

    Instantiator {
        id: windowBridge
        model: niri.windows
        delegate: QtObject {
            required property var model
            readonly property var windowId: model.id
            readonly property var workspaceId: model.workspaceId
            readonly property var columnIndex: model.columnIndex
            readonly property var tileIndex: model.tileIndex
            readonly property var tileWidth: model.tileWidth
            readonly property var isFocused: model.isFocused
            readonly property var isFloating: model.isFloating
        }
    }

    function workspaceCount() { return niri.workspaces.count; }
    function getWorkspace(rowIdx) { return niri.workspaces.get(rowIdx); }

    readonly property var sortedWorkspaceIndices: {
        root.layoutRevision;
        return [...Array(workspaceCount()).keys()]
            .map(r => getWorkspace(r))
            .filter(w => w)
            .map(w => w.index)
            .sort((a,b)=>a-b)
    }
    readonly property int minimumWorkspaceIndex: sortedWorkspaceIndices.length ? sortedWorkspaceIndices[0] : 1
    readonly property int focusedWorkspaceIndex: {
        root.layoutRevision;
        const found = [...Array(workspaceCount()).keys()]
            .map(r => getWorkspace(r))
            .find(w => w && w.isFocused)
        return found ? found.index : minimumWorkspaceIndex
    }

    function usableWidth(count) {
        return count <= 0 ? previewMaxWidth : previewMaxWidth - columnGap * (count - 1)
    }

    function workspaceIdForIndex(idx) {
        const found = [...Array(niri.workspaces.count).keys()]
            .map(r => niri.workspaces.get(r))
            .find(w => w && w.index === idx)
        return found ? found.id : 0
    }

    function isWindowFocused(windowId) {
        return _windowsSnapshot.some(d => d.windowId === windowId && d.isFocused === true)
    }

    // Deklaratywna transformacja okien -> kolumny per workspace (snapshot, coalesced)
    function columnsForWorkspace(workspaceId) {
        root.layoutRevision;
        const windowsInWorkspace = _windowsSnapshot.filter(w => w.workspaceId === workspaceId && w.isFloating === false)
        if (windowsInWorkspace.length === 0) return []

        const columnsByIndex = windowsInWorkspace.reduce((acc, w) => {
            const c = w.columnIndex || 1
            if (!acc[c]) acc[c] = []
            acc[c].push(w)
            return acc
        }, {})

        const sortedColumnIndices = Object.keys(columnsByIndex).map(Number).sort((a,b)=>a-b)
        // Kompaktowy wariant per-preview (256): naturalna szerokość = tileWidth / pillBaseUnit (~20-44px dla typowych kafelków),
        // zachowuje proporcje kolumn (1395px->~35, 871px->~22), suma clamp do previewMaxWidth
        const naturalWidths = sortedColumnIndices.map(k => Math.max(12, columnsByIndex[k][0].tileWidth / pillBaseUnit))
        const gapsTotal = columnGap * Math.max(0, sortedColumnIndices.length - 1)
        const naturalPillsTotal = naturalWidths.reduce((a,b)=>a+b, 0)
        const availableForPills = previewMaxWidth - gapsTotal
        const scale = naturalPillsTotal > availableForPills ? availableForPills / naturalPillsTotal : 1

        return sortedColumnIndices
            .map((columnIdx, i) => {
                const windowsInColumn = [...columnsByIndex[columnIdx]].sort((a,b)=>a.tileIndex - b.tileIndex)
                const columnKey = windowsInColumn.map(w=>w.windowId).sort((a,b)=>a-b).join(",")
                const width = naturalWidths[i] * scale
                const segmentHeight = (pillHeight - (windowsInColumn.length-1)*segmentGap) / windowsInColumn.length
                const segments = windowsInColumn.map(w => ({ windowId: w.windowId, height: segmentHeight }))
                const hasFocusedWindow = windowsInColumn.some(w => w.isFocused === true)
                return { columnKey, columnId: columnIdx, width, segments, hasFocusedWindow }
            })
            .sort((a,b)=>a.columnId - b.columnId)
    }

    Text {
        id: workspaceIndexLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        font.pixelSize: 12
        font.weight: 550
        text: root.focusedWorkspaceIndex
    }

    Item {
        id: pillClipArea
        clip: true
        width: previewMaxWidth
        height: rowHeight
        anchors.left: workspaceIndexLabel.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter

        Item {
            id: workspaceRowsContainer
            x: 0
            width: previewMaxWidth
            height: rowHeight
            y: -(root.focusedWorkspaceIndex - root.minimumWorkspaceIndex) * root.rowHeight
            Behavior on y { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
        Repeater {
            id: workspaceRowRepeater
            model: root.sortedWorkspaceIndices
        Item {
            required property var modelData
            readonly property int workspaceIdx: modelData
            readonly property int workspaceId: {
                root.layoutRevision;
                return root.workspaceIdForIndex(workspaceIdx);
            }
            x: 0
            y: (workspaceIdx - root.minimumWorkspaceIndex) * root.rowHeight
            width: pillClipArea.width
            height: root.rowHeight

            ListView {
                width: contentWidth
                height: parent.height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                orientation: ListView.Horizontal
                interactive: false
                spacing: root.columnGap
                model: ScriptModel {
                    values: root.columnsForWorkspace(workspaceId)
                    objectProp: "columnKey"
                }
                delegate: Item {
                    id: columnDelegate
                    required property var modelData
                    width: modelData.width
                    height: root.rowHeight
                    z: modelData.hasFocusedWindow ? 10 : 1
                    Component.onCompleted: widthBehavior.enabled = true
                    Behavior on width {
                        id: widthBehavior
                        enabled: false
                        NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
                    }
                    Item {
                        id: pillContainer
                        anchors.fill: parent
                        opacity: columnDelegate.opacity
                        scale: columnDelegate.scale
                        transformOrigin: Item.Left
                        Column {
                            spacing: root.segmentGap
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            Repeater {
                                model: columnDelegate.modelData.segments
                                Rectangle {
                                    required property var modelData
                                    width: pillContainer.width
                                    height: modelData.height
                                    radius: 3
                                    color: root.isWindowFocused(modelData.windowId) ? "#ffffff" : "#555555"
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: niri.focusWindow(modelData.windowId)
                                    }
                                    Behavior on color { ColorAnimation { duration: root.animationDuration } }
                                    Behavior on height { NumberAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic } }
                                }
                            }
                        }
                    }
                }
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: root.animationDuration * 0.7 }
                    NumberAnimation { property: "scale"; from: 0; to: 1; duration: root.animationDuration; easing.type: Easing.OutBack }
                }
                addDisplaced: Transition { NumberAnimation { properties: "x"; duration: root.animationDuration; easing.type: Easing.OutCubic } }
                remove: Transition {
                    NumberAnimation { property: "opacity"; to: 0; duration: root.animationDuration }
                    NumberAnimation { property: "scale"; to: 0; duration: root.animationDuration; easing.type: Easing.InBack }
                }
                removeDisplaced: Transition { NumberAnimation { properties: "x"; duration: root.animationDuration; easing.type: Easing.OutCubic } }
                displaced: Transition { NumberAnimation { properties: "x"; duration: root.animationDuration; easing.type: Easing.OutCubic } }
                move: Transition { NumberAnimation { properties: "x"; duration: root.animationDuration; easing.type: Easing.OutCubic } }
                moveDisplaced: Transition { NumberAnimation { properties: "x"; duration: root.animationDuration; easing.type: Easing.OutCubic } }
                populate: null
            }
        }
        }
    }
    }

    Timer { id: scrollCooldownTimer; interval: 200; onTriggered: root.canScroll = true }
    property bool canScroll: true
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (!root.canScroll) return;
            root.canScroll = false;
            scrollCooldownTimer.restart();
            let dir = event.angleDelta.y > 0 ? -1 : 1;
            let act = dir < 0 ? "FocusWorkspaceUp" : "FocusWorkspaceDown";
            niri.sendRawAction({ [act]: {} });
            event.accepted = true;
        }
    }
}
