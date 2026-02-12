import QtQuick
import QtQuick.Layouts

// Square layout Page 2: High/Low temps with condition
Item {
    id: root

    // Required properties
    required property QtObject colors
    required property string highTemp
    required property string lowTemp
    required property string condition
    required property bool isLoading

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 6

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 20
        }

        // High temperature with arrow
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Text {
                text: "↑"
                font.pixelSize: parent.parent.width * 0.19
                color: root.colors.textPrimary
                opacity: 0.9
            }

            Text {
                text: highTemp + "°"
                font.pixelSize: parent.parent.width * 0.19
                font.weight: Font.Normal
                color: root.colors.textPrimary
                opacity: isLoading ? 0.5 : 1.0
            }
        }

        // Low temperature with arrow
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Text {
                text: "↓"
                font.pixelSize: parent.parent.width * 0.19
                color: root.colors.textPrimary
                opacity: 0.9
            }

            Text {
                text: lowTemp + "°"
                font.pixelSize: parent.parent.width * 0.19
                font.weight: Font.Normal
                color: root.colors.textPrimary
                opacity: isLoading ? 0.5 : 1.0
            }
        }

        Item {
            Layout.minimumHeight: 2
        }

        // Weather condition
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.bottomMargin: 5
            text: condition
            font.pixelSize: parent.width * 0.09
            color: root.colors.textPrimary
            opacity: 0.9
        }

        Item {
            Layout.fillHeight: true
            Layout.minimumHeight: 10
        }
    }
}
