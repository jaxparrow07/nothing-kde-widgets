import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import "." as Config

KCM.SimpleKCM {
    id: configGeneral

    property int cfg_widgetVariant
    property alias cfg_use24HourFormat: use24HourCheckbox.checked
    property alias cfg_themeMode: themeModeCombo.currentIndex
    property alias cfg_useSystemAccent: useSystemAccentCheckbox.checked
    property alias cfg_cityName: cityNameField.text
    property string cfg_timeZone

    Config.TimezonesData {
        id: timezonesData
    }

    Component.onCompleted: {
        loadTimezones()
    }

    function loadTimezones() {
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
        selectCurrentTimezone()
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
        if (timezoneModel.count > 0) {
            timezoneCombo.currentIndex = 0
        }
    }

    ColumnLayout {
        spacing: 10

        // --- Style selection ---
        Label {
            text: i18n("Style:")
            font.weight: Font.Medium
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            spacing: 10

            // Digital Clock card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 0 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 0 ? 2 : 1
                border.color: cfg_widgetVariant === 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/digital.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Digital Clock")
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 0
                }
            }

            // World Clock card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 1 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 1 ? 2 : 1
                border.color: cfg_widgetVariant === 1 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/world.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("World Clock")
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- Digital clock settings (variant 0) ---
        RowLayout {
            visible: cfg_widgetVariant === 0
            CheckBox {
                id: use24HourCheckbox
                text: i18n("Use 24-Hour Format")
            }
        }

        Label {
            visible: cfg_widgetVariant === 0
            text: i18n("Show time in 24-hour format (e.g., 14:30) instead of 12-hour format (e.g., 2:30)")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            visible: cfg_widgetVariant === 0
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- World clock settings (variant 1) ---
        Label {
            visible: cfg_widgetVariant === 1
            text: i18n("City Name:")
        }

        TextField {
            id: cityNameField
            visible: cfg_widgetVariant === 1
            placeholderText: i18n("e.g., Austin, New York, Tokyo")
            Layout.fillWidth: true
        }

        Label {
            visible: cfg_widgetVariant === 1
            text: i18n("Enter the city name to display on the widget.")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            visible: cfg_widgetVariant === 1
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        Label {
            visible: cfg_widgetVariant === 1
            text: i18n("Time Zone:")
        }

        ComboBox {
            id: timezoneCombo
            visible: cfg_widgetVariant === 1
            Layout.fillWidth: true
            textRole: "display"

            model: ListModel {
                id: timezoneModel
            }

            onActivated: {
                if (currentIndex >= 0 && currentIndex < timezoneModel.count) {
                    cfg_timeZone = timezoneModel.get(currentIndex).value
                    cfg_cityName = timezoneModel.get(currentIndex).city
                }
            }
        }

        Label {
            visible: cfg_widgetVariant === 1
            text: i18n("Select a timezone from the list above. The widget will display the time for the selected location.")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Rectangle {
            visible: cfg_widgetVariant === 1
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- Theme (always visible) ---
        RowLayout {
            Label {
                text: i18n("Theme:")
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: themeModeCombo
                model: [i18n("Dark"), i18n("Light"), i18n("Follow System")]
                Layout.fillWidth: true
            }
        }

        Label {
            text: i18n("Dark: Nothing's signature dark aesthetic. Light: Nothing's light palette. Follow System: Matches your KDE dark/light scheme.")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            CheckBox {
                id: useSystemAccentCheckbox
                text: i18n("Use system accent color")
            }
        }

        Label {
            text: i18n("Replace Nothing's red accent with your KDE system highlight color while keeping the Nothing aesthetic.")
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
