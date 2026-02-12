import QtQuick
import org.kde.kirigami as Kirigami

// Reusable weather icon component
Item {
    id: root

    required property string weatherIconPath
    required property QtObject colors
    property bool isLoading: false
    property bool showBrief: false
    property string condition: ""
    property real iconScale: 0.7

    Kirigami.Icon {
        id: weatherIcon
        anchors.centerIn: parent
        width: parent.width * iconScale
        height: parent.height * iconScale
        source: weatherIconPath
        color: root.colors.iconColor
        isMask: true
        visible: !isLoading
    }

    // Brief text (for single-page layout)
    Text {
        visible: showBrief && !isLoading
        anchors.top: weatherIcon.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        text: condition
        font.pixelSize: parent.height * 0.12
        color: root.colors.textPrimary
        opacity: 0.9
        font.weight: Font.Light
    }
}
