import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "components"
import "components/circle"
import "components/square"
import "components/wide"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // --- Variant selection ---
    property int widgetVariant: plasmoid.configuration.widgetVariant
    readonly property bool variantChosen: widgetVariant >= 0

    // --- Shared state ---
    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
        useSystemAccent: plasmoid.configuration.useSystemAccent
    }

    // Configuration properties
    property string location: plasmoid.configuration.location
    property int temperatureUnit: plasmoid.configuration.temperatureUnit

    // WEATHER DATA
    property string currentTemp: "--"
    property string highTemp: "--"
    property string lowTemp: "--"
    property string condition: "Loading..."
    property int weatherCode: 0
    property string weatherIconPath: getWeatherIcon(0)

    // Daily forecast data (6 days from tomorrow) - only used by variant 0
    property var dailyForecastDays: []
    property var dailyForecastIcons: []
    property var dailyForecastHighs: []
    property var dailyForecastLows: []

    // Hourly forecast data - only used by variant 0
    property var hourlyForecastTimes: []
    property var hourlyForecastIcons: []
    property var hourlyForecastTemps: []

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
        var currentHour = new Date().getHours()
        var isNight = currentHour < 7 || currentHour >= 19

        if (code === 0) {
            return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/sunny.svg")
        }
        else if (code === 1 || code === 2) {
            return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/partly_cloudy_day.svg")
        }
        else if (code === 3) {
            return Qt.resolvedUrl("../icons/cloudy.svg")
        }
        else if (code === 45 || code === 48) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 51 || code === 53 || code === 55) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 56 || code === 57) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 61 || code === 63 || code === 65) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 66 || code === 67) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 71 || code === 73 || code === 75) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        else if (code === 77) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        else if (code === 80 || code === 81 || code === 82) {
            return Qt.resolvedUrl("../icons/rain_or_mist.svg")
        }
        else if (code === 85 || code === 86) {
            return Qt.resolvedUrl("../icons/snow_fall.svg")
        }
        else if (code === 95) {
            return Qt.resolvedUrl("../icons/thunder.svg")
        }
        else if (code === 96 || code === 99) {
            return Qt.resolvedUrl("../icons/thunder.svg")
        }

        return isNight ? Qt.resolvedUrl("../icons/partly_cloudy_night.svg") : Qt.resolvedUrl("../icons/sunny.svg")
    }

    // Weather condition text mapping
    function getWeatherCondition(code) {
        if (code === 0) return "Clear"
        else if (code === 1) return "Mainly Clear"
        else if (code === 2) return "Partly Cloudy"
        else if (code === 3) return "Overcast"
        else if (code === 45) return "Fog"
        else if (code === 48) return "Depositing Rime Fog"
        else if (code === 51) return "Light Drizzle"
        else if (code === 53) return "Drizzle"
        else if (code === 55) return "Dense Drizzle"
        else if (code === 56) return "Light Freezing Drizzle"
        else if (code === 57) return "Freezing Drizzle"
        else if (code === 61) return "Slight Rain"
        else if (code === 63) return "Rain"
        else if (code === 65) return "Heavy Rain"
        else if (code === 66) return "Light Freezing Rain"
        else if (code === 67) return "Freezing Rain"
        else if (code === 71) return "Slight Snow"
        else if (code === 73) return "Snow"
        else if (code === 75) return "Heavy Snow"
        else if (code === 77) return "Snow Grains"
        else if (code === 80) return "Slight Rain Showers"
        else if (code === 81) return "Rain Showers"
        else if (code === 82) return "Violent Rain Showers"
        else if (code === 85) return "Slight Snow Showers"
        else if (code === 86) return "Heavy Snow Showers"
        else if (code === 95) return "Thunderstorm"
        else if (code === 96) return "Thunderstorm with Hail"
        else if (code === 99) return "Heavy Thunderstorm with Hail"
        return "Unknown"
    }

    // Get day name for forecast
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

    // Process hourly forecast data
    function processHourlyForecast(hourlyData) {
        var times = []
        var icons = []
        var temps = []

        var currentDate = new Date()
        var currentHour = currentDate.getHours()

        var startHour = currentHour + 1
        var maxHour = currentHour + 12
        var targetEndHour = Math.min(startHour + 5, maxHour)

        for (var i = 0; i < hourlyData.time.length && times.length < 6; i++) {
            var timeStr = hourlyData.time[i]
            var hour = parseInt(timeStr.substring(11, 13))

            if (hour >= startHour && hour <= targetEndHour) {
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

    // Geocoding function
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

        // Variant 0 needs full forecast data; variants 1 & 2 only need current + daily
        var needsFullForecast = (widgetVariant === 0)

        var url = "https://api.open-meteo.com/v1/forecast?" +
                  "latitude=" + latitude +
                  "&longitude=" + longitude +
                  "&current=temperature_2m,weather_code" +
                  (needsFullForecast ? "&hourly=temperature_2m,weather_code" : "") +
                  "&daily=temperature_2m_max,temperature_2m_min,weather_code" +
                  "&temperature_unit=" + apiTempUnit +
                  "&timezone=auto" +
                  "&forecast_days=" + (needsFullForecast ? "7" : "1")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)

                        if (response.current) {
                            currentTemp = Math.round(response.current.temperature_2m).toString()
                            weatherCode = response.current.weather_code || 0
                            weatherIconPath = getWeatherIcon(weatherCode)
                            condition = getWeatherCondition(weatherCode)
                        }

                        if (response.daily) {
                            highTemp = Math.round(response.daily.temperature_2m_max[0]).toString()
                            lowTemp = Math.round(response.daily.temperature_2m_min[0]).toString()

                            if (needsFullForecast) {
                                processDailyForecast(response.daily)
                            }
                        }

                        if (needsFullForecast && response.hourly) {
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
        interval: 1800000
        running: true
        repeat: true
        onTriggered: fetchWeatherData()
    }

    onLocationChanged: geocodeLocation()

    onTemperatureUnitChanged: {
        if (latitude !== 0 || longitude !== 0) {
            fetchWeatherData()
        }
    }

    // Re-fetch when variant changes (may need different data)
    onWidgetVariantChanged: {
        if (latitude !== 0 || longitude !== 0) {
            fetchWeatherData()
        }
    }

    Component.onCompleted: geocodeLocation()

    // --- Compact representation ---
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

        // Always icon + temp (same for all variants, works without variant selection)
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

    // --- Full representation ---
    fullRepresentation: Loader {
        id: fullLoader

        // Determine sizes based on variant and context
        readonly property bool isInPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal || Plasmoid.formFactor === PlasmaCore.Types.Vertical

        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 100
        Layout.minimumHeight: 100

        sourceComponent: {
            if (!root.variantChosen) return selectorComponent

            // In panel (popup): always show full weather detail
            if (isInPanel) return weatherFullComponent

            // On desktop: variant-specific
            if (root.widgetVariant === 0) return weatherFullComponent
            if (root.widgetVariant === 1) return circularSingleComponent
            if (root.widgetVariant === 2) return circularMultiComponent

            return selectorComponent
        }
    }

    Component {
        id: selectorComponent
        VariantSelector {
            colors: nColors
        }
    }

    Component {
        id: weatherFullComponent
        Item {
            readonly property bool isWideLayout: width >= height * 2

            // SQUARE/VERTICAL LAYOUT
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

                    SquarePageOne {
                        colors: nColors
                        currentTemp: root.currentTemp
                        weatherIconPath: root.weatherIconPath
                        isLoading: root.isLoading
                        errorMessage: root.errorMessage
                        location: root.location
                    }

                    SquarePageTwo {
                        colors: nColors
                        highTemp: root.highTemp
                        lowTemp: root.lowTemp
                        condition: root.condition
                        isLoading: root.isLoading
                    }
                }
            }

            // WIDE LAYOUT
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

                    QQC2.SwipeView {
                        id: wideSwipeView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: 0
                        clip: true
                        orientation: Qt.Vertical

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

            // Page Indicator
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
                    model: 2

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

                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }

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

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                z: 5
                onWheel: {
                    if (parent.isWideLayout) {
                        if (wheel.angleDelta.y < 0) wideSwipeView.incrementCurrentIndex()
                        else if (wheel.angleDelta.y > 0) wideSwipeView.decrementCurrentIndex()
                    } else {
                        if (wheel.angleDelta.y < 0) swipeView.incrementCurrentIndex()
                        else if (wheel.angleDelta.y > 0) swipeView.decrementCurrentIndex()
                    }
                }
            }
        }
    }

    Component {
        id: circularSingleComponent
        SinglePageLayout {
            weatherIconPath: root.weatherIconPath
            condition: root.condition
            currentTemp: root.currentTemp
            highTemp: root.highTemp
            lowTemp: root.lowTemp
            isLoading: root.isLoading
            colors: nColors
        }
    }

    Component {
        id: circularMultiComponent
        Item {
            Rectangle {
                anchors.fill: parent
                anchors.margins: 10
                color: nColors.background
                radius: width / 2
                opacity: 0.95

                QQC2.SwipeView {
                    id: circleSwipeView
                    anchors.fill: parent
                    anchors.margins: 15
                    currentIndex: 0
                    clip: true
                    orientation: Qt.Vertical

                    CirclePageOne {
                        weatherIconPath: root.weatherIconPath
                        isLoading: root.isLoading
                        errorMessage: root.errorMessage
                        colors: nColors
                    }

                    CirclePageTwo {
                        currentTemp: root.currentTemp
                        isLoading: root.isLoading
                        colors: nColors
                    }

                    CirclePageThree {
                        highTemp: root.highTemp
                        lowTemp: root.lowTemp
                        isLoading: root.isLoading
                        colors: nColors
                    }
                }
            }

            // Page Indicator
            Column {
                anchors {
                    right: parent.right
                    rightMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                spacing: 8
                z: 100

                Repeater {
                    model: 3

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: circleSwipeView.currentIndex === index ? nColors.indicatorActive : nColors.indicatorInactive
                        opacity: circleSwipeView.currentIndex === index ? 0.95 : 0.45

                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: circleSwipeView.currentIndex = index
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                z: 5
                onWheel: {
                    if (wheel.angleDelta.y < 0) circleSwipeView.incrementCurrentIndex()
                    else if (wheel.angleDelta.y > 0) circleSwipeView.decrementCurrentIndex()
                }
            }
        }
    }
}
