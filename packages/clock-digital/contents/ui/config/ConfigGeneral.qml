import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configGeneral

    property alias cfg_use24HourFormat: use24HourCheckbox.checked

    ColumnLayout {
        spacing: 20

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

        Item {
            Layout.fillHeight: true
        }
    }
}
