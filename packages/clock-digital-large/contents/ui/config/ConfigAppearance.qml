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
                text: "Font Style:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: fontStyleCombo
                model: ["Dotted", "Dot Matrix", "Serif", "Segmented", "Segmented Sharp"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Dotted: Bigger dots, cleaner look"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Dot Matrix: Nothing's iconic dot matrix font"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Serif: Nothing's new serif font"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Segmented: Subway board inspired font that nothing designed"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Segmented Sharp: Segmented but sharper"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "NOTE: Segmented fonts don't have separator (:)"
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
                text: "Show Date"
            }
        }

        Label {
            text: "Display the current date above the time (e.g., \"Thu, 31 Jan\")"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            CheckBox {
                id: use24HourCheckbox
                text: "Use 24-Hour Format"
            }
        }

        Label {
            text: "Show time in 24-hour format (e.g., 14:30) instead of 12-hour format (e.g., 2:30)"
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
                text: "Use Darker Font Color"
            }
        }

        Label {
            text: "Use a darker font color for better visibility on lighter backgrounds"
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
