import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.kirigami as Kirigami
import org.kde.bluezqt as BluezQt
import "components"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // Battery data properties
    property int batteryPercent: 0
    property bool isCharging: false
    property bool isBatterySaver: false
    property bool hasBattery: false
    property string batteryState: ""
    property int batteryCheckAttempts: 0
    property int maxBatteryCheckAttempts: 6  // Check for 30 seconds (6 * 5s intervals)

    // Bluetooth device properties
    readonly property BluezQt.Manager btManager: BluezQt.Manager
    property var bluetoothDevices: []

    // Helper function to update Bluetooth device list
    function updateBluetoothDevices() {
        var devices = []
        if (btManager.operational) {
            for (var i = 0; i < btManager.devices.length; i++) {
                var device = btManager.devices[i]
                // Only include connected devices with battery information
                if (device.connected && device.battery) {
                    devices.push({
                        name: device.name || device.alias || "Unknown Device",
                        address: device.address,
                        percentage: device.battery.percentage,
                        icon: getDeviceIcon(device),
                        device: device
                    })
                }
            }
        }
        bluetoothDevices = devices
    }

    // Helper function to determine device icon based on device type
    function getDeviceIcon(device) {
        var iconName = device.icon

        // Map common device icons to local SVG filenames (without .svg extension)
        if (iconName.includes("audio") || iconName.includes("headset") || iconName.includes("headphone")) {
            // Check if it's earbuds or headset
            if (iconName.includes("earbud")) {
                return "earbuds"
            }
            return "headset"
        } else if (iconName.includes("mouse")) {
            return "mouse"
        } else if (iconName.includes("keyboard")) {
            return "keyboard"
        } else if (iconName.includes("phone") || iconName.includes("watch")) {
            return "watch"
        } else if (iconName.includes("computer")) {
            return "computer"
        } else if (iconName.includes("speaker")) {
            return "speaker"
        } else if (iconName.includes("controller") || iconName.includes("gamepad")) {
            return "controller"
        } else {
            // Default fallback - will use Kirigami icon
            return ""
        }
    }

    // Monitor Bluetooth manager state
    Connections {
        target: btManager
        function onDeviceAdded() { updateBluetoothDevices() }
        function onDeviceRemoved() { updateBluetoothDevices() }
        function onDeviceChanged() { updateBluetoothDevices() }
        function onOperationalChanged() { updateBluetoothDevices() }
    }

    // Initial Bluetooth device update
    Component.onCompleted: {
        updateBluetoothDevices()
    }

    // Periodic update for battery percentage changes
    Timer {
        interval: 10000  // Update every 10 seconds
        running: true
        repeat: true
        onTriggered: updateBluetoothDevices()
    }

    // Font loader for ndot-55
    FontLoader {
        id: ndotFont
        source: Qt.resolvedUrl("../fonts/ndot-55.otf")
    }

    // Power Management Data Source (Plasma 6)
    P5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
        interval: 5000  // Update every 5 seconds

        onNewData: function(source, data) {
            if (source === "Battery") {
                var hasBat = data["Has Battery"] || false

                // If battery is found, reset the check attempts counter
                if (hasBat) {
                    root.batteryCheckAttempts = 0
                    root.hasBattery = true
                } else {
                    // Increment check attempts
                    if (root.batteryCheckAttempts < root.maxBatteryCheckAttempts) {
                        root.batteryCheckAttempts++
                    }
                    root.hasBattery = false
                }

                root.batteryPercent = data["Percent"] || 0
                root.batteryState = data["State"] || ""

                // Determine if battery saver mode is active
                // Battery saver is typically when "Battery Save Mode" is enabled
                root.isBatterySaver = data["Battery Save Mode"] || false
            } else if (source === "AC Adapter") {
                root.isCharging = data["Plugged in"] || false
            }
        }

        Component.onCompleted: {
            // Initial data load
            if (pmSource.data["Battery"]) {
                root.hasBattery = pmSource.data["Battery"]["Has Battery"] || false
                root.batteryPercent = pmSource.data["Battery"]["Percent"] || 0
                root.batteryState = pmSource.data["Battery"]["State"] || ""
                root.isBatterySaver = pmSource.data["Battery"]["Battery Save Mode"] || false
            }
            if (pmSource.data["AC Adapter"]) {
                root.isCharging = pmSource.data["AC Adapter"]["Plugged in"] || false
            }
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200

        // Hide the widget completely if no battery is found after several checks
        visible: root.hasBattery || root.batteryCheckAttempts < root.maxBatteryCheckAttempts

        // Main background
        Rectangle {
            id: mainBackground
            anchors.fill: parent
            anchors.margins: 10
            color: "#1a1a1a"
            radius: 20
            opacity: 0.95

            // 2x2 Grid Layout
            GridLayout {
                anchors.fill: parent
                anchors.margins: 15
                rows: 2
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // TOP LEFT - Main laptop battery circle
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 0
                    Layout.column: 0

                    CircularBatteryProgress {
                        anchors.fill: parent
                        percentage: root.batteryPercent
                        isCharging: root.isCharging
                        isBatterySaver: root.isBatterySaver
                        deviceType: "laptop"
                    }
                }

                // TOP RIGHT - First Bluetooth device
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 0
                    Layout.column: 1
                    visible: root.bluetoothDevices.length > 0

                    CircularBatteryProgress {
                        anchors.fill: parent
                        percentage: root.bluetoothDevices.length > 0 ? root.bluetoothDevices[0].percentage : 0
                        isCharging: false
                        isBatterySaver: false
                        deviceIcon: root.bluetoothDevices.length > 0 ? root.bluetoothDevices[0].icon : ""
                        isSystemDevice: false
                    }
                }

                // BOTTOM LEFT - Second Bluetooth device
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 0
                    visible: root.bluetoothDevices.length > 1

                    CircularBatteryProgress {
                        anchors.fill: parent
                        percentage: root.bluetoothDevices.length > 1 ? root.bluetoothDevices[1].percentage : 0
                        isCharging: false
                        isBatterySaver: false
                        deviceIcon: root.bluetoothDevices.length > 1 ? root.bluetoothDevices[1].icon : ""
                        isSystemDevice: false
                    }
                }

                // BOTTOM RIGHT - Battery percentage text
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 1

                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 2
                        anchors.bottomMargin: 2
                        text: root.hasBattery ? root.batteryPercent + "%" : "N/A"
                        font.family: ndotFont.name
                        font.pixelSize: parent.width * 0.4
                        color: "#ffffff"
                        opacity: 0.95
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                    }
                }
            }

            // No battery message
            Item {
                anchors.fill: parent
                visible: !root.hasBattery

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        source: "battery-missing"
                        color: "#666666"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No Battery"
                        font.pixelSize: 16
                        color: "#666666"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 150
                        text: "This device doesn't have a battery"
                        font.pixelSize: 11
                        color: "#555555"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
