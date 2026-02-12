import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
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
    required property string errorMessage
    required property string location
    required property var dailyForecastDays
    required property var dailyForecastIcons
    required property var dailyForecastHighs
    required property var dailyForecastLows
    required property var hourlyForecastTimes
    required property var hourlyForecastIcons
    required property var hourlyForecastTemps
    required property var getWeatherIcon

    // Detect wide layout (width >= 2x height)
    readonly property bool isWideLayout: width >= height * 2

    // SQUARE/VERTICAL LAYOUT
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: fullItem.colors.background
        radius: 20
        opacity: 0.95
        visible: !fullItem.isWideLayout

        QQC2.SwipeView {
            id: swipeView
            anchors.fill: parent
            anchors.margins: 15
            currentIndex: 0
            clip: true
            orientation: Qt.Vertical

            SquarePageOne {
                colors: fullItem.colors
                currentTemp: fullItem.currentTemp
                weatherIconPath: fullItem.weatherIconPath
                isLoading: fullItem.isLoading
                errorMessage: fullItem.errorMessage
                location: fullItem.location
            }

            SquarePageTwo {
                colors: fullItem.colors
                highTemp: fullItem.highTemp
                lowTemp: fullItem.lowTemp
                condition: fullItem.condition
                isLoading: fullItem.isLoading
            }
        }
    }

    // WIDE LAYOUT
    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: fullItem.colors.background
        radius: 20
        opacity: 0.95
        visible: fullItem.isWideLayout

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 5

            WidePageHeader {
                colors: fullItem.colors
                weatherIconPath: fullItem.weatherIconPath
                isLoading: fullItem.isLoading
                errorMessage: fullItem.errorMessage
                currentTemp: fullItem.currentTemp
                highTemp: fullItem.highTemp
                lowTemp: fullItem.lowTemp
                location: fullItem.location
                condition: fullItem.condition
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
                        colors: fullItem.colors
                        dailyForecastDays: fullItem.dailyForecastDays
                        dailyForecastIcons: fullItem.dailyForecastIcons
                        dailyForecastHighs: fullItem.dailyForecastHighs
                        dailyForecastLows: fullItem.dailyForecastLows
                        getWeatherIcon: fullItem.getWeatherIcon
                    }
                }

                Item {
                    WideHourlyForecast {
                        anchors.fill: parent
                        colors: fullItem.colors
                        hourlyForecastTimes: fullItem.hourlyForecastTimes
                        hourlyForecastIcons: fullItem.hourlyForecastIcons
                        hourlyForecastTemps: fullItem.hourlyForecastTemps
                        getWeatherIcon: fullItem.getWeatherIcon
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

        readonly property bool useWideLayout: fullItem.isWideLayout

        Repeater {
            model: 2

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: {
                    var currentIdx = pageIndicator.useWideLayout ? wideSwipeView.currentIndex : swipeView.currentIndex
                    return currentIdx === index ? fullItem.colors.indicatorActive : fullItem.colors.indicatorInactive
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

    // Mouse wheel support
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        z: 5
        onWheel: {
            if (fullItem.isWideLayout) {
                if (wheel.angleDelta.y < 0) wideSwipeView.incrementCurrentIndex()
                else if (wheel.angleDelta.y > 0) wideSwipeView.decrementCurrentIndex()
            } else {
                if (wheel.angleDelta.y < 0) swipeView.incrementCurrentIndex()
                else if (wheel.angleDelta.y > 0) swipeView.decrementCurrentIndex()
            }
        }
    }
}
