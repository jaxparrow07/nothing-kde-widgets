import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configAppearance

    property alias cfg_borderEnabled: borderEnabledCheckbox.checked
    property alias cfg_borderSize: borderSizeSlider.value
    property alias cfg_pillShapeEnabled: pillShapeCheckbox.checked

    ColumnLayout {
        spacing: 10

        // Border Settings Section
        Label {
            text: "Border Settings"
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            CheckBox {
                id: borderEnabledCheckbox
                text: "Enable Borders"
            }
        }

        Label {
            text: "Adds margin around the image to reveal the dark background, creating a frame effect"
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
                text: "Border Size:"
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
            text: "Shape Settings"
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            CheckBox {
                id: pillShapeCheckbox
                text: "Pill Shape"
            }
        }

        Label {
            text: "Automatically creates a circle (if square) or pill shape (if rectangular). When disabled, uses standard rounded corners."
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
