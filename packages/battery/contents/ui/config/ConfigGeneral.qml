import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: generalPage

    property alias cfg_deviceType: deviceTypeCombo.currentValue
    property alias cfg_updateInterval: updateIntervalSpin.value

    QQC2.ComboBox {
        id: deviceTypeCombo
        Kirigami.FormData.label: i18n("Device Type:")
        textRole: "text"
        valueRole: "value"
        model: [
            { text: i18n("Laptop"), value: "laptop" },
            { text: i18n("Desktop PC"), value: "computer" }
        ]

        Component.onCompleted: {
            for (var i = 0; i < model.length; i++) {
                if (model[i].value === plasmoid.configuration.deviceType) {
                    currentIndex = i
                    break
                }
            }
        }
    }

    QQC2.SpinBox {
        id: updateIntervalSpin
        Kirigami.FormData.label: i18n("Update Interval (ms):")
        from: 1000
        to: 60000
        stepSize: 1000
        editable: true
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    QQC2.Label {
        Layout.fillWidth: true
        text: i18n("Battery widget displays current battery level with a circular progress indicator.")
        wrapMode: Text.WordWrap
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        opacity: 0.6
    }
}
