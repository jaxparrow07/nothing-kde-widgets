import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Shared header for wide layout pages
RowLayout {
    id: header

    // Required properties - passed from parent
    required property string weatherIconPath
    required property bool isLoading
    required property string errorMessage
    required property string currentTemp
    required property string highTemp
    required property string lowTemp
    required property string location
    required property string condition

    Layout.fillWidth: true
    Layout.preferredHeight: parent.height * 0.60
    Layout.topMargin: -30
    spacing: 15

    // Weather icon
    Kirigami.Icon {
        Layout.preferredWidth: parent.height * 0.585
        Layout.preferredHeight: parent.height * 0.585
        source: header.weatherIconPath
        color: "#ffffff"
        visible: !header.isLoading && header.errorMessage === ""
    }

    // Current temperature
    Text {
        text: header.currentTemp + "°"
        font.pixelSize: parent.height * 0.36
        font.weight: Font.Normal
        color: "#ffffff"
        opacity: header.isLoading ? 0.5 : 1.0
    }

    // High/Low temps
    ColumnLayout {
        spacing: 4
        Layout.alignment: Qt.AlignVCenter

        RowLayout {
            spacing: 6
            Text {
                text: "↑"
                font.pixelSize: parent.parent.parent.height * 0.144
                color: "#ffffff"
                opacity: 0.9
            }
            Text {
                text: header.highTemp + "°"
                font.pixelSize: parent.parent.parent.height * 0.144
                font.weight: Font.Normal
                color: "#ffffff"
            }
        }

        RowLayout {
            spacing: 6
            Text {
                text: "↓"
                font.pixelSize: parent.parent.parent.height * 0.144
                color: "#ffffff"
                opacity: 0.9
            }
            Text {
                text: header.lowTemp + "°"
                font.pixelSize: parent.parent.parent.height * 0.144
                font.weight: Font.Normal
                color: "#ffffff"
            }
        }
    }

    Item { Layout.fillWidth: true }

    // Location and condition
    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
        spacing: 4

        Text {
            text: header.location
            font.pixelSize: parent.parent.height * 0.16
            color: "#ffffff"
            horizontalAlignment: Text.AlignRight
        }

        Text {
            text: header.condition
            font.pixelSize: parent.parent.height * 0.16
            font.weight: Font.Light
            color: "#ffffff"
            opacity: 0.8
            horizontalAlignment: Text.AlignRight
        }
    }
}
