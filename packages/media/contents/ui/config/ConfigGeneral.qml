import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_themeMode: themeModeCombo.currentIndex

    ColumnLayout {
        spacing: 10

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
