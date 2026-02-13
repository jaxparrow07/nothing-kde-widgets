import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: nColors

    property int themeMode: 0  // 0=Dark, 1=Light, 2=Follow System
    property bool useSystemAccent: false

    readonly property bool useSystem: themeMode === 2
    readonly property bool systemIsDark: {
        var bg = Kirigami.Theme.backgroundColor
        var luminance = 0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b
        return luminance < 0.5
    }
    readonly property bool isLight: themeMode === 1 || (useSystem && !systemIsDark)

    // Core backgrounds
    readonly property color background: isLight ? "#f5f5f5" : "#1a1a1a"
    readonly property color surface:    isLight ? "#ffffff" : "#2a2a2a"

    // Text colors
    readonly property color textPrimary:     isLight ? "#1a1a1a" : "#ffffff"
    readonly property color textSecondary:   isLight ? "#666666" : "#aaaaaa"
    readonly property color textMuted:       isLight ? "#777777" : "#888888"
    readonly property color textDisabled:    isLight ? "#aaaaaa" : "#666666"
    readonly property color textPlaceholder: isLight ? "#999999" : "#b0b0b0"

    // Accent colors
    readonly property color accent:          useSystemAccent ? Kirigami.Theme.highlightColor
                                           : "#ff4444"
    readonly property color accentSecondHand: useSystemAccent ? Kirigami.Theme.highlightColor
                                           : "#D71921"

    // Status colors
    readonly property color warning: "#ffc107"
    readonly property color error:   "#d32f2f"

    // Structural colors
    readonly property color divider:  isLight ? "#dddddd" : "#333333"
    readonly property color pagePeel: isLight ? "#cccccc" : "#3a3a3a"

    // Indicators
    readonly property color indicatorActive:   isLight ? "#1a1a1a" : "#ffffff"
    readonly property color indicatorInactive: isLight ? "#aaaaaa" : "#666666"

    // Icons
    readonly property color iconColor: isLight ? "#1a1a1a" : "#ffffff"

    // Borders
    readonly property color borderLight: isLight ? "#cccccc" : "#e0e0e0"

    // Neutral
    readonly property color neutral: "#808080"

    // Surface variants (media player)
    readonly property color surfaceAlt:      isLight ? "#e8edf2" : "#0f1419"
    readonly property color surfaceGradient: isLight ? "#dce4ed" : "#1a2332"

    // Battery alpha fills
    readonly property color batteryBgFill:       isLight ? "#0a000000" : "#04ffffff"
    readonly property color batteryProgressFill: isLight ? "#1b000000" : "#1bffffff"
    readonly property color batteryRingFill:     isLight ? "#43000000" : "#43ffffff"
}
