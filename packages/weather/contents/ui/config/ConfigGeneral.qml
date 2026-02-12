import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: configGeneral

    property int cfg_widgetVariant
    property alias cfg_location: locationField.text
    property alias cfg_temperatureUnit: temperatureUnitCombo.currentIndex
    property alias cfg_themeMode: themeModeCombo.currentIndex

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
            spacing: 8

            // Weather Full card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 0 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 0 ? 2 : 1
                border.color: cfg_widgetVariant === 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/weather-full.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Full")
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 0
                }
            }

            // Circular Single card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 1 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 1 ? 2 : 1
                border.color: cfg_widgetVariant === 1 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/circular-single.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Circular")
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 1
                }
            }

            // Circular Multi card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 2 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 2 ? 2 : 1
                border.color: cfg_widgetVariant === 2 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/circular-multi.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: i18n("Circle Pages")
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 2
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- Location ---
        RowLayout {
            Label {
                text: i18n("Location:")
                Layout.alignment: Qt.AlignLeft
            }

            TextField {
                id: locationField
                placeholderText: i18n("e.g., New York, Chennai, Villupuram")
                Layout.fillWidth: true
            }
        }

        Label {
            text: i18n("Enter a city name for weather information. The widget will automatically find the coordinates.")
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

        // --- Temperature Unit ---
        RowLayout {
            Label {
                text: i18n("Temperature Unit:")
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: temperatureUnitCombo
                model: [i18n("Celsius (\u00B0C)"), i18n("Fahrenheit (\u00B0F)")]
                Layout.fillWidth: true
            }
        }

        Label {
            text: i18n("Choose between Celsius and Fahrenheit for temperature display.")
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

        // --- Theme ---
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
            text: i18n("Dark: Nothing's signature dark aesthetic. Light: Nothing's light palette. Follow System: Uses your KDE color scheme.")
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
