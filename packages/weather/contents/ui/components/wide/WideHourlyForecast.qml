import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Hourly forecast component for wide layout (6 consecutive hours from current time)
RowLayout {
    id: hourlyForecast

    // Required properties - passed from parent
    required property QtObject colors
    required property var hourlyForecastTimes
    required property var hourlyForecastIcons
    required property var hourlyForecastTemps
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

                // Hour time
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: hourlyForecast.hourlyForecastTimes[index] || "--"
                    font.pixelSize: parent.parent.height * 0.125
                    font.weight: Font.Light
                    color: hourlyForecast.colors.textSecondary
                }

                // Weather icon
                Kirigami.Icon {
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.parent.height * 0.4
                    Layout.preferredHeight: parent.parent.height * 0.4
                    source: hourlyForecast.getWeatherIcon(hourlyForecast.hourlyForecastIcons[index] || 0)
                    color: hourlyForecast.colors.iconColor
                    isMask: true
                }

                // Temperature
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: (hourlyForecast.hourlyForecastTemps[index] || "--") + "°"
                    font.pixelSize: parent.parent.height * 0.125
                    font.weight: Font.Normal
                    color: hourlyForecast.colors.textPrimary
                }
            }
        }
    }
}
