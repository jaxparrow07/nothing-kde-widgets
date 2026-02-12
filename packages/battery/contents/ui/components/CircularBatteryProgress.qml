import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Properties
    property int percentage: 75  // Battery percentage (0-100)
    property bool isCharging: false
    property bool isBatterySaver: false
    property string deviceType: "laptop"  // "laptop", "computer", "mouse", "headphones", "keyboard", "phone", "bluetooth"
    property string deviceIcon: ""  // Optional: override icon with specific icon name
    property bool isSystemDevice: true  // If false, don't show charging/battery saver indicators
    property int criticalThreshold: 20  // Battery percentage threshold for critical warning
    required property QtObject colors

    // Visual properties
    property color progressColor: '#43ffffff'
    property color backgroundColor: "transparent"
    property real lineWidth: 8

    // Calculated properties
    readonly property real centerX: width / 2
    readonly property real centerY: height / 2
    readonly property real radius: Math.min(width, height) / 2

    // Main circular progress (filled pie chart)
    Canvas {
        id: progressCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // Draw background circle (full circle, filled)
            ctx.beginPath()
            ctx.arc(root.centerX, root.centerY, root.radius, 0, 2 * Math.PI)
            ctx.fillStyle = root.colors.batteryBgFill
            ctx.fill()

            // Draw progress pie (from top, clockwise, filled)
            if (root.percentage > 0) {
                ctx.beginPath()
                ctx.moveTo(root.centerX, root.centerY)  // Move to center for pie chart
                var startAngle = -Math.PI / 2  // Start at top (12 o'clock)
                var endAngle = startAngle + (root.percentage / 100 * 2 * Math.PI)
                ctx.arc(root.centerX, root.centerY, root.radius, startAngle, endAngle)
                ctx.closePath()
                // Use red color for critical battery level, otherwise white
                ctx.fillStyle = root.percentage <= root.criticalThreshold ? root.colors.accent : root.colors.batteryProgressFill
                ctx.fill()
            }
        }

        // Repaint when percentage changes
        Connections {
            target: root
            function onPercentageChanged() { progressCanvas.requestPaint() }
        }

        Connections {
            target: root.colors
            function onBatteryBgFillChanged() { progressCanvas.requestPaint() }
            function onBatteryProgressFillChanged() { progressCanvas.requestPaint() }
            function onAccentChanged() { progressCanvas.requestPaint() }
        }
    }

    // Centered content: device icon and status indicator
    Item {
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.6

        // Device icon container with proper positioning
        Item {
            id: deviceIconContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.75
            height: parent.height * 0.75

            // Calculate Y position properly to avoid overflow
            readonly property bool hasStatusIndicator: root.isSystemDevice && (root.isCharging || root.isBatterySaver)
            y: hasStatusIndicator ? 0 : (parent.height - height) / 2

            // Device icon
            Kirigami.Icon {
                id: deviceIconImage
                anchors.fill: parent
                source: {
                    // Use custom icon if provided (for Bluetooth devices)
                    if (root.deviceIcon !== "") {
                        return Qt.resolvedUrl("../../device-icons/" + root.deviceIcon + ".svg")
                    }

                    // Otherwise map deviceType to local icon
                    switch (root.deviceType) {
                        case "laptop":
                            return Qt.resolvedUrl("../../device-icons/laptop.svg")
                        case "computer":
                            return Qt.resolvedUrl("../../device-icons/computer.svg")
                        case "mouse":
                            return Qt.resolvedUrl("../../device-icons/mouse.svg")
                        case "headphones":
                        case "audio-headset":
                            return Qt.resolvedUrl("../../device-icons/headset.svg")
                        case "keyboard":
                            return Qt.resolvedUrl("../../device-icons/keyboard.svg")
                        default:
                            return "network-bluetooth"
                    }
                }
                color: root.colors.iconColor
                isMask: true
                opacity: 0.9
            }
        }

        // Status indicator (small circle below, stays within bounds)
        // Only shown for system devices (laptop/computer)
        Item {
            id: statusIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: deviceIconContainer.bottom
            anchors.topMargin: parent.height * 0.05
            width: Math.min(parent.width, parent.height) * 0.5
            height: Math.min(parent.width, parent.height) * 0.5
            visible: root.isSystemDevice && (root.isCharging || root.isBatterySaver)

            // Background circle
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: root.isCharging ? root.colors.accent : root.colors.warning
                opacity: 0.95
            }

            // Status icon
            Item {
                anchors.centerIn: parent
                width: parent.width * 0.75
                height: parent.height * 0.75

                // Custom SVG for charging, Kirigami icon for battery saver
                Kirigami.Icon {
                    anchors.fill: parent
                    source: root.isCharging ? Qt.resolvedUrl("../../icons/charging_mode.svg") : ""
                    color: root.colors.background
                    isMask: true
                    visible: root.isCharging
                }

                Kirigami.Icon {
                    anchors.fill: parent
                    source: "list-add"
                    color: root.colors.background
                    visible: root.isBatterySaver && !root.isCharging
                    isMask: true
                }
            }
        }
    }
}
