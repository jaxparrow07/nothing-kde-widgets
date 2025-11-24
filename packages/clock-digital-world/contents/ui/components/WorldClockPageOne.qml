import QtQuick
import QtQuick.Layouts

// Page 1: City name + Time (12-hour) + AM/PM
Item {
    // Required properties
    required property string cityName
    required property string currentHours
    required property string currentMinutes
    required property bool colonVisible
    required property string amPm
    required property string ndot55FontFamily
    required property string ndotFontFamily

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // City name at top-left
        Text {
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            Layout.topMargin: 5
            text: cityName
            font.family: ndot55FontFamily
            font.pixelSize: Math.min(parent.width * 0.13, parent.height * 0.13)
            color: "#ffffff"
            opacity: 0.9
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }

        // Time display at bottom
        RowLayout {
            Layout.alignment: Qt.AlignHLeft | Qt.AlignBottom
            Layout.bottomMargin: 10
            Layout.fillWidth: true
            spacing: 8

            // Time in large digits with blinking colon
            Row {
                spacing: 4

                Text {
                    text: currentHours
                    font.family: ndotFontFamily
                    font.pixelSize: Math.min(root.width * 0.18, root.height * 0.18)
                    color: "#ffffff"
                    opacity: 1.0
                }

                Text {
                    text: ":"
                    font.family: ndotFontFamily
                    font.pixelSize: Math.min(root.width * 0.18, root.height * 0.18)
                    color: "#ffffff"
                    opacity: colonVisible ? 1.0 : 0.3

                    Behavior on opacity {
                        NumberAnimation { duration: 100 }
                    }
                }

                Text {
                    text: currentMinutes
                    font.family: ndotFontFamily
                    font.pixelSize: Math.min(root.width * 0.18, root.height * 0.18)
                    color: "#ffffff"
                    opacity: 1.0
                }
            }

            // AM/PM indicator (top-right of time)
            Text {
                Layout.alignment: Qt.AlignTop
                text: amPm
                font.family: ndot55FontFamily
                font.pixelSize: Math.min(root.width * 0.075, root.height * 0.075)
                color: "#ffffff"
                opacity: 0.85
            }

            // Spacer to balance layout
            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
            }
        }
    }
}
