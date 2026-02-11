import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "components"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

    // Configuration properties
    property string location: plasmoid.configuration.location
    property int temperatureUnit: plasmoid.configuration.temperatureUnit
    property int layoutMode: plasmoid.configuration.layoutMode

    // WEATHER DATA - These will be updated by API calls
    property string currentTemp: "--"
    property string highTemp: "--"
    property string lowTemp: "--"
    property string condition: "Loading..."
    property int weatherCode: 0
    property string weatherIconPath: getWeatherIcon(0)

    // API state
    property double latitude: 0
    property double longitude: 0
    property bool isLoading: true
    property string errorMessage: ""

    // Temperature unit symbol
    readonly property string tempUnit: temperatureUnit === 0 ? "°C" : "°F"
    readonly property string apiTempUnit: temperatureUnit === 0 ? "celsius" : "fahrenheit"

    // Weather icon mapping function
    function getWeatherIcon(code) {
        // WMO Weather interpretation codes (28 total codes)
        // Determine if it's day or night (night: before 7 AM or after 7 PM)
        var currentHour = new Date().getHours()
        var isNight = currentHour < 7 || currentHour >= 19

        // Clear sky (0)
        if (code === 0) {
            return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/sunny.svg")
        }
        // Mainly clear, partly cloudy (1-2)
        else if (code === 1 || code === 2) {
            return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/partly_cloudy_day.svg")
        }
        // Overcast (3)
        else if (code === 3) {
            return Qt.resolvedUrl("../icons/cloudy.svg")
        }
        // Fog and depositing rime fog (45, 48)
        else if (code === 45 || code === 48) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Drizzle: Light, moderate, and dense (51, 53, 55)
        else if (code === 51 || code === 53 || code === 55) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Freezing Drizzle: Light and dense (56, 57)
        else if (code === 56 || code === 57) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Rain: Slight, moderate and heavy (61, 63, 65)
        else if (code === 61 || code === 63 || code === 65) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Freezing Rain: Light and heavy (66, 67)
        else if (code === 66 || code === 67) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Snow fall: Slight, moderate, and heavy (71, 73, 75)
        else if (code === 71 || code === 73 || code === 75) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        // Snow grains (77)
        else if (code === 77) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        // Rain showers: Slight, moderate, and violent (80, 81, 82)
        else if (code === 80 || code === 81 || code === 82) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        // Snow showers: Slight and heavy (85, 86)
        else if (code === 85 || code === 86) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        // Thunderstorm: Slight or moderate (95)
        else if (code === 95) {
            return Qt.resolvedUrl("../icons/thunder.svg")
        }
        // Thunderstorm with slight and heavy hail (96, 99)
        else if (code === 96 || code === 99) {
            return Qt.resolvedUrl("../icons/thunder.svg")
        }

        // Default fallback
        return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/sunny.svg")
    }

    // Weather condition text mapping
    function getWeatherCondition(code) {
        // Clear/Cloudy conditions (0-3)
        if (code === 0) return "Clear"
        else if (code === 1) return "Mainly Clear"
        else if (code === 2) return "Partly Cloudy"
        else if (code === 3) return "Overcast"
        // Fog (45, 48)
        else if (code === 45) return "Fog"
        else if (code === 48) return "Depositing Rime Fog"
        // Drizzle (51-57)
        else if (code === 51) return "Light Drizzle"
        else if (code === 53) return "Drizzle"
        else if (code === 55) return "Dense Drizzle"
        else if (code === 56) return "Light Freezing Drizzle"
        else if (code === 57) return "Freezing Drizzle"
        // Rain (61-67)
        else if (code === 61) return "Slight Rain"
        else if (code === 63) return "Rain"
        else if (code === 65) return "Heavy Rain"
        else if (code === 66) return "Light Freezing Rain"
        else if (code === 67) return "Freezing Rain"
        // Snow (71-77)
        else if (code === 71) return "Slight Snow"
        else if (code === 73) return "Snow"
        else if (code === 75) return "Heavy Snow"
        else if (code === 77) return "Snow Grains"
        // Showers (80-86)
        else if (code === 80) return "Slight Rain Showers"
        else if (code === 81) return "Rain Showers"
        else if (code === 82) return "Violent Rain Showers"
        else if (code === 85) return "Slight Snow Showers"
        else if (code === 86) return "Heavy Snow Showers"
        // Thunderstorm (95-99)
        else if (code === 95) return "Thunderstorm"
        else if (code === 96) return "Thunderstorm with Hail"
        else if (code === 99) return "Heavy Thunderstorm with Hail"
        return "Unknown"
    }

    // Geocoding function - convert location name to coordinates
    function geocodeLocation() {
        isLoading = true
        errorMessage = ""

        var xhr = new XMLHttpRequest()
        var url = "https://geocoding-api.open-meteo.com/v1/search?name=" +
                  encodeURIComponent(location) + "&count=1&language=en&format=json"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.results && response.results.length > 0) {
                            latitude = response.results[0].latitude
                            longitude = response.results[0].longitude
                            fetchWeatherData()
                        } else {
                            errorMessage = "Location not found"
                            isLoading = false
                            currentTemp = "--"
                            condition = "Not found"
                        }
                    } catch (e) {
                        errorMessage = "Error parsing location data"
                        isLoading = false
                        console.error("Geocoding parse error:", e)
                    }
                } else {
                    errorMessage = "Network error"
                    isLoading = false
                    console.error("Geocoding request failed:", xhr.status)
                }
            }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    // Fetch weather data from Open-Meteo API
    function fetchWeatherData() {
        if (latitude === 0 && longitude === 0) {
            geocodeLocation()
            return
        }

        var xhr = new XMLHttpRequest()
        var url = "https://api.open-meteo.com/v1/forecast?" +
                  "latitude=" + latitude +
                  "&longitude=" + longitude +
                  "&current=temperature_2m,weather_code" +
                  "&daily=temperature_2m_max,temperature_2m_min,weather_code" +
                  "&temperature_unit=" + apiTempUnit +
                  "&timezone=auto" +
                  "&forecast_days=1"

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)

                        // Update current temperature
                        if (response.current) {
                            currentTemp = Math.round(response.current.temperature_2m).toString()
                            weatherCode = response.current.weather_code || 0
                            weatherIconPath = getWeatherIcon(weatherCode)
                            condition = getWeatherCondition(weatherCode)
                        }

                        // Update daily high/low for today
                        if (response.daily) {
                            highTemp = Math.round(response.daily.temperature_2m_max[0]).toString()
                            lowTemp = Math.round(response.daily.temperature_2m_min[0]).toString()
                        }

                        isLoading = false
                        errorMessage = ""
                    } catch (e) {
                        errorMessage = "Error parsing weather data"
                        isLoading = false
                        console.error("Weather parse error:", e)
                    }
                } else {
                    errorMessage = "Failed to fetch weather"
                    isLoading = false
                    console.error("Weather request failed:", xhr.status)
                }
            }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    // Timer to refresh weather data every 30 minutes
    Timer {
        interval: 1800000 // 30 minutes in milliseconds
        running: true
        repeat: true
        onTriggered: fetchWeatherData()
    }

    // Fetch weather when location changes
    onLocationChanged: {
        geocodeLocation()
    }

    // Fetch weather when temperature unit changes
    onTemperatureUnitChanged: {
        if (latitude !== 0 || longitude !== 0) {
            fetchWeatherData()
        }
    }

    // Initial data fetch
    Component.onCompleted: {
        geocodeLocation()
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200

        // MULTI-PAGE LAYOUT (layoutMode = 0) - Common rectangle with swipeable content
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: nColors.background
            radius: width / 2
            opacity: 0.95
            visible: root.layoutMode === 0

            QQC2.SwipeView {
                id: swipeView
                anchors.fill: parent
                anchors.margins: 15
                currentIndex: 0
                clip: true
                orientation: Qt.Vertical

                // PAGE 1: Weather icon only
                CirclePageOne {
                    weatherIconPath: root.weatherIconPath
                    isLoading: root.isLoading
                    errorMessage: root.errorMessage
                    colors: nColors
                }

                // PAGE 2: Temperature
                CirclePageTwo {
                    currentTemp: root.currentTemp
                    isLoading: root.isLoading
                    colors: nColors
                }

                // PAGE 3: High/Low
                CirclePageThree {
                    highTemp: root.highTemp
                    lowTemp: root.lowTemp
                    isLoading: root.isLoading
                    colors: nColors
                }
            }
        }

        // SINGLE-PAGE LAYOUT (layoutMode = 1)
        SinglePageLayout {
            anchors.fill: parent
            visible: root.layoutMode === 1
            weatherIconPath: root.weatherIconPath
            condition: root.condition
            currentTemp: root.currentTemp
            highTemp: root.highTemp
            lowTemp: root.lowTemp
            isLoading: root.isLoading
            colors: nColors
        }

        // Vertical Page Indicator (right center) - works for both layouts
        Column {
            id: pageIndicator
            anchors {
                right: parent.right
                rightMargin: 16
                verticalCenter: parent.verticalCenter
            }
            spacing: 8
            z: 100
            visible: root.layoutMode === 0

            Repeater {
                model: 3

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: swipeView.currentIndex === index ? nColors.indicatorActive : nColors.indicatorInactive
                    opacity: swipeView.currentIndex === index ? 0.95 : 0.45

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 200 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            swipeView.currentIndex = index
                        }
                    }
                }
            }
        }

        // Mouse wheel support for page navigation - only for multi-page
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            z: 5
            enabled: root.layoutMode === 0
            onWheel: {
                if (wheel.angleDelta.y < 0) {
                    swipeView.incrementCurrentIndex()
                } else if (wheel.angleDelta.y > 0) {
                    swipeView.decrementCurrentIndex()
                }
            }
        }
    }
}
