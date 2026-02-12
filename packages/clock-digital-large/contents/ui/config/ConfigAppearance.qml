import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configAppearance

    property alias cfg_fontStyle: fontStyleCombo.currentIndex
    property alias cfg_showDate: showDateCheckbox.checked
    property alias cfg_use24HourFormat: use24HourCheckbox.checked
    property alias cfg_useDarkerFont: useDarkerFontCheckbox.checked
    property alias cfg_themeMode: themeModeCombo.currentIndex

    ColumnLayout {
        spacing: 10

        RowLayout {
            Label {
                text: i18n("Font Style:")
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: fontStyleCombo
                model: [i18n("Dotted"), i18n("Dot Matrix"), i18n("Serif"), i18n("Segmented"), i18n("Segmented Sharp")]
                Layout.fillWidth: true
            }
        }

        Label {
            text: i18n("Dotted: Bigger dots, cleaner look")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: i18n("Dot Matrix: Nothing's iconic dot matrix font")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: i18n("Serif: Nothing's new serif font")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: i18n("Segmented: Subway board inspired font that nothing designed")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: i18n("Segmented Sharp: Segmented but sharper")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: i18n("NOTE: Segmented fonts don't have separator (:)")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            Layout.topMargin: 4
            wrapMode: Text.WordWrap
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        RowLayout {
            CheckBox {
                id: showDateCheckbox
                text: i18n("Show Date")
            }
        }

        Label {
            text: i18n("Display the current date above the time (e.g., \"Thu, 31 Jan\")")
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            CheckBox {
                id: use24HourCheckbox
                text: i18n("Use 24-Hour Format")
            }
        }

        Label {
            text: i18n("Show time in 24-hour format (e.g., 14:30) instead of 12-hour format (e.g., 2:30)")
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
            CheckBox {
                id: useDarkerFontCheckbox
                text: i18n("Use Darker Font Color")
            }
        }

        Label {
            text: i18n("Use a darker font color for better visibility on lighter backgrounds")
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
