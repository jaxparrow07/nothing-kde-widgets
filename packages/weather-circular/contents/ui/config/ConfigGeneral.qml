import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_location: locationField.text
    property alias cfg_temperatureUnit: temperatureUnitCombo.currentIndex
    property alias cfg_layoutMode: layoutModeCombo.currentIndex

    ColumnLayout {
        spacing: 10

        RowLayout {
            Label {
                text: "Location:"
                Layout.alignment: Qt.AlignLeft
            }

            TextField {
                id: locationField
                placeholderText: "e.g., New York, Chennai, Villupuram"
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Enter a city name for weather information. The widget will automatically find the coordinates."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        RowLayout {
            Label {
                text: "Temperature Unit:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: temperatureUnitCombo
                model: ["Celsius (°C)", "Fahrenheit (°F)"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Choose between Celsius and Fahrenheit for temperature display."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        RowLayout {
            Label {
                text: "Layout Mode:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: layoutModeCombo
                model: ["Multi-page (swipe through pages)", "Single-page (grid layout)"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Multi-page: Swipe vertically through weather icon, temperature, and high/low pages.\nSingle-page: View all information in a grid layout."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
