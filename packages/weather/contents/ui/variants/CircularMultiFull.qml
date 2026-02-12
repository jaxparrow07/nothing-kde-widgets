import QtQuick
import QtQuick.Controls as QQC2
import "../components"

Item {
    id: fullItem

    required property QtObject colors
    required property string currentTemp
    required property string highTemp
    required property string lowTemp
    required property string weatherIconPath
    required property bool isLoading
    required property string errorMessage

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: fullItem.colors.background
        radius: width / 2
        opacity: 0.95

        QQC2.SwipeView {
            id: swipeView
            anchors.fill: parent
            anchors.margins: 15
            currentIndex: 0
            clip: true
            orientation: Qt.Vertical

            CirclePageOne {
                weatherIconPath: fullItem.weatherIconPath
                isLoading: fullItem.isLoading
                errorMessage: fullItem.errorMessage
                colors: fullItem.colors
            }

            CirclePageTwo {
                currentTemp: fullItem.currentTemp
                isLoading: fullItem.isLoading
                colors: fullItem.colors
            }

            CirclePageThree {
                highTemp: fullItem.highTemp
                lowTemp: fullItem.lowTemp
                isLoading: fullItem.isLoading
                colors: fullItem.colors
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

        Repeater {
            model: 3

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: swipeView.currentIndex === index ? fullItem.colors.indicatorActive : fullItem.colors.indicatorInactive
                opacity: swipeView.currentIndex === index ? 0.95 : 0.45

                Behavior on color { ColorAnimation { duration: 200 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: swipeView.currentIndex = index
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
            if (wheel.angleDelta.y < 0) swipeView.incrementCurrentIndex()
            else if (wheel.angleDelta.y > 0) swipeView.decrementCurrentIndex()
        }
    }
}
