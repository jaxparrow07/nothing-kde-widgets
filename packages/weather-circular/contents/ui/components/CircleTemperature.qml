import QtQuick

// Reusable temperature display component
Item {
    id: root

    required property string temperature
    required property QtObject colors
    property bool isLoading: false
    property real textScale: 0.35

    Text {
        anchors.centerIn: parent
        text: temperature + "°"
        font.pixelSize: Math.min(parent.width * textScale, parent.height * textScale)
        font.weight: Font.Light
        color: root.colors.textPrimary
        opacity: isLoading ? 0.5 : 1.0
    }
}
