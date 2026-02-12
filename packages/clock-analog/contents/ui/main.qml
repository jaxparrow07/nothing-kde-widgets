import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "components"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

    // --- Variant selection ---
    property int widgetVariant: plasmoid.configuration.widgetVariant
    readonly property bool variantChosen: widgetVariant >= 0

    // Map widgetVariant to clockStyle for rendering (0=Swiss, 1=Minimalist)
    readonly property int clockStyle: variantChosen ? widgetVariant : 0

    property int hours: 0
    property int minutes: 0
    property int seconds: 0
    property real milliseconds: 0
    property bool smoothHands: plasmoid.configuration.smoothHands

    Timer {
        interval: root.smoothHands ? 50 : 1000
        running: root.variantChosen
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

    fullRepresentation: Loader {
        id: fullLoader

        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200

        sourceComponent: root.variantChosen ? clockComponent : selectorComponent
    }

    Component {
        id: selectorComponent
        VariantSelector {
            colors: nColors
        }
    }

    Component {
        id: clockComponent
        Item {
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
                        ctx.fillStyle = Qt.rgba(nColors.background.r, nColors.background.g, nColors.background.b, 0.95)
                        ctx.fill()

                        // Only draw markers for Swiss Railway style (clockStyle === 0)
                        if (root.clockStyle === 0) {
                            // Draw hour markers
                            ctx.save()
                            ctx.translate(centerX, centerY)

                            for (var i = 0; i < 60; i++) {
                                ctx.save()
                                ctx.rotate(i * Math.PI / 30)

                                ctx.beginPath()

                                var markerStart = radius * 0.92

                                if (i % 5 === 0) {
                                    var markerLength = radius * 0.12
                                    var markerWidth = radius * 0.026

                                    ctx.rect(-markerWidth / 2, -markerStart, markerWidth, markerLength)
                                    ctx.fillStyle = nColors.textPrimary
                                    ctx.fill()
                                } else {
                                    var minuteMarkerLength = radius * 0.05
                                    var minuteMarkerWidth = radius * 0.008

                                    ctx.rect(-minuteMarkerWidth / 2, -markerStart, minuteMarkerWidth, minuteMarkerLength)
                                    ctx.fillStyle = nColors.textPrimary
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
                        var handWidth = radius * 0.025
                        var counterWeight = radius * 0.12

                        ctx.reset()
                        ctx.save()
                        ctx.translate(centerX, centerY)

                        if (root.clockStyle === 0) {
                            ctx.beginPath()
                            ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                            ctx.fillStyle = nColors.textPrimary
                            ctx.fill()
                        } else {
                            ctx.beginPath()
                            var pillWidth = radius * 0.2
                            var pillLength = radius * 0.6
                            var pillCounterWeight = radius * 0.08
                            var roundRadius = pillWidth / 2

                            ctx.moveTo(-pillWidth / 2, -pillLength + roundRadius)
                            ctx.arc(-pillWidth / 2 + roundRadius, -pillLength + roundRadius, roundRadius, Math.PI, Math.PI * 1.5, false)
                            ctx.lineTo(pillWidth / 2 - roundRadius, -pillLength)
                            ctx.arc(pillWidth / 2 - roundRadius, -pillLength + roundRadius, roundRadius, Math.PI * 1.5, 0, false)
                            ctx.lineTo(pillWidth / 2, pillCounterWeight - roundRadius)
                            ctx.arc(pillWidth / 2 - roundRadius, pillCounterWeight - roundRadius, roundRadius, 0, Math.PI * 0.5, false)
                            ctx.lineTo(-pillWidth / 2 + roundRadius, pillCounterWeight)
                            ctx.arc(-pillWidth / 2 + roundRadius, pillCounterWeight - roundRadius, roundRadius, Math.PI * 0.5, Math.PI, false)
                            ctx.closePath()
                            ctx.fillStyle = nColors.borderLight
                            ctx.fill()

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
                        var handLength = radius * 0.675
                        var handWidth = radius * 0.025
                        var counterWeight = radius * 0.12

                        ctx.reset()
                        ctx.save()
                        ctx.translate(centerX, centerY)

                        if (root.clockStyle === 0) {
                            ctx.beginPath()
                            ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                            ctx.fillStyle = nColors.textPrimary
                            ctx.fill()
                        } else {
                            ctx.beginPath()
                            var pillWidth = radius * 0.055
                            var pillLength = radius * 0.70
                            var pillCounterWeight = 0
                            var roundRadius = pillWidth / 2

                            ctx.moveTo(-pillWidth / 2, -pillLength + roundRadius)
                            ctx.arc(-pillWidth / 2 + roundRadius, -pillLength + roundRadius, roundRadius, Math.PI, Math.PI * 1.5, false)
                            ctx.lineTo(pillWidth / 2 - roundRadius, -pillLength)
                            ctx.arc(pillWidth / 2 - roundRadius, -pillLength + roundRadius, roundRadius, Math.PI * 1.5, 0, false)
                            ctx.lineTo(pillWidth / 2, pillCounterWeight - roundRadius)
                            ctx.arc(pillWidth / 2 - roundRadius, pillCounterWeight - roundRadius, roundRadius, 0, Math.PI * 0.5, false)
                            ctx.lineTo(-pillWidth / 2 + roundRadius, pillCounterWeight)
                            ctx.arc(-pillWidth / 2 + roundRadius, pillCounterWeight - roundRadius, roundRadius, Math.PI * 0.5, Math.PI, false)
                            ctx.closePath()
                            ctx.fillStyle = nColors.neutral
                            ctx.fill()

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

                        ctx.beginPath()
                        ctx.arc(0, 0, radius * 0.06, 0, 2 * Math.PI)
                        ctx.fillStyle = nColors.textPrimary
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

                        ctx.beginPath()
                        ctx.arc(0, 0, radius * 0.035, 0, 2 * Math.PI)
                        ctx.fillStyle = nColors.accentSecondHand
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

                        ctx.beginPath()
                        ctx.rect(-handWidth / 2, -handLength, handWidth, handLength + counterWeight)
                        ctx.fillStyle = nColors.accentSecondHand
                        ctx.fill()

                        ctx.beginPath()
                        ctx.arc(0, -handLength * 0.75, endDotRadius, 0, 2 * Math.PI)
                        ctx.fillStyle = nColors.accentSecondHand
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
                        var dotRadius = radius * 0.045
                        var dotDistance = radius * 0.88

                        ctx.reset()
                        ctx.save()
                        ctx.translate(centerX, centerY)

                        ctx.beginPath()
                        ctx.arc(0, -dotDistance, dotRadius, 0, 2 * Math.PI)
                        ctx.fillStyle = nColors.accentSecondHand
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

                Connections {
                    target: nColors
                    function onBackgroundChanged() { clockFace.requestPaint() }
                    function onTextPrimaryChanged() {
                        clockFace.requestPaint()
                        hourHand.requestPaint()
                        minuteHand.requestPaint()
                        pivotDots.requestPaint()
                    }
                    function onAccentSecondHandChanged() {
                        secondHand.requestPaint()
                        secondPivotDot.requestPaint()
                        minimalistSecondHand.requestPaint()
                    }
                    function onBorderLightChanged() { hourHand.requestPaint() }
                    function onNeutralChanged() { minuteHand.requestPaint() }
                }
            }
        }
    }
}
