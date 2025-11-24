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
    property bool batteryLoading: true  // Loading state for battery detection
    property bool isPCMode: false  // True when device has no battery (desktop PC)
    property real energyRate: 0  // Power consumption/generation in watts

    // Bluetooth device properties
    readonly property BluezQt.Manager btManager: BluezQt.Manager
    property var bluetoothDevices: []

    // Configuration properties
    property var customIconMappings: []
    property var deviceHistory: []

    // Watch for configuration changes
    Connections {
        target: plasmoid.configuration
        function onCustomIconMappingsChanged() {
            loadCustomMappings()
            updateBluetoothDevices()  // Refresh to apply new mappings
        }
    }

    function loadCustomMappings() {
        if (!plasmoid.configuration.customIconMappings) {
            customIconMappings = []
            return
        }
        try {
            customIconMappings = JSON.parse(plasmoid.configuration.customIconMappings)
        } catch (e) {
            console.error("Failed to parse custom icon mappings:", e)
            customIconMappings = []
        }
    }

    function loadDeviceHistory() {
        if (!plasmoid.configuration.deviceHistory) {
            deviceHistory = []
            return
        }
        try {
            deviceHistory = JSON.parse(plasmoid.configuration.deviceHistory)
        } catch (e) {
            console.error("Failed to parse device history:", e)
            deviceHistory = []
        }
    }

    function saveDeviceHistory(history) {
        plasmoid.configuration.deviceHistory = JSON.stringify(history)
    }

    // Update device history with new devices
    function updateDeviceHistory(device) {
        loadDeviceHistory()

        // Check if device already exists
        var exists = false
        for (var i = 0; i < deviceHistory.length; i++) {
            if (deviceHistory[i].address === device.address) {
                exists = true
                // Update name if it changed
                if (deviceHistory[i].name !== device.name) {
                    deviceHistory[i].name = device.name
                }
                break
            }
        }

        // Add new device to history
        if (!exists) {
            deviceHistory.push({
                name: device.name,
                address: device.address
            })
            saveDeviceHistory(deviceHistory)
        }
    }

    // Helper function to update Bluetooth device list
    function updateBluetoothDevices() {
        var devices = []
        if (btManager.operational) {
            for (var i = 0; i < btManager.devices.length; i++) {
                var device = btManager.devices[i]
                // Only include connected devices with battery information
                if (device.connected && device.battery) {
                    var deviceName = device.name || device.alias || "Unknown Device"
                    var deviceInfo = {
                        name: deviceName,
                        address: device.address,
                        percentage: device.battery.percentage,
                        icon: getDeviceIcon(device, deviceName),
                        device: device
                    }
                    devices.push(deviceInfo)

                    // Update device history
                    updateDeviceHistory({
                        name: deviceName,
                        address: device.address
                    })
                }
            }
        }
        bluetoothDevices = devices
    }

    // Helper function to determine device icon based on device type
    function getDeviceIcon(device, deviceName) {
        // First, check custom icon mappings from configuration
        for (var i = 0; i < customIconMappings.length; i++) {
            var mapping = customIconMappings[i]
            if (deviceName.toLowerCase().includes(mapping.pattern.toLowerCase())) {
                console.log("Custom mapping matched for", deviceName, "->", mapping.icon)
                return mapping.icon
            }
        }

        // Fall back to automatic detection based on device icon property
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
        loadCustomMappings()
        loadDeviceHistory()
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
                    root.batteryLoading = false
                    root.isPCMode = false
                } else {
                    // Increment check attempts
                    if (root.batteryCheckAttempts < root.maxBatteryCheckAttempts) {
                        root.batteryCheckAttempts++
                    } else {
                        // After max attempts, we're definitely in PC mode
                        root.batteryLoading = false
                        root.isPCMode = true
                    }
                    root.hasBattery = false
                }

                root.batteryPercent = data["Percent"] || 0
                root.batteryState = data["State"] || ""

                // Get energy rate (power consumption/generation in watts)
                // Positive = discharging, Negative = charging
                root.energyRate = Math.abs(data["Energy Rate"] || 0)

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
                var hasBat = pmSource.data["Battery"]["Has Battery"] || false
                root.hasBattery = hasBat
                root.batteryPercent = pmSource.data["Battery"]["Percent"] || 0
                root.batteryState = pmSource.data["Battery"]["State"] || ""
                root.isBatterySaver = pmSource.data["Battery"]["Battery Save Mode"] || false
                root.energyRate = Math.abs(pmSource.data["Battery"]["Energy Rate"] || 0)

                // If initial load shows no battery, mark as loading
                if (!hasBat) {
                    root.batteryLoading = true
                } else {
                    root.batteryLoading = false
                }
            } else {
                root.batteryLoading = true
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

                // TOP LEFT - Main laptop battery circle (hidden in PC mode)
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 0
                    Layout.column: 0
                    visible: !root.isPCMode

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

                // BOTTOM RIGHT - Battery percentage or PC watts usage
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 1

                    // Battery percentage (laptop mode)
                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 2
                        anchors.bottomMargin: 2
                        text: root.batteryPercent + "%"
                        font.family: ndotFont.name
                        font.pixelSize: parent.width * 0.4
                        color: "#ffffff"
                        opacity: 0.95
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                        visible: root.hasBattery
                    }

                    // PC watts usage (PC mode with power data)
                    ColumnLayout {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 2
                        anchors.bottomMargin: 2
                        spacing: 0
                        visible: root.isPCMode && root.energyRate > 0

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: Math.round(root.energyRate) + "W"
                            font.family: ndotFont.name
                            font.pixelSize: parent.parent.width * 0.35
                            color: "#ffffff"
                            opacity: 0.95
                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: "PC"
                            font.family: ndotFont.name
                            font.pixelSize: parent.parent.width * 0.15
                            color: "#888888"
                            opacity: 0.8
                            horizontalAlignment: Text.AlignRight
                        }
                    }

                    // PC mode without power data
                    Text {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 2
                        anchors.bottomMargin: 2
                        text: "PC"
                        font.family: ndotFont.name
                        font.pixelSize: parent.width * 0.3
                        color: "#888888"
                        opacity: 0.8
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignBottom
                        visible: root.isPCMode && root.energyRate <= 0
                    }
                }
            }

            // Loading indicator
            Item {
                anchors.fill: parent
                visible: root.batteryLoading && !root.isPCMode

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        source: "battery"
                        color: "#666666"

                        // Simple rotation animation for loading
                        RotationAnimator on rotation {
                            from: 0
                            to: 360
                            duration: 2000
                            loops: Animation.Infinite
                            running: root.batteryLoading
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Detecting Battery..."
                        font.pixelSize: 14
                        color: "#888888"
                    }
                }
            }
        }
    }
}
