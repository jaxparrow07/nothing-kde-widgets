import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components"
import "config" as Config

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

    // Configuration properties
    property string cityName: plasmoid.configuration.cityName
    property string timeZone: plasmoid.configuration.timeZone

    // Time properties
    property string currentTime: "12:00"
    property string currentHours: "12"
    property string currentMinutes: "00"
    property string amPm: "AM"
    property string dayOfWeek: "Friday"
    property string hourDifference: "+0.0"
    property bool colonVisible: true

    // Timezone data from embedded QML
    property var timezonesData: ({})

    Config.TimezonesData {
        id: timezonesDataSource
    }

    // Load fonts
    FontLoader {
        id: ndot55Font
        source: Qt.resolvedUrl("../fonts/ndot-55.otf")
    }

    FontLoader {
        id: ndotFont
        source: Qt.resolvedUrl("../fonts/ndot.ttf")
    }

    // Timer to update time every second
    Timer {
        interval: 1000 // Update every second
        running: true
        repeat: true
        onTriggered: updateTime()
        Component.onCompleted: updateTime()
    }

    // Timer to blink the colon separator (every 1 second)
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.colonVisible = !root.colonVisible
    }

    // Load timezones from embedded data
    Component.onCompleted: {
        loadTimezones()
        updateTime()
    }

    function loadTimezones() {
        // Create a map for quick lookup by timezone ID
        var timezoneMap = {}
        for (var i = 0; i < timezonesDataSource.timezones.length; i++) {
            var tz = timezonesDataSource.timezones[i]
            timezoneMap[tz.id] = tz
        }
        root.timezonesData = timezoneMap

        console.log("Loaded " + timezonesDataSource.timezones.length + " timezones")
    }

    // Get timezone offset in hours from loaded data
    function getTimezoneOffset(timezone) {
        if (root.timezonesData && root.timezonesData[timezone]) {
            return root.timezonesData[timezone].offset
        }
        return 0 // Default to UTC if timezone not found
    }

    // Get city name from timezone ID
    function getCityName(timezone) {
        if (root.timezonesData && root.timezonesData[timezone]) {
            return root.timezonesData[timezone].city
        }
        return timezone.split("/").pop().replace(/_/g, " ")
    }

    // Get current time in the selected timezone
    function getTimeInTimezone(timezone) {
        var now = new Date()

        // QML's toLocaleString doesn't properly support timezone parameter
        // Use manual calculation with UTC offset
        var utcHours = now.getUTCHours()
        var utcMinutes = now.getUTCMinutes()
        var offset = getTimezoneOffset(timezone)

        var totalMinutes = (utcHours * 60 + utcMinutes) + (offset * 60)

        while (totalMinutes < 0) totalMinutes += 24 * 60
        while (totalMinutes >= 24 * 60) totalMinutes -= 24 * 60

        var hours = Math.floor(totalMinutes / 60)
        var minutes = totalMinutes % 60

        var ampm = "AM"
        if (hours >= 12) {
            ampm = "PM"
            if (hours > 12) hours -= 12
        }
        if (hours === 0) hours = 12

        var minutesStr = minutes < 10 ? "0" + minutes : minutes.toString()
        var hoursStr = hours < 10 ? "0" + hours : hours.toString()

        return hoursStr + ":" + minutesStr + " " + ampm
    }

    // Get day of week in the selected timezone
    function getDayOfWeekInTimezone(timezone) {
        var now = new Date()

        // QML's toLocaleString doesn't properly support timezone parameter
        // Use manual calculation
        var utcDay = now.getUTCDay()
        var utcHours = now.getUTCHours()
        var offset = getTimezoneOffset(timezone)
        var totalHours = utcHours + offset

        var dayOffset = 0
        if (totalHours < 0) dayOffset = -1
        if (totalHours >= 24) dayOffset = 1

        var adjustedDay = (utcDay + dayOffset + 7) % 7
        var dayNames = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
        return dayNames[adjustedDay]
    }

    // Calculate hour difference between selected timezone and local time
    function calculateHourDifference(timezone) {
        var now = new Date()

        // Get local timezone offset in minutes (note: negative for west of UTC)
        var localOffsetMinutes = -now.getTimezoneOffset()
        var localOffsetHours = localOffsetMinutes / 60

        // Get selected timezone offset
        var selectedOffsetHours = getTimezoneOffset(timezone)

        // Calculate difference
        var diffHours = selectedOffsetHours - localOffsetHours

        // Format with sign
        var sign = diffHours >= 0 ? "+" : ""
        return sign + diffHours.toFixed(1)
    }

    // Update all time-related properties
    function updateTime() {
        // Get time in selected timezone
        var timeStr = getTimeInTimezone(timeZone)

        // Parse the time string - format: "HH:MM AM/PM"
        timeStr = timeStr.trim()

        // Extract AM/PM
        var ampmIndex = -1
        if (timeStr.toUpperCase().indexOf("AM") !== -1) {
            ampmIndex = timeStr.toUpperCase().indexOf("AM")
            amPm = "AM"
        } else if (timeStr.toUpperCase().indexOf("PM") !== -1) {
            ampmIndex = timeStr.toUpperCase().indexOf("PM")
            amPm = "PM"
        }

        if (ampmIndex !== -1) {
            // Extract time part before AM/PM
            currentTime = timeStr.substring(0, ampmIndex).trim()
        } else {
            // No AM/PM found
            currentTime = timeStr
            amPm = ""
        }

        // Split hours and minutes
        var timeParts = currentTime.split(":")
        if (timeParts.length >= 2) {
            currentHours = timeParts[0].trim()
            currentMinutes = timeParts[1].trim()

            // Ensure zero-padding
            if (currentHours.length === 1) currentHours = "0" + currentHours
            if (currentMinutes.length === 1) currentMinutes = "0" + currentMinutes
        } else {
            // Fallback
            currentHours = "12"
            currentMinutes = "00"
        }

        // Get day of week
        dayOfWeek = getDayOfWeekInTimezone(timeZone)

        // Calculate hour difference
        hourDifference = calculateHourDifference(timeZone)
    }

    // Update when timezone or city changes
    onTimeZoneChanged: updateTime()
    onCityNameChanged: updateTime()

    // City abbreviation for compact view (first 3 chars uppercase)
    readonly property string cityAbbrev: cityName.substring(0, 3).toUpperCase()

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
            spacing: compactItem.height * 0.08

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.cityAbbrev
                font.family: ndot55Font.name
                font.pixelSize: compactItem.height * 0.35
                color: nColors.textSecondary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentHours
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.5
                color: nColors.textPrimary
            }

            BlinkingSeparator {
                anchors.verticalCenter: parent.verticalCenter
                dotSize: Math.max(compactItem.height * 0.07, 3)
                dotColor: nColors.textPrimary
                dotSpacing: Math.max(compactItem.height * 0.04, 2)
                blinking: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentMinutes
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.5
                color: nColors.textPrimary
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

        Rectangle {
            id: mainRect
            anchors.fill: parent
            anchors.margins: 10
            color: nColors.background
            radius: 20
            opacity: 0.95

            // SwipeView inside the rectangle
            QQC2.SwipeView {
                id: swipeView
                anchors.fill: parent
                anchors.margins: 15
                currentIndex: 0
                clip: true
                orientation: Qt.Vertical

                // PAGE 1: Time display
                WorldClockPageOne {
                    colors: nColors
                    cityName: root.cityName
                    currentHours: root.currentHours
                    currentMinutes: root.currentMinutes
                    colonVisible: root.colonVisible
                    amPm: root.amPm
                    ndot55FontFamily: ndot55Font.name
                    ndotFontFamily: ndotFont.name
                }

                // PAGE 2: Day and hour difference
                WorldClockPageTwo {
                    colors: nColors
                    dayOfWeek: root.dayOfWeek
                    hourDifference: root.hourDifference
                    ndot55FontFamily: ndot55Font.name
                    ndotFontFamily: ndotFont.name
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
                        onClicked: swipeView.currentIndex = index
                    }
                }
            }
        }

        // Mouse wheel support for page navigation
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
}
