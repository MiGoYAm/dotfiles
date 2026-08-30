import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: workspaceIndexLabel.implicitWidth + 10 + previewMaxWidth

    readonly property int pillHeight: 9
    readonly property int columnGap: 4
    readonly property int segmentGap: 1
    readonly property int previewMaxWidth: 256
    readonly property int pillBaseUnit: 40
    readonly property int rowHeight: 14
    readonly property int animationDuration: 250

    property var workspaces: []
    property var windows: []
    property int focusedWindowId: 0

    function parseWindow(obj) {
        const layout = obj.layout || {};
        const pos = layout.pos_in_scrolling_layout || [0, 0];
        const tileSize = layout.tile_size || [0, 0];
        return {
            windowId: obj.id,
            workspaceId: obj.workspace_id,
            columnIndex: pos[0] || 0,
            tileIndex: pos[1] || 0,
            tileWidth: tileSize[0] || 0,
            tileHeight: tileSize[1] || 0,
            isFloating: obj.is_floating || false,
            isUrgent: obj.is_urgent || false
        };
    }

    function handleEvent(event) {
        if (event.WorkspacesChanged) {
            workspaces = (event.WorkspacesChanged.workspaces || []).map(w => ({
                        id: w.id,
                        index: w.idx,
                        isFocused: w.is_focused,
                        isActive: w.is_active,
                        isUrgent: w.is_urgent || false
                    }));
        } else if (event.WorkspaceUrgencyChanged) {
            const wuid = event.WorkspaceUrgencyChanged.id;
            const wurg = event.WorkspaceUrgencyChanged.urgent || false;
            workspaces = workspaces.map(w => w.id === wuid ? {
                    id: w.id,
                    index: w.index,
                    isFocused: w.isFocused,
                    isActive: w.isActive,
                    isUrgent: wurg
                } : w);
        } else if (event.WorkspaceActivated) {
            const wid = event.WorkspaceActivated.id;
            const focused = event.WorkspaceActivated.focused;
            workspaces = workspaces.map(w => {
                if (w.id === wid)
                    return {
                        id: w.id,
                        index: w.index,
                        isFocused: focused,
                        isActive: w.isActive,
                        isUrgent: w.isUrgent || false
                    };
                if (focused)
                    return {
                        id: w.id,
                        index: w.index,
                        isFocused: false,
                        isActive: w.isActive,
                        isUrgent: w.isUrgent || false
                    };
                return w;
            });
        } else if (event.WindowsChanged) {
            const wins = event.WindowsChanged.windows || [];
            windows = wins.map(parseWindow);
            const focused = wins.find(w => w.is_focused);
            focusedWindowId = focused ? focused.id : 0;
        } else if (event.WindowOpenedOrChanged) {
            const w2raw = event.WindowOpenedOrChanged.window;
            const w2 = parseWindow(w2raw);
            if (w2raw.is_focused)
                focusedWindowId = w2.windowId;
            const idx2 = windows.findIndex(w => w.windowId === w2.windowId);
            if (idx2 === -1) {
                windows = windows.concat([w2]);
            } else {
                windows = windows.map((w, i) => i === idx2 ? w2 : w);
            }
        } else if (event.WindowClosed) {
            const idc = event.WindowClosed.id;
            windows = windows.filter(w => w.windowId !== idc);
            if (focusedWindowId === idc)
                focusedWindowId = 0;
        } else if (event.WindowFocusChanged) {
            const idVal2 = event.WindowFocusChanged.id;
            focusedWindowId = (idVal2 === null || idVal2 === undefined) ? 0 : idVal2;
        } else if (event.WindowUrgencyChanged) {
            const wuid2 = event.WindowUrgencyChanged.id;
            const wurg2 = event.WindowUrgencyChanged.urgent || false;
            windows = windows.map(w => w.windowId === wuid2 ? {
                    windowId: w.windowId,
                    workspaceId: w.workspaceId,
                    columnIndex: w.columnIndex,
                    tileIndex: w.tileIndex,
                    tileWidth: w.tileWidth,
                    tileHeight: w.tileHeight,
                    isFloating: w.isFloating,
                    isUrgent: wurg2
                } : w);
        } else if (event.WindowLayoutsChanged) {
            const changes2 = event.WindowLayoutsChanged.changes || [];
            if (changes2.length > 0) {
                const map2 = changes2.reduce((acc, cur) => {
                    acc[cur[0]] = cur[1];
                    return acc;
                }, {});
                windows = windows.map(w => {
                    const lay4 = map2[w.windowId];
                    if (lay4) {
                        const pos3 = lay4.pos_in_scrolling_layout || [w.columnIndex, w.tileIndex];
                        const tileSize3 = lay4.tile_size || [w.tileWidth, w.tileHeight];
                        return {
                            windowId: w.windowId,
                            workspaceId: w.workspaceId,
                            columnIndex: pos3[0] || w.columnIndex,
                            tileIndex: pos3[1] || w.tileIndex,
                            tileWidth: tileSize3[0] || w.tileWidth,
                            tileHeight: tileSize3[1] || w.tileHeight,
                            isFloating: w.isFloating,
                            isUrgent: w.isUrgent || false
                        };
                    }
                    return w;
                });
            }
        }
    }

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim();
                if (!line)
                    return;
                try {
                    const ev = JSON.parse(line);
                    root.handleEvent(ev);
                } catch (e) {
                    console.warn("Niri parse", e, line.slice(0, 200));
                }
            }
        }
        onExited: (code, status) => {
            console.warn("Niri event-stream exited", code, status, "restarting");
            restartTimer.restart();
        }
    }

    Timer {
        id: restartTimer
        interval: 1000
        onTriggered: eventStream.running = true
    }

    function focusWindow(windowId) {
        const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        proc.command = ["niri", "msg", "action", "focus-window", "--id", String(windowId)];
        proc.running = true;
        proc.exited.connect(() => proc.destroy());
    }

    function sendRawAction(actionMap) {
        const key = Object.keys(actionMap)[0];
        if (!key)
            return;
        const kebab = key.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
        const proc2 = Qt.createQmlObject('import Quickshell.Io; Process {}', root);
        proc2.command = ["niri", "msg", "action", kebab];
        proc2.running = true;
        proc2.exited.connect(() => proc2.destroy());
    }

    readonly property var sortedWorkspaceIndices: workspaces.map(w => w.index).sort((a, b) => a - b)
    readonly property int minimumWorkspaceIndex: sortedWorkspaceIndices.length ? sortedWorkspaceIndices[0] : 1
    readonly property int focusedWorkspaceIndex: {
        const found = workspaces.find(w => w.isFocused);
        return found ? found.index : minimumWorkspaceIndex;
    }

    function usableWidth(count) {
        return count <= 0 ? previewMaxWidth : previewMaxWidth - columnGap * (count - 1);
    }

    function workspaceIdForIndex(idx) {
        const found = workspaces.find(w => w.index === idx);
        return found ? found.id : 0;
    }

    function isWindowFocused(windowId) {
        return focusedWindowId === windowId;
    }

    function isWindowUrgent(windowId) {
        for (var i = 0; i < windows.length; i++)
            if (windows[i].windowId === windowId && windows[i].isUrgent)
                return true;
        return false;
    }

    function columnsForWorkspace(workspaceId) {
        const windowsInWorkspace = windows.filter(w => w.workspaceId === workspaceId && !w.isFloating);
        if (windowsInWorkspace.length === 0)
            return [];

        const columnsByIndex = windowsInWorkspace.reduce((acc, w) => {
            const c = w.columnIndex || 1;
            if (!acc[c])
                acc[c] = [];
            acc[c].push(w);
            return acc;
        }, {});

        const sortedColumnIndices = Object.keys(columnsByIndex).map(Number).sort((a, b) => a - b);
        const naturalWidths = sortedColumnIndices.map(col => {
            const tw = columnsByIndex[col][0].tileWidth;
            const nw = tw / pillBaseUnit;
            return nw < 12 ? 12 : nw;
        });
        const gapsTotal = columnGap * Math.max(0, sortedColumnIndices.length - 1);
        const naturalPillsTotal = naturalWidths.reduce((a, b) => a + b, 0);
        const availableForPills = previewMaxWidth - gapsTotal;
        const scale = naturalPillsTotal > availableForPills ? availableForPills / naturalPillsTotal : 1;

        return sortedColumnIndices.map((columnIdx, idx) => {
            const colWins = columnsByIndex[columnIdx].slice().sort((a, b) => a.tileIndex - b.tileIndex);
            const columnKey = colWins.map(w => w.windowId).sort((a, b) => a - b).join(",");
            const width = naturalWidths[idx] * scale;
            const segments = colWins.map(w => ({
                windowId: w.windowId,
                tileHeight: w.tileHeight || 0,
                isUrgent: w.isUrgent || false
            }));
            const hasFocusedWindow = colWins.some(w => w.windowId === focusedWindowId);
            const hasUrgentWindow = colWins.some(w => w.isUrgent);
            return {
                columnKey: columnKey,
                columnId: columnIdx,
                width: width,
                segments: segments,
                hasFocusedWindow: hasFocusedWindow,
                hasUrgentWindow: hasUrgentWindow
            };
        }).sort((a, b) => a.columnId - b.columnId);
    }

    function columnKeysForWorkspace(workspaceId) {
        return columnsForWorkspace(workspaceId).map(c => ({
                    columnKey: c.columnKey
                }));
    }

    function columnDataByKey(columnKey, workspaceId) {
        const cols = columnsForWorkspace(workspaceId);
        const found = cols.find(c => c.columnKey === columnKey);
        return found || {
            columnKey: columnKey,
            width: 12,
            segments: [],
            hasFocusedWindow: false,
            hasUrgentWindow: false
        };
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
            Behavior on y {
                NumberAnimation {
                    duration: root.animationDuration
                    easing.type: Easing.OutCubic
                }
            }
            Repeater {
                id: workspaceRowRepeater
                model: root.sortedWorkspaceIndices
                ListView {
                    required property var modelData
                    readonly property int workspaceIdx: modelData
                    readonly property int workspaceId: root.workspaceIdForIndex(workspaceIdx)
                    x: 0
                    y: (workspaceIdx - root.minimumWorkspaceIndex) * root.rowHeight
                    width: contentWidth
                    height: root.rowHeight
                    orientation: ListView.Horizontal
                    interactive: false
                    spacing: root.columnGap
                    model: ScriptModel {
                        values: root.columnKeysForWorkspace(workspaceId)
                        objectProp: "columnKey"
                    }
                    delegate: ColumnLayout {
                        id: columnDelegate
                        required property var modelData
                        readonly property var colData: root.columnDataByKey(modelData.columnKey, workspaceId)
                        width: colData.width
                        height: root.pillHeight
                        spacing: root.segmentGap
                        z: colData.hasFocusedWindow ? 10 : 1
                        transformOrigin: Item.Left
                        Component.onCompleted: widthBehavior.enabled = true
                        Behavior on width {
                            id: widthBehavior
                            enabled: false
                            NumberAnimation {
                                duration: root.animationDuration
                                easing.type: Easing.OutCubic
                            }
                        }
                        Repeater {
                            model: columnDelegate.colData.segments
                            Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 2
                                Layout.preferredHeight: modelData.tileHeight
                                radius: 3
                                color: root.isWindowFocused(modelData.windowId) ? "#ffffff" : modelData.isUrgent ? "#ff453a" : "#555555"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.focusWindow(modelData.windowId)
                                }
                                Behavior on color {
                                    ColorAnimation {
                                        duration: root.animationDuration
                                    }
                                }
                                Behavior on height {
                                    NumberAnimation {
                                        duration: root.animationDuration
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }
                    }
                    add: Transition {
                        NumberAnimation {
                            property: "opacity"
                            from: 0
                            to: 1
                            duration: root.animationDuration * 0.7
                        }
                        NumberAnimation {
                            property: "scale"
                            from: 0
                            to: 1
                            duration: root.animationDuration
                            easing.type: Easing.OutBack
                        }
                    }
                    addDisplaced: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    remove: Transition {
                        NumberAnimation {
                            property: "opacity"
                            to: 0
                            duration: root.animationDuration
                        }
                        NumberAnimation {
                            property: "scale"
                            to: 0
                            duration: root.animationDuration
                            easing.type: Easing.InBack
                        }
                    }
                    removeDisplaced: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    displaced: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    move: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    moveDisplaced: Transition {
                        NumberAnimation {
                            properties: "x"
                            duration: root.animationDuration
                            easing.type: Easing.OutCubic
                        }
                    }
                    populate: null
                }
            }
        }
    }

    Timer {
        id: scrollCooldownTimer
        interval: 200
        onTriggered: root.canScroll = true
    }
    property bool canScroll: true
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (!root.canScroll)
                return;
            root.canScroll = false;
            scrollCooldownTimer.restart();
            let dir = event.angleDelta.y > 0 ? -1 : 1;
            let act = dir < 0 ? "FocusWorkspaceUp" : "FocusWorkspaceDown";
            root.sendRawAction({
                [act]: {}
            });
            event.accepted = true;
        }
    }
}
