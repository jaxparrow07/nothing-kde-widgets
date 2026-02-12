import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: fullItem

    required property QtObject colors
    required property string cityName
    required property string currentHours
    required property string currentMinutes
    required property int currentSeconds
    readonly property bool colonVisible: currentSeconds % 2 === 0
    required property string amPm
    required property string dayOfWeek
    required property string hourDifference
    required property string ndotFontFamily
    required property string ndot55FontFamily

    Layout.preferredWidth: 200
    Layout.preferredHeight: 200
    Layout.minimumWidth: 200
    Layout.minimumHeight: 200
    Layout.maximumWidth: 200
    Layout.maximumHeight: 200

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 10
        color: fullItem.colors.background
        radius: 20
        opacity: 0.95

        QQC2.SwipeView {
            id: swipeView
            anchors.fill: parent
            anchors.margins: 15
            currentIndex: 0
            clip: true
            orientation: Qt.Vertical

            WorldClockPageOne {
                colors: fullItem.colors
                cityName: fullItem.cityName
                currentHours: fullItem.currentHours
                currentMinutes: fullItem.currentMinutes
                currentSeconds: fullItem.currentSeconds
                amPm: fullItem.amPm
                ndot55FontFamily: fullItem.ndot55FontFamily
                ndotFontFamily: fullItem.ndotFontFamily
            }

            WorldClockPageTwo {
                colors: fullItem.colors
                dayOfWeek: fullItem.dayOfWeek
                hourDifference: fullItem.hourDifference
                ndot55FontFamily: fullItem.ndot55FontFamily
                ndotFontFamily: fullItem.ndotFontFamily
            }
        }
    }

    // Page Indicator (right center)
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
            model: 2

            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: swipeView.currentIndex === index ? fullItem.colors.indicatorActive : fullItem.colors.indicatorInactive
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
            if (wheel.angleDelta.y < 0) {
                swipeView.incrementCurrentIndex()
            } else if (wheel.angleDelta.y > 0) {
                swipeView.decrementCurrentIndex()
            }
        }
    }
}
