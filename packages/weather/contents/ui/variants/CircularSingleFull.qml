import QtQuick
import "../components"

Item {
    id: fullItem

    required property QtObject colors
    required property string currentTemp
    required property string highTemp
    required property string lowTemp
    required property string condition
    required property string weatherIconPath
    required property bool isLoading

    SinglePageLayout {
        anchors.fill: parent
        weatherIconPath: fullItem.weatherIconPath
        condition: fullItem.condition
        currentTemp: fullItem.currentTemp
        highTemp: fullItem.highTemp
        lowTemp: fullItem.lowTemp
        isLoading: fullItem.isLoading
        colors: fullItem.colors
    }
}
