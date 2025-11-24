import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configAppearance

    property alias cfg_clockStyle: clockStyleCombo.currentIndex
    property alias cfg_smoothHands: smoothHandsCheckbox.checked 
    
    ColumnLayout {
        spacing: 10

        RowLayout {
            Label {
                text: "Clock Style:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: clockStyleCombo
                model: ["Swiss Railway (with markers)", "Minimalist (clean)"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Swiss Railway: Classic design with hour and minute markers, and a traditional red second hand"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Label {
            text: "Minimalist: Clean design with no markers, rounded hands, and a red dot as the second hand"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        RowLayout {
            CheckBox {
                id: smoothHandsCheckbox
                text: "Smooth Moving Second Hand"
            }
        }

        Label {
            text: "Update second hand every 50ms instead of 1000ms ( 1s ) for a smoother motion"
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
