import QtQuick
import QtQuick.Layouts

// Reusable high/low temperature component
Item {
    id: root

    required property string highTemp
    required property string lowTemp
    property bool isLoading: false
    property real textScale: 0.20
    property real spacing: 8

    ColumnLayout {
        anchors.centerIn: parent
        spacing: root.spacing

        // High temperature with arrow
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Text {
                text: "↑"
                font.pixelSize: Math.min(root.width * textScale, root.height * textScale)
                color: "#ffffff"
                opacity: 0.9
            }

            Text {
                text: highTemp + "°"
                font.pixelSize: Math.min(root.width * textScale, root.height * textScale)
                font.weight: Font.Light
                color: "#ffffff"
                opacity: isLoading ? 0.5 : 1.0
            }
        }

        // Low temperature with arrow
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Text {
                text: "↓"
                font.pixelSize: Math.min(root.width * textScale, root.height * textScale)
                color: "#ffffff"
                opacity: 0.9
            }

            Text {
                text: lowTemp + "°"
                font.pixelSize: Math.min(root.width * textScale, root.height * textScale)
                font.weight: Font.Light
                color: "#ffffff"
                opacity: isLoading ? 0.5 : 1.0
            }
        }
    }
}
