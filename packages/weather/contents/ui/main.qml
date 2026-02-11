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

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

    // Configuration properties
    property string location: plasmoid.configuration.location
    property int temperatureUnit: plasmoid.configuration.temperatureUnit

    // WEATHER DATA - These will be updated by API calls
    property string currentTemp: "--"
    property string highTemp: "--"
    property string lowTemp: "--"
    property string condition: "Loading..."
    property int weatherCode: 0
    property string weatherIconPath: getWeatherIcon(0)

    // Daily forecast data (6 days from tomorrow)
    property var dailyForecastDays: []       // Array of day names: ["FRI", "SAT", ...]
    property var dailyForecastIcons: []      // Array of weather codes
    property var dailyForecastHighs: []      // Array of high temps
    property var dailyForecastLows: []       // Array of low temps

    // Hourly forecast data (6 consecutive hours from current time, max 12 hours ahead)
    property var hourlyForecastTimes: []     // Array of times: ["3 PM", "4 PM", ...]
    property var hourlyForecastIcons: []     // Array of weather codes
    property var hourlyForecastTemps: []     // Array of temperatures

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

    // Get day name for forecast (starting from tomorrow)
    function getDayName(daysAhead) {
        var date = new Date()
        date.setDate(date.getDate() + daysAhead)
        var dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return dayNames[date.getDay()]
    }

    // Process daily forecast data (6 days from tomorrow)
    function processDailyForecast(dailyData) {
        var days = []
        var icons = []
        var highs = []
        var lows = []

        // Start from index 1 (tomorrow) and get 6 days
        for (var i = 1; i <= 6; i++) {
            days.push(getDayName(i))
            icons.push(dailyData.weather_code[i])
            highs.push(Math.round(dailyData.temperature_2m_max[i]).toString())
            lows.push(Math.round(dailyData.temperature_2m_min[i]).toString())
        }

        dailyForecastDays = days
        dailyForecastIcons = icons
        dailyForecastHighs = highs
        dailyForecastLows = lows
    }

    // Process hourly forecast data (6 consecutive hours from current time, max 12 hours ahead)
    function processHourlyForecast(hourlyData) {
        var times = []
        var icons = []
        var temps = []

        var currentDate = new Date()
        var currentHour = currentDate.getHours()

        // Start from next hour
        var startHour = currentHour + 1
        var maxHour = currentHour + 12  // Cap at 12 hours ahead
        var targetEndHour = Math.min(startHour + 5, maxHour)  // Get 6 hours, but stop at 12

        // Get the time array to find the right indices
        for (var i = 0; i < hourlyData.time.length && times.length < 6; i++) {
            var timeStr = hourlyData.time[i]
            var hour = parseInt(timeStr.substring(11, 13)) // Extract hour from ISO string

            // Get consecutive hours starting from next hour, stopping at 12 hours ahead
            if (hour >= startHour && hour <= targetEndHour) {
                // Format time
                var displayHour = hour
                var ampm = " AM"
                if (hour >= 12) {
                    ampm = " PM"
                    if (hour > 12) displayHour = hour - 12
                }
                if (displayHour === 0) displayHour = 12

                times.push(displayHour + ampm)
                icons.push(hourlyData.weather_code[i])
                temps.push(Math.round(hourlyData.temperature_2m[i]).toString())
            }
        }

        hourlyForecastTimes = times
        hourlyForecastIcons = icons
        hourlyForecastTemps = temps
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
                            condition = "Location not found"
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
                  "&hourly=temperature_2m,weather_code" +
                  "&daily=temperature_2m_max,temperature_2m_min,weather_code" +
                  "&temperature_unit=" + apiTempUnit +
                  "&timezone=auto" +
                  "&forecast_days=7"

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

                            // Process 6-day forecast (tomorrow onwards)
                            processDailyForecast(response.daily)
                        }

                        // Process hourly forecast (6 consecutive hours from current time)
                        if (response.hourly) {
                            processHourlyForecast(response.hourly)
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

    compactRepresentation: Item {
        id: compactItem

        states: [
            State {
                name: "horizontalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

                PropertyChanges {
                    compactItem.Layout.fillHeight: true
                    compactItem.Layout.fillWidth: false
                    compactItem.Layout.minimumWidth: compactRow.implicitWidth + compactItem.height * 0.4
                    compactItem.Layout.maximumWidth: compactItem.Layout.minimumWidth
                }
            },
            State {
                name: "verticalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.fillHeight: false
                    compactItem.Layout.fillWidth: true
                    compactItem.Layout.minimumHeight: compactRow.implicitHeight + compactItem.width * 0.4
                    compactItem.Layout.maximumHeight: compactItem.Layout.minimumHeight
                }
            },
            State {
                name: "desktop"
                when: Plasmoid.formFactor !== PlasmaCore.Types.Horizontal && Plasmoid.formFactor !== PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.minimumWidth: compactRow.implicitWidth + 8
                    compactItem.Layout.minimumHeight: compactRow.implicitHeight + 8
                }
            }
        ]

        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: compactItem.height * 0.15

            Kirigami.Icon {
                anchors.verticalCenter: parent.verticalCenter
                width: compactItem.height * 0.75
                height: compactItem.height * 0.75
                source: root.weatherIconPath
                color: nColors.iconColor
                isMask: true
                visible: !root.isLoading && root.errorMessage === ""
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentTemp + "\u00B0"
                font.pixelSize: compactItem.height * 0.45
                font.weight: Font.Normal
                color: nColors.textPrimary
                visible: !root.isLoading
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200

        // Detect wide layout (width >= 2x height)
        readonly property bool isWideLayout: width >= height * 2

        // SQUARE/VERTICAL LAYOUT - Rectangle with SwipeView inside (content swipes, not rectangle)
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: nColors.background
            radius: 20
            opacity: 0.95
            visible: !parent.isWideLayout

            QQC2.SwipeView {
                id: swipeView
                anchors.fill: parent
                anchors.margins: 15
                currentIndex: 0
                clip: true
                orientation: Qt.Vertical

                // PAGE 1: Current temperature with icon
                SquarePageOne {
                    colors: nColors
                    currentTemp: root.currentTemp
                    weatherIconPath: root.weatherIconPath
                    isLoading: root.isLoading
                    errorMessage: root.errorMessage
                    location: root.location
                }

                // PAGE 2: High/low temps with condition
                SquarePageTwo {
                    colors: nColors
                    highTemp: root.highTemp
                    lowTemp: root.lowTemp
                    condition: root.condition
                    isLoading: root.isLoading
                }
            }
        }

        // WIDE LAYOUT - Common rectangle with swipeable content
        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            color: nColors.background
            radius: 20
            opacity: 0.95
            visible: parent.isWideLayout

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 5

                // Shared header (common, not swipeable)
                WidePageHeader {
                    colors: nColors
                    weatherIconPath: root.weatherIconPath
                    isLoading: root.isLoading
                    errorMessage: root.errorMessage
                    currentTemp: root.currentTemp
                    highTemp: root.highTemp
                    lowTemp: root.lowTemp
                    location: root.location
                    condition: root.condition
                }

                // SwipeView for forecast content only
                QQC2.SwipeView {
                    id: wideSwipeView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: 0
                    clip: true
                    orientation: Qt.Vertical

                    // PAGE 1: Daily Forecast
                    Item {
                        WideDailyForecast {
                            anchors.fill: parent
                            colors: nColors
                            dailyForecastDays: root.dailyForecastDays
                            dailyForecastIcons: root.dailyForecastIcons
                            dailyForecastHighs: root.dailyForecastHighs
                            dailyForecastLows: root.dailyForecastLows
                            getWeatherIcon: root.getWeatherIcon
                        }
                    }

                    // PAGE 2: Hourly Forecast
                    Item {
                        WideHourlyForecast {
                            anchors.fill: parent
                            colors: nColors
                            hourlyForecastTimes: root.hourlyForecastTimes
                            hourlyForecastIcons: root.hourlyForecastIcons
                            hourlyForecastTemps: root.hourlyForecastTemps
                            getWeatherIcon: root.getWeatherIcon
                        }
                    }
                }
            }
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

            readonly property bool useWideLayout: parent.isWideLayout

            Repeater {
                model: pageIndicator.useWideLayout ? 2 : 2

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: {
                        var currentIdx = pageIndicator.useWideLayout ? wideSwipeView.currentIndex : swipeView.currentIndex
                        return currentIdx === index ? nColors.indicatorActive : nColors.indicatorInactive
                    }
                    opacity: {
                        var currentIdx = pageIndicator.useWideLayout ? wideSwipeView.currentIndex : swipeView.currentIndex
                        return currentIdx === index ? 0.95 : 0.45
                    }

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
                            if (pageIndicator.useWideLayout) {
                                wideSwipeView.currentIndex = index
                            } else {
                                swipeView.currentIndex = index
                            }
                        }
                    }
                }
            }
        }

        // Mouse wheel support for page navigation - works for both layouts
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            z: 5
            onWheel: {
                if (parent.isWideLayout) {
                    if (wheel.angleDelta.y < 0) {
                        wideSwipeView.incrementCurrentIndex()
                    } else if (wheel.angleDelta.y > 0) {
                        wideSwipeView.decrementCurrentIndex()
                    }
                } else {
                    if (wheel.angleDelta.y < 0) {
                        swipeView.incrementCurrentIndex()
                    } else if (wheel.angleDelta.y > 0) {
                        swipeView.decrementCurrentIndex()
                    }
                }
            }
        }
    }
}
