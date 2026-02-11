import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: nColors

    property int themeMode: 0  // 0=Dark, 1=Light, 2=Follow System

    readonly property bool useSystem: themeMode === 2
    readonly property bool isLight: themeMode === 1

    // Helper to access Kirigami theme text color components for derived colors
    readonly property color _kirigamiText: useSystem ? Kirigami.Theme.textColor : "transparent"
    readonly property real _frameContrast: 0.2

    // Core backgrounds
    readonly property color background: useSystem ? Kirigami.Theme.backgroundColor
                                      : isLight  ? "#f5f5f5" : "#1a1a1a"
    readonly property color surface:    useSystem ? Kirigami.Theme.alternateBackgroundColor
                                      : isLight  ? "#ffffff" : "#2a2a2a"

    // Text colors
    readonly property color textPrimary:     useSystem ? Kirigami.Theme.textColor
                                           : isLight  ? "#1a1a1a" : "#ffffff"
    readonly property color textSecondary:   useSystem ? Kirigami.Theme.disabledTextColor
                                           : isLight  ? "#666666" : "#aaaaaa"
    readonly property color textMuted:       useSystem ? Kirigami.Theme.disabledTextColor
                                           : isLight  ? "#777777" : "#888888"
    readonly property color textDisabled:    useSystem ? Kirigami.Theme.disabledTextColor
                                           : isLight  ? "#aaaaaa" : "#666666"
    readonly property color textPlaceholder: useSystem ? Kirigami.Theme.disabledTextColor
                                           : isLight  ? "#999999" : "#b0b0b0"

    // Accent colors
    readonly property color accent:          useSystem ? Kirigami.Theme.highlightColor
                                           : "#ff4444"
    readonly property color accentSecondHand: useSystem ? Kirigami.Theme.negativeTextColor
                                           : "#D71921"

    // Status colors
    readonly property color warning: useSystem ? Kirigami.Theme.neutralBackgroundColor
                                   : "#ffc107"
    readonly property color error:   useSystem ? Kirigami.Theme.negativeTextColor
                                   : "#d32f2f"

    // Structural colors
    readonly property color divider: useSystem ? Qt.rgba(_kirigamiText.r, _kirigamiText.g, _kirigamiText.b, _frameContrast)
                                   : isLight  ? "#dddddd" : "#333333"
    readonly property color pagePeel: useSystem ? Kirigami.Theme.alternateBackgroundColor
                                    : isLight  ? "#cccccc" : "#3a3a3a"

    // Indicators
    readonly property color indicatorActive:   useSystem ? Kirigami.Theme.textColor
                                             : isLight  ? "#1a1a1a" : "#ffffff"
    readonly property color indicatorInactive: useSystem ? Kirigami.Theme.disabledTextColor
                                             : isLight  ? "#aaaaaa" : "#666666"

    // Icons
    readonly property color iconColor: useSystem ? Kirigami.Theme.textColor
                                     : isLight  ? "#1a1a1a" : "#ffffff"

    // Borders
    readonly property color borderLight: useSystem ? Qt.rgba(_kirigamiText.r, _kirigamiText.g, _kirigamiText.b, 0.3)
                                       : isLight  ? "#cccccc" : "#e0e0e0"

    // Neutral
    readonly property color neutral: useSystem ? Kirigami.Theme.disabledTextColor
                                   : "#808080"

    // Surface variants (media player)
    readonly property color surfaceAlt:      useSystem ? Kirigami.Theme.backgroundColor
                                           : isLight  ? "#e8edf2" : "#0f1419"
    readonly property color surfaceGradient: useSystem ? Kirigami.Theme.alternateBackgroundColor
                                           : isLight  ? "#dce4ed" : "#1a2332"

    // Battery alpha fills
    readonly property color batteryBgFill:       useSystem ? Qt.rgba(_kirigamiText.r, _kirigamiText.g, _kirigamiText.b, 0.016)
                                               : isLight  ? "#0a000000" : "#04ffffff"
    readonly property color batteryProgressFill: useSystem ? Qt.rgba(_kirigamiText.r, _kirigamiText.g, _kirigamiText.b, 0.106)
                                               : isLight  ? "#1b000000" : "#1bffffff"
    readonly property color batteryRingFill:     useSystem ? Qt.rgba(_kirigamiText.r, _kirigamiText.g, _kirigamiText.b, 0.263)
                                               : isLight  ? "#43000000" : "#43ffffff"
}
