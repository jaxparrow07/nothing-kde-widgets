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

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

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

    // A real battery won't report 0% while charging — that's a PC without a real battery
    readonly property bool showMainBattery: root.hasBattery && !(root.batteryPercent === 0 && root.isCharging)
    // Total number of circles to show in compact view
    readonly property int compactCircleCount: (showMainBattery ? 1 : 0) + root.bluetoothDevices.length
    // Hide compact view entirely if nothing to show
    readonly property bool compactVisible: compactCircleCount > 0

    compactRepresentation: Item {
        id: compactItem

        visible: root.compactVisible

        readonly property real cellSize: Math.min(width / Math.max(root.compactCircleCount, 1), height)
        readonly property real ringSize: cellSize - 4
        readonly property real ringWidth: ringSize * 0.12

        states: [
            State {
                name: "horizontalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

                PropertyChanges {
                    compactItem.Layout.fillHeight: true
                    compactItem.Layout.fillWidth: false
                    compactItem.Layout.minimumWidth: compactItem.height * root.compactCircleCount
                    compactItem.Layout.maximumWidth: compactItem.Layout.minimumWidth
                }
            },
            State {
                name: "verticalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.fillHeight: false
                    compactItem.Layout.fillWidth: true
                    compactItem.Layout.minimumHeight: compactItem.width * root.compactCircleCount
                    compactItem.Layout.maximumHeight: compactItem.Layout.minimumHeight
                }
            },
            State {
                name: "desktop"
                when: Plasmoid.formFactor !== PlasmaCore.Types.Horizontal && Plasmoid.formFactor !== PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.minimumWidth: 24 * root.compactCircleCount
                    compactItem.Layout.minimumHeight: 24
                }
            }
        ]

        Row {
            anchors.centerIn: parent
            spacing: 0

            // Main battery circle (only if battery is available)
            Item {
                width: compactItem.cellSize
                height: compactItem.cellSize
                visible: root.showMainBattery

                Canvas {
                    id: compactMainRing
                    anchors.centerIn: parent
                    width: compactItem.ringSize
                    height: compactItem.ringSize

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var centerX = width / 2
                        var centerY = height / 2
                        var radius = (Math.min(width, height) - compactItem.ringWidth) / 2
                        var startAngle = -Math.PI / 2
                        var endAngle = startAngle + (2 * Math.PI * root.batteryPercent / 100)

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                        ctx.strokeStyle = nColors.batteryBgFill
                        ctx.lineWidth = compactItem.ringWidth
                        ctx.stroke()

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                        ctx.strokeStyle = root.batteryPercent <= 20 ? nColors.accent : nColors.batteryRingFill
                        ctx.lineWidth = compactItem.ringWidth
                        ctx.lineCap = "round"
                        ctx.stroke()
                    }

                    Connections {
                        target: root
                        function onBatteryPercentChanged() { compactMainRing.requestPaint() }
                    }
                    Connections {
                        target: nColors
                        function onBatteryRingFillChanged() { compactMainRing.requestPaint() }
                        function onBatteryBgFillChanged() { compactMainRing.requestPaint() }
                        function onAccentChanged() { compactMainRing.requestPaint() }
                    }
                }

                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: compactItem.ringSize * 0.45
                    height: compactItem.ringSize * 0.45
                    source: "battery"
                    color: nColors.iconColor
                    isMask: true
                }
            }

            // Bluetooth device circles
            Repeater {
                model: root.bluetoothDevices.length

                Item {
                    width: compactItem.cellSize
                    height: compactItem.cellSize

                    readonly property int btPercent: root.bluetoothDevices[index] ? root.bluetoothDevices[index].percentage : 0
                    readonly property string btIcon: root.bluetoothDevices[index] ? root.bluetoothDevices[index].icon : ""

                    Canvas {
                        id: btRing
                        anchors.centerIn: parent
                        width: compactItem.ringSize
                        height: compactItem.ringSize

                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.reset()
                            var centerX = width / 2
                            var centerY = height / 2
                            var radius = (Math.min(width, height) - compactItem.ringWidth) / 2
                            var startAngle = -Math.PI / 2
                            var pct = parent.btPercent
                            var endAngle = startAngle + (2 * Math.PI * pct / 100)

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = nColors.batteryBgFill
                            ctx.lineWidth = compactItem.ringWidth
                            ctx.stroke()

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                            ctx.strokeStyle = pct <= 20 ? nColors.accent : nColors.batteryRingFill
                            ctx.lineWidth = compactItem.ringWidth
                            ctx.lineCap = "round"
                            ctx.stroke()
                        }

                        Connections {
                            target: root
                            function onBluetoothDevicesChanged() { btRing.requestPaint() }
                        }
                        Connections {
                            target: nColors
                            function onBatteryRingFillChanged() { btRing.requestPaint() }
                            function onBatteryBgFillChanged() { btRing.requestPaint() }
                            function onAccentChanged() { btRing.requestPaint() }
                        }
                    }

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: compactItem.ringSize * 0.45
                        height: compactItem.ringSize * 0.45
                        source: {
                            if (parent.btIcon !== "") {
                                return Qt.resolvedUrl("../device-icons/" + parent.btIcon + ".svg")
                            }
                            return "network-bluetooth"
                        }
                        color: nColors.iconColor
                        isMask: true
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
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
            color: nColors.background
            radius: 20
            opacity: 0.95

            // Build a flat device list: main battery (if present) + BT devices
            // Devices flow into a 2x2 grid: top-left, top-right, bottom-left, bottom-right
            readonly property int deviceCount: (root.showMainBattery ? 1 : 0) + root.bluetoothDevices.length
            readonly property real cellWidth: (width - 40) / 2
            readonly property real cellHeight: (height - 40) / 2

            // Helper to get device info by slot index
            function slotDevice(slot) {
                // slot 0..3 maps to the flat list: main battery first, then BT devices
                var mainOffset = root.showMainBattery ? 1 : 0
                if (slot === 0 && root.showMainBattery) {
                    return { type: "main" }
                }
                var btIndex = slot - mainOffset
                if (btIndex >= 0 && btIndex < root.bluetoothDevices.length) {
                    return { type: "bt", index: btIndex }
                }
                return null
            }

            // Grid positions
            readonly property var gridPositions: [
                { x: 15, y: 15 },                              // top-left
                { x: 15 + cellWidth + 10, y: 15 },             // top-right
                { x: 15, y: 15 + cellHeight + 10 },            // bottom-left
                { x: 15 + cellWidth + 10, y: 15 + cellHeight + 10 } // bottom-right
            ]

            // Slot 0 - top left
            Item {
                x: mainBackground.gridPositions[0].x
                y: mainBackground.gridPositions[0].y
                width: mainBackground.cellWidth
                height: mainBackground.cellHeight
                visible: mainBackground.deviceCount > 0

                CircularBatteryProgress {
                    anchors.fill: parent
                    percentage: {
                        var dev = mainBackground.slotDevice(0)
                        if (!dev) return 0
                        if (dev.type === "main") return root.batteryPercent
                        return root.bluetoothDevices[dev.index].percentage
                    }
                    isCharging: {
                        var dev = mainBackground.slotDevice(0)
                        return dev && dev.type === "main" ? root.isCharging : false
                    }
                    isBatterySaver: {
                        var dev = mainBackground.slotDevice(0)
                        return dev && dev.type === "main" ? root.isBatterySaver : false
                    }
                    deviceType: {
                        var dev = mainBackground.slotDevice(0)
                        return dev && dev.type === "main" ? "laptop" : ""
                    }
                    deviceIcon: {
                        var dev = mainBackground.slotDevice(0)
                        if (!dev || dev.type === "main") return ""
                        return root.bluetoothDevices[dev.index].icon
                    }
                    isSystemDevice: {
                        var dev = mainBackground.slotDevice(0)
                        return dev ? dev.type === "main" : false
                    }
                    colors: nColors
                }
            }

            // Slot 1 - top right
            Item {
                x: mainBackground.gridPositions[1].x
                y: mainBackground.gridPositions[1].y
                width: mainBackground.cellWidth
                height: mainBackground.cellHeight
                visible: mainBackground.deviceCount > 1

                CircularBatteryProgress {
                    anchors.fill: parent
                    percentage: {
                        var dev = mainBackground.slotDevice(1)
                        if (!dev) return 0
                        if (dev.type === "main") return root.batteryPercent
                        return root.bluetoothDevices[dev.index].percentage
                    }
                    isCharging: {
                        var dev = mainBackground.slotDevice(1)
                        return dev && dev.type === "main" ? root.isCharging : false
                    }
                    isBatterySaver: {
                        var dev = mainBackground.slotDevice(1)
                        return dev && dev.type === "main" ? root.isBatterySaver : false
                    }
                    deviceType: {
                        var dev = mainBackground.slotDevice(1)
                        return dev && dev.type === "main" ? "laptop" : ""
                    }
                    deviceIcon: {
                        var dev = mainBackground.slotDevice(1)
                        if (!dev || dev.type === "main") return ""
                        return root.bluetoothDevices[dev.index].icon
                    }
                    isSystemDevice: {
                        var dev = mainBackground.slotDevice(1)
                        return dev ? dev.type === "main" : false
                    }
                    colors: nColors
                }
            }

            // Slot 2 - bottom left
            Item {
                x: mainBackground.gridPositions[2].x
                y: mainBackground.gridPositions[2].y
                width: mainBackground.cellWidth
                height: mainBackground.cellHeight
                visible: mainBackground.deviceCount > 2

                CircularBatteryProgress {
                    anchors.fill: parent
                    percentage: {
                        var dev = mainBackground.slotDevice(2)
                        if (!dev) return 0
                        if (dev.type === "main") return root.batteryPercent
                        return root.bluetoothDevices[dev.index].percentage
                    }
                    isCharging: {
                        var dev = mainBackground.slotDevice(2)
                        return dev && dev.type === "main" ? root.isCharging : false
                    }
                    isBatterySaver: {
                        var dev = mainBackground.slotDevice(2)
                        return dev && dev.type === "main" ? root.isBatterySaver : false
                    }
                    deviceType: {
                        var dev = mainBackground.slotDevice(2)
                        return dev && dev.type === "main" ? "laptop" : ""
                    }
                    deviceIcon: {
                        var dev = mainBackground.slotDevice(2)
                        if (!dev || dev.type === "main") return ""
                        return root.bluetoothDevices[dev.index].icon
                    }
                    isSystemDevice: {
                        var dev = mainBackground.slotDevice(2)
                        return dev ? dev.type === "main" : false
                    }
                    colors: nColors
                }
            }

            // Slot 3 - bottom right
            Item {
                x: mainBackground.gridPositions[3].x
                y: mainBackground.gridPositions[3].y
                width: mainBackground.cellWidth
                height: mainBackground.cellHeight
                visible: mainBackground.deviceCount > 3

                CircularBatteryProgress {
                    anchors.fill: parent
                    percentage: {
                        var dev = mainBackground.slotDevice(3)
                        if (!dev) return 0
                        if (dev.type === "main") return root.batteryPercent
                        return root.bluetoothDevices[dev.index].percentage
                    }
                    isCharging: {
                        var dev = mainBackground.slotDevice(3)
                        return dev && dev.type === "main" ? root.isCharging : false
                    }
                    isBatterySaver: {
                        var dev = mainBackground.slotDevice(3)
                        return dev && dev.type === "main" ? root.isBatterySaver : false
                    }
                    deviceType: {
                        var dev = mainBackground.slotDevice(3)
                        return dev && dev.type === "main" ? "laptop" : ""
                    }
                    deviceIcon: {
                        var dev = mainBackground.slotDevice(3)
                        if (!dev || dev.type === "main") return ""
                        return root.bluetoothDevices[dev.index].icon
                    }
                    isSystemDevice: {
                        var dev = mainBackground.slotDevice(3)
                        return dev ? dev.type === "main" : false
                    }
                    colors: nColors
                }
            }

            // PC label (small, bottom-right corner) - only when detected as PC
            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 20
                anchors.bottomMargin: 20
                text: "PC"
                font.family: ndotFont.name
                font.pixelSize: 17
                color: nColors.textPrimary
                opacity: 0.6
                visible: !root.showMainBattery && root.hasBattery
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
                        color: nColors.textPrimary
                        opacity: 0.5

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
                        font.pixelSize: 17
                        color: nColors.textPrimary
                        opacity: 0.7
                    }
                }
            }
        }
    }
}
