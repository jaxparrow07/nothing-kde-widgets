import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configImage

    property alias cfg_imagePath: imagePathField.text
    property alias cfg_imageFillMode: imageFillModeCombo.currentIndex
    property alias cfg_grayscaleEnabled: grayscaleCheckbox.checked

    ColumnLayout {
        spacing: 10

        // Image Source Section
        Label {
            text: "Image Source"
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            TextField {
                id: imagePathField
                Layout.fillWidth: true
                placeholderText: "Select an image file..."
                readOnly: true
            }

            Button {
                text: "Browse..."
                onClicked: fileDialog.open()
            }
        }

        Label {
            text: "Select a photo to display in the widget (PNG, JPG, JPEG, WebP)"
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

        // Image Fit Mode Section
        Label {
            text: "Image Fit Mode"
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Label {
                text: "Fit Mode:"
                Layout.alignment: Qt.AlignLeft
            }

            ComboBox {
                id: imageFillModeCombo
                model: ["Crop (Fill Frame)", "Fit (Show All)", "Stretch"]
                Layout.fillWidth: true
            }
        }

        Label {
            text: "Crop: Fills the frame completely, may crop parts of the image\nFit: Shows the entire image, may have letterboxing\nStretch: Fills frame completely, may distort the image"
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

        // Effects Section
        Label {
            text: "Effects"
            font.bold: true
            font.pointSize: 11
        }

        RowLayout {
            CheckBox {
                id: grayscaleCheckbox
                text: "Grayscale"
            }
        }

        Label {
            text: "Convert the image to black and white (grayscale)"
            font.pointSize: 9
            opacity: 0.7
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        Item {
            Layout.fillHeight: true
        }
    }

    FileDialog {
        id: fileDialog
        title: "Select an Image"
        nameFilters: ["Image files (*.png *.jpg *.jpeg *.webp *.bmp *.gif)"]
        onAccepted: {
            imagePathField.text = fileDialog.selectedFile
        }
    }
}
