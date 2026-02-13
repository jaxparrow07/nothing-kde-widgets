import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configAppearance

    property alias cfg_borderEnabled: borderEnabledCheckbox.checked
    property alias cfg_borderSize: borderSizeSlider.value
    property alias cfg_pillShapeEnabled: pillShapeCheckbox.checked
    property alias cfg_themeMode: themeModeCombo.currentIndex
    property alias cfg_useSystemAccent: useSystemAccentCheckbox.checked

    ColumnLayout {
        spacing: 10

        // Border Settings Section
        Label {
            text: i18n("Border Settings")
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            CheckBox {
                id: borderEnabledCheckbox
                text: i18n("Enable Borders")
            }
        }

        Label {
            text: i18n("Adds margin around the image to reveal the dark background, creating a frame effect")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            enabled: borderEnabledCheckbox.checked

            Label {
                text: i18n("Border Size:")
                Layout.alignment: Qt.AlignLeft
            }

            Slider {
                id: borderSizeSlider
                from: 0
                to: 50
                stepSize: 1
                Layout.fillWidth: true
            }

            Label {
                text: Math.round(borderSizeSlider.value) + "px"
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // Shape Settings Section
        Label {
            text: i18n("Shape Settings")
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            CheckBox {
                id: pillShapeCheckbox
                text: i18n("Pill Shape")
            }
        }

        Label {
            text: i18n("Automatically creates a circle (if square) or pill shape (if rectangular). When disabled, uses standard rounded corners.")
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

        // Theme Section
        Label {
            text: i18n("Theme")
            font.bold: true
            font.pointSize: 11
        }

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
