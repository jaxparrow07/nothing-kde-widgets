import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// 6-day forecast component for wide layout
RowLayout {
    id: dailyForecast

    // Required properties - passed from parent
    required property var dailyForecastDays
    required property var dailyForecastIcons
    required property var dailyForecastHighs
    required property var dailyForecastLows
    required property var getWeatherIcon  // Function reference

    Layout.fillWidth: true
    Layout.preferredHeight: parent.height * 0.35
    Layout.topMargin: -10
    spacing: 8

    Repeater {
        model: 6

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width / 6
            Layout.alignment: Qt.AlignVTop

            ColumnLayout {
                anchors.centerIn: parent
                width: parent.width
                spacing: 2

                // Day name
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: dailyForecast.dailyForecastDays[index] || "---"
                    font.pixelSize: parent.parent.height * 0.125
                    font.weight: Font.Light
                    color: "#aaaaaa"
                }

                // Weather icon
                Kirigami.Icon {
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.parent.height * 0.4
                    Layout.preferredHeight: parent.parent.height * 0.4
                    source: dailyForecast.getWeatherIcon(dailyForecast.dailyForecastIcons[index] || 0)
                    color: "#ffffff"
                }

                // High temp
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: (dailyForecast.dailyForecastHighs[index] || "--") + "°"
                    font.pixelSize: parent.parent.height * 0.125
                    font.weight: Font.Normal
                    color: "#ffffff"
                }

                // Low temp
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: (dailyForecast.dailyForecastLows[index] || "--") + "°"
                    font.pixelSize: parent.parent.height * 0.09
                    font.weight: Font.Light
                    color: "#aaaaaa"
                }
            }
        }
    }
}
