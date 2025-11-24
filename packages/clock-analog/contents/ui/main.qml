import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property real milliseconds: 0
    property int clockStyle: plasmoid.configuration.clockStyle
    property bool smoothHands: plasmoid.configuration.smoothHands

    Timer {
        interval: root.smoothHands ? 50 : 1000
        running: true
        repeat: true
        onTriggered: {
            var currentTime = new Date()
            root.hours = currentTime.getHours() % 12
            root.minutes = currentTime.getMinutes()
            root.seconds = currentTime.getSeconds()
            root.milliseconds = root.smoothHands ? currentTime.getMilliseconds() : 0
        }
        Component.onCompleted: triggered()
    }

    compactRepresentation: Item {
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: Qt.formatTime(new Date(), "hh:mm")
            font.pixelSize: parent.height * 0.4
            font.bold: true
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200

        // Analog Clock
        Item {
            id: clockContainer
            anchors.fill: parent
            anchors.margins: 10
            property real clockRadius: Math.min(width, height) / 2
            property real centerX: width / 2
            property real centerY: height / 2

            // Clock face background
            Canvas {
                id: clockFace
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2

                    ctx.reset()

                    // Draw dark background circle
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                    ctx.fillStyle = "#f21a1a1a"
                    ctx.fill()

                    // Only draw markers for Swiss Railway style (clockStyle === 0)
                    if (root.clockStyle === 0) {
                        // Draw hour markers
                        ctx.save()
                        ctx.translate(centerX, centerY)

                        for (var i = 0; i < 60; i++) {
                            ctx.save()
                            ctx.rotate(i * Math.PI / 30) // Rotate for each marker

                            ctx.beginPath()

                            var markerStart = radius * 0.92 // Same outer position for all markers

                            if (i % 5 === 0) {
                                // Hour markers - shortened by 20%, thickened by 30%, all same size
                                var markerLength = radius * 0.12  // 0.15 * 0.8 = 0.12 (20% shorter)
                                var markerWidth = radius * 0.026  // 0.02 * 1.3 = 0.026 (30% thicker)

                                ctx.rect(-markerWidth / 2, -markerStart, markerWidth, markerLength)
                                ctx.fillStyle = "#ffffff"
                                ctx.fill()
                            } else {
                                // Minute markers - smaller and thinner lines
                                var minuteMarkerLength = radius * 0.05
                                var minuteMarkerWidth = radius * 0.008

                                ctx.rect(-minuteMarkerWidth / 2, -markerStart, minuteMarkerWidth, minuteMarkerLength)
                                ctx.fillStyle = "#ffffff"
                                ctx.fill()
                            }

                            ctx.restore()
                        }

                        ctx.restore()
                    }
                }

                Connections {
                    target: root
                    function onClockStyleChanged() {
                        clockFace.requestPaint()
                    }
                }
            }

            // Hour hand
            Canvas {
                id: hourHand
                anchors.fill: parent
                rotation: (root.hours * 30) + (root.minutes * 0.5)

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2
                    var handLength = radius * 0.5
                    var handWidth = radius * 0.025  // Same thickness as minute hand
                    var counterWeight = radius * 0.12  // Protrude 12% past center

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    if (root.clockStyle === 0) {
                        // Swiss Railway: sharp rectangular edges, protruding past center
                        ctx.beginPath()
                        ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                        ctx.fillStyle = "#ffffff"
                        ctx.fill()
                    } else {
                        // Minimalist: rounded pill shape with 8% past pivot
                        ctx.beginPath()
                        var pillWidth = radius * 0.2  // Thicker hour hand
                        var pillLength = radius * 0.6
                        var pillCounterWeight = radius * 0.08  // 8% past pivot
                        var roundRadius = pillWidth / 2

                        // Draw pill from top (negative direction) to bottom (counterweight)
                        ctx.moveTo(-pillWidth / 2, -pillLength + roundRadius)
                        ctx.arc(-pillWidth / 2 + roundRadius, -pillLength + roundRadius, roundRadius, Math.PI, Math.PI * 1.5, false)
                        ctx.lineTo(pillWidth / 2 - roundRadius, -pillLength)
                        ctx.arc(pillWidth / 2 - roundRadius, -pillLength + roundRadius, roundRadius, Math.PI * 1.5, 0, false)
                        ctx.lineTo(pillWidth / 2, pillCounterWeight - roundRadius)
                        ctx.arc(pillWidth / 2 - roundRadius, pillCounterWeight - roundRadius, roundRadius, 0, Math.PI * 0.5, false)
                        ctx.lineTo(-pillWidth / 2 + roundRadius, pillCounterWeight)
                        ctx.arc(-pillWidth / 2 + roundRadius, pillCounterWeight - roundRadius, roundRadius, Math.PI * 0.5, Math.PI, false)
                        ctx.closePath()
                        ctx.fillStyle = "#e0e0e0"
                        ctx.fill()

                        // Add subtle shadow/depth
                        ctx.shadowColor = "rgba(0, 0, 0, 0.3)"
                        ctx.shadowBlur = radius * 0.02
                        ctx.shadowOffsetX = radius * 0.01
                        ctx.shadowOffsetY = radius * 0.01
                        ctx.fill()
                    }

                    ctx.restore()
                }

                Behavior on rotation {
                    RotationAnimation {
                        duration: 300
                        direction: RotationAnimation.Clockwise
                    }
                }

                Connections {
                    target: root
                    function onClockStyleChanged() {
                        hourHand.requestPaint()
                    }
                }
            }

            // Minute hand
            Canvas {
                id: minuteHand
                anchors.fill: parent
                rotation: root.minutes * 6 + root.seconds * 0.1

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2
                    var handLength = radius * 0.675  // 0.75 * 0.9 = 0.675 (10% shorter)
                    var handWidth = radius * 0.025  // Same thickness as hour hand
                    var counterWeight = radius * 0.12  // Protrude 12% past center

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    if (root.clockStyle === 0) {
                        // Swiss Railway: sharp rectangular edges, protruding past center
                        ctx.beginPath()
                        ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                        ctx.fillStyle = "#ffffff"
                        ctx.fill()
                    } else {
                        // Minimalist: thinner rounded pill shape
                        ctx.beginPath()
                        var pillWidth = radius * 0.055  // Thicker minute hand (but still thinner than hour)
                        var pillLength = radius * 0.70  // Longer than hour hand
                        var pillCounterWeight = 0  // Smaller counterweight
                        var roundRadius = pillWidth / 2

                        // Draw pill from top (negative direction) to bottom (counterweight)
                        ctx.moveTo(-pillWidth / 2, -pillLength + roundRadius)
                        ctx.arc(-pillWidth / 2 + roundRadius, -pillLength + roundRadius, roundRadius, Math.PI, Math.PI * 1.5, false)
                        ctx.lineTo(pillWidth / 2 - roundRadius, -pillLength)
                        ctx.arc(pillWidth / 2 - roundRadius, -pillLength + roundRadius, roundRadius, Math.PI * 1.5, 0, false)
                        ctx.lineTo(pillWidth / 2, pillCounterWeight - roundRadius)
                        ctx.arc(pillWidth / 2 - roundRadius, pillCounterWeight - roundRadius, roundRadius, 0, Math.PI * 0.5, false)
                        ctx.lineTo(-pillWidth / 2 + roundRadius, pillCounterWeight)
                        ctx.arc(-pillWidth / 2 + roundRadius, pillCounterWeight - roundRadius, roundRadius, Math.PI * 0.5, Math.PI, false)
                        ctx.closePath()
                        ctx.fillStyle = "#808080"
                        ctx.fill()

                        // Add subtle shadow/depth
                        ctx.shadowColor = "rgba(0, 0, 0, 0.3)"
                        ctx.shadowBlur = radius * 0.015
                        ctx.shadowOffsetX = radius * 0.008
                        ctx.shadowOffsetY = radius * 0.008
                        ctx.fill()
                    }

                    ctx.restore()
                }

                Behavior on rotation {
                    RotationAnimation {
                        duration: 300
                        direction: RotationAnimation.Clockwise
                    }
                }

                Connections {
                    target: root
                    function onClockStyleChanged() {
                        minuteHand.requestPaint()
                    }
                }
            }

            // Pivot dots for all hands (Swiss Railway only)
            Canvas {
                id: pivotDots
                anchors.fill: parent
                z: 10
                visible: root.clockStyle === 0

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    // White pivot dot for hour and minute hands
                    ctx.beginPath()
                    ctx.arc(0, 0, radius * 0.06, 0, 2 * Math.PI)
                    ctx.fillStyle = "#ffffff"
                    ctx.fill()

                    ctx.restore()
                }
            }

            Canvas {
                id: secondPivotDot
                anchors.fill: parent
                z: 10
                visible: root.clockStyle === 0

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    // Red pivot dot for second hand
                    ctx.beginPath()
                    ctx.arc(0, 0, radius * 0.035, 0, 2 * Math.PI)
                    ctx.fillStyle = "#D71921"
                    ctx.fill()

                    ctx.restore()
                }
            }

            // Second hand
            Canvas {
                id: secondHand
                anchors.fill: parent
                rotation: root.seconds * 6 + (root.milliseconds / 1000) * 6
                z: 15
                visible: root.clockStyle === 0

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2
                    var handLength = radius * 0.80
                    var counterWeight = radius * 0.15
                    var handWidth = radius * 0.012
                    var endDotRadius = radius * 0.05

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    // Draw second hand with sharp rectangular edges
                    ctx.beginPath()
                    ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                    ctx.fillStyle = "#D71921"
                    ctx.fill()

                    // Draw circular dot at 80% of second hand length
                    ctx.beginPath()
                    ctx.arc(0, -handLength * 0.75, endDotRadius, 0, 2 * Math.PI)
                    ctx.fillStyle = "#D71921"
                    ctx.fill()

                    ctx.restore()
                }

                Behavior on rotation {
                    RotationAnimation {
                        duration: 50
                        direction: RotationAnimation.Clockwise
                    }
                }
            }

            // Minimalist second hand (red dot moving on perimeter)
            Canvas {
                id: minimalistSecondHand
                anchors.fill: parent
                rotation: root.seconds * 6 + (root.milliseconds / 1000) * 6
                z: 15
                visible: root.clockStyle === 1

                onPaint: {
                    var ctx = getContext("2d")
                    var centerX = width / 2
                    var centerY = height / 2
                    var radius = Math.min(width, height) / 2
                    var dotRadius = radius * 0.045  // Small red dot
                    var dotDistance = radius * 0.88  // Distance from center to dot

                    ctx.reset()
                    ctx.save()
                    ctx.translate(centerX, centerY)

                    // Draw red dot on perimeter
                    ctx.beginPath()
                    ctx.arc(0, -dotDistance, dotRadius, 0, 2 * Math.PI)
                    ctx.fillStyle = "#D71921"
                    ctx.fill()

                    ctx.restore()
                }

                Behavior on rotation {
                    RotationAnimation {
                        duration: 50
                        direction: RotationAnimation.Clockwise
                    }
                }

                Connections {
                    target: root
                    function onClockStyleChanged() {
                        minimalistSecondHand.requestPaint()
                    }
                }
            }

        }
    }
}
