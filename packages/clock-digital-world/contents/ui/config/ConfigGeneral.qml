import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import "." as Config

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_cityName: cityNameField.text
    property string cfg_timeZone
    property alias cfg_themeMode: themeModeCombo.currentIndex

    Config.TimezonesData {
        id: timezonesData
    }

    Component.onCompleted: {
        loadTimezones()
    }

    function loadTimezones() {
        // Populate the model from embedded data
        timezoneModel.clear()
        for (var i = 0; i < timezonesData.timezones.length; i++) {
            var tz = timezonesData.timezones[i]
            var offsetStr = formatOffset(tz.offset)
            var displayName = tz.city + ", " + tz.country + " (" + offsetStr + ")"
            timezoneModel.append({
                "display": displayName,
                "value": tz.id,
                "city": tz.city
            })
        }

        // Find and select the current timezone
        selectCurrentTimezone()

        console.log("Loaded " + timezonesData.timezones.length + " timezones for configuration")
    }

    function formatOffset(offset) {
        var prefix = offset >= 0 ? "UTC+" : "UTC"
        if (offset === 0) return "UTC+0"

        var absOffset = Math.abs(offset)
        var hours = Math.floor(absOffset)
        var minutes = Math.round((absOffset - hours) * 60)

        if (minutes === 0) {
            return prefix + hours
        } else {
            return prefix + hours + ":" + (minutes < 10 ? "0" : "") + minutes
        }
    }

    function selectCurrentTimezone() {
        for (var i = 0; i < timezoneModel.count; i++) {
            if (timezoneModel.get(i).value === cfg_timeZone) {
                timezoneCombo.currentIndex = i
                return
            }
        }
        // Default to first timezone if not found
        if (timezoneModel.count > 0) {
            timezoneCombo.currentIndex = 0
        }
    }

    ColumnLayout {
        spacing: 10

        Label {
            text: "City Name:"
        }

        TextField {
            id: cityNameField
            placeholderText: "e.g., Austin, New York, Tokyo"
            Layout.fillWidth: true
        }

        Label {
            text: "Enter the city name to display on the widget."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        Label {
            text: "Time Zone:"
        }

        ComboBox {
            id: timezoneCombo
            Layout.fillWidth: true
            textRole: "display"

            model: ListModel {
                id: timezoneModel
            }

            onCurrentIndexChanged: {
                if (currentIndex >= 0 && currentIndex < timezoneModel.count) {
                    cfg_timeZone = timezoneModel.get(currentIndex).value
                    // Auto-fill city name if empty
                    if (!cfg_cityName || cfg_cityName === "") {
                        cfg_cityName = timezoneModel.get(currentIndex).city
                    }
                }
            }
        }

        Label {
            text: "Select a timezone from the list above. The widget will display the time for the selected location."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        RowLayout {
            Label {
                text: "Theme:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: themeModeCombo
                model: ["Dark", "Light", "Follow System"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Dark: Nothing's signature dark aesthetic. Light: Nothing's light palette. Follow System: Uses your KDE color scheme."
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
