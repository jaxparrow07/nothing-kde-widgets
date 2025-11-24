import QtQuick
import QtQuick.Layouts

// Page 2: Day of week + Hour difference
Item {
    // Required properties
    required property string dayOfWeek
    required property string hourDifference
    required property string ndot55FontFamily
    required property string ndotFontFamily

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Day of week at top-left
        Text {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.topMargin: 5
            text: dayOfWeek
            font.family: ndot55FontFamily
            font.pixelSize: Math.min(parent.width * 0.13, parent.height * 0.13)
            color: "#ffffff"
            opacity: 0.9
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Hour difference display at bottom
        RowLayout {
            Layout.alignment: Qt.AlignHLeft | Qt.AlignBottom
            Layout.bottomMargin: 10
            Layout.fillWidth: true
            spacing: 8

            // Hour difference in large digits
            Text {

                Layout.alignment: Qt.AlignBottom
                text: hourDifference
                font.family: ndotFontFamily
                font.pixelSize: Math.min(root.width * 0.18, root.height * 0.18)
                color: "#ffffff"
                opacity: 1.0
            }

            // "H" indicator
            Text {
                Layout.alignment: Qt.AlignBottom
                text: "H"
                font.family: ndot55FontFamily
                font.pixelSize: Math.min(root.width * 0.075, root.height * 0.075)
                color: "#ffffff"
                opacity: 0.85
                Layout.bottomMargin: 5
            }
        }
    }
}
