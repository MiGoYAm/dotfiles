import Quickshell
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Networking
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland 
import "." as Local

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }
    exclusiveZone: bar.implicitHeight
    implicitHeight: bar.implicitHeight
    color: "black"

    WlrLayershell.layer: WlrLayer.Top

    Rectangle {
        id: bar
        anchors.fill: parent
        color: "transparent"
        implicitHeight: status.implicitHeight + 8

        // lewa sekcja: workspace indicator + pills okien
        Local.Workspaces {
            id: workspacesIndicator
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
        }


        Row {
            id: status
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 8
            }
            spacing: 14

            // System tray - ikony aplikacji (SNI/StatusNotifier)
            Row {
                id: tray
                spacing: 8

                Repeater {
                    model: SystemTray.items

                    MouseArea {
                        id: trayItem
                        required property var modelData
                        width: 16
                        height: 16
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) modelData.activate();
                            else if (modelData.hasMenu) modelData.display(menuAnchor, 0, 20);
                        }

                        IconImage {
                            source: trayItem.modelData ? trayItem.modelData.icon : ""
                            implicitSize: 16
                            anchors.centerIn: parent
                        }
                    }
                }
                Component.onCompleted: console.log("TRAY items", SystemTray.items.values.length)
            }

            // WiFi - Quickshell.Networking + gotowe ikony Adwaita
            Item {
                id: wifi
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter

                property var wifiDevice: {
                    for (let i = 0; i < Networking.devices.values.length; i++) {
                        let d = Networking.devices.values[i];
                        if (d.type === 1) {
                            d.scannerEnabled = true;
                            return d;
                        }
                    }
                    return null;
                }
                property var activeNet: {
                    if (!wifiDevice || !wifiDevice.networks) return null;
                    for (let j = 0; j < wifiDevice.networks.values.length; j++) {
                        let n = wifiDevice.networks.values[j];
                        if (n.connected) return n;
                    }
                    return null;
                }
                property bool connected: activeNet !== null && wifiDevice && wifiDevice.connected
                // signalStrength z WifiNetwork to 0.0-1.0, nie 0-100
                property real signal: activeNet ? activeNet.signalStrength : 0

                property string iconName: {
                    if (!connected) return "network-wireless-offline-symbolic";
                    if (signal >= 0.75) return "network-wireless-signal-excellent-symbolic";
                    if (signal >= 0.5) return "network-wireless-signal-good-symbolic";
                    if (signal >= 0.25) return "network-wireless-signal-ok-symbolic";
                    return "network-wireless-signal-weak-symbolic";
                }

                // brak internetu - połączono z AP ale connectivity None/Portal/Limited
                // (Networking.connectivity nie istnieje w qs 0.2.1 -> nmcli przez Process)
                property bool noInternet: false
                onNoInternetChanged: console.log("NET noInternet", noInternet)

                Process {
                    id: connCheck
                    command: ["nmcli", "networking", "connectivity"]
                    stdout: StdioCollector {
                        onStreamFinished: wifi.noInternet = wifi.connected && text.trim() !== "full"
                    }
                }
                Timer {
                    interval: 15000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: connCheck.running = true
                }

                IconImage {
                    id: wifiIcon
                    source: {
                        let base = "file:///usr/share/icons/Adwaita/symbolic/status/";
                        if (wifi.noInternet) return base + "network-wireless-no-route-symbolic.svg";
                        return base + wifi.iconName + ".svg";
                    }
                    implicitSize: 16
                    anchors.centerIn: parent
                    visible: false
                }
                MultiEffect {
                    id: tint
                    source: wifiIcon
                    width: 16
                    height: 16
                    x: 0
                    y: 0
                    brightness: 1.0
                    contrast: 1.0
                    saturation: 0.0
                    colorization: 1.0
                    colorizationColor: "#ffffff"
                }
            }

            // Ethernet - ikona tylko gdy kabel podpięty
            Item {
                id: eth
                width: 16
                height: 16
                anchors.verticalCenter: parent.verticalCenter

                property bool connected: {
                    for (let i = 0; i < Networking.devices.values.length; i++) {
                        let d = Networking.devices.values[i];
                        // WiredDevice ma type 0 (ethernet)
                        if (d.type === 0 && d.connected) return true;
                    }
                    return false;
                }

                visible: connected

                IconImage {
                    id: ethIcon
                    source: "file:///usr/share/icons/Adwaita/symbolic/devices/network-wired-symbolic.svg"
                    implicitSize: 16
                    anchors.centerIn: parent
                    visible: false
                }
                MultiEffect {
                    source: ethIcon
                    width: 16
                    height: 16
                    x: 0
                    y: 0
                    brightness: 1.0
                    contrast: 1.0
                    saturation: 0.0
                    colorization: 1.0
                    colorizationColor: "#ffffff"
                }
            }

            Item {
                id: batteryIcon
                width: 23
                height: 11
                anchors.verticalCenter: parent.verticalCenter
                property real pct: UPower.displayDevice.percentage
                property bool isCharging: UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged
                property bool isLow: pct < 0.2
                property string fillColor: isLow ? "#ff3b30" : isCharging ? "#30d158" : "white"

                Rectangle {
                    id: batteryBody
                    width: 20
                    height: 11
                    radius: 3
                    color: "#8e8e93"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }
                Rectangle {
                    width: 2
                    height: 5.5
                    radius: 0.8
                    color: "#8e8e93"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 21
                }

                Item {
                    width: Math.round(batteryIcon.pct * 23)
                    height: parent.height
                    clip: true
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        width: 20
                        height: 11
                        radius: 3
                        color: batteryIcon.fillColor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                    }
                    Rectangle {
                        width: 2
                        height: 5.5
                        radius: 0.8
                        color: batteryIcon.fillColor
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 21
                    }
                }

                Text {
                    anchors.centerIn: batteryBody
                    text: batteryIcon.isCharging ? "⚡" + Math.round(batteryIcon.pct * 100) : Math.round(batteryIcon.pct * 100)
                    color: "#636366"
                    font.pixelSize: batteryIcon.isCharging ? 7 : 8.5
                    font.weight: 700
                    font.features: { "tnum": 1 }
                }
            }

            Text {
                color: "white"
                font {
                    pixelSize: 12
                    weight: 550
                    features: { "tnum": 1 }
                }
                SystemClock {
                    id: clock
                    precision: SystemClock.Minutes
                }
                text: Qt.formatDateTime(clock.date, "d MMM  hh:mm")
            }
        }
    }
}
