import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: generalPage

    property alias cfg_deviceType: deviceTypeCombo.currentValue
    property alias cfg_updateInterval: updateIntervalSpin.value
    property alias cfg_themeMode: themeModeCombo.currentIndex
    property string cfg_customIconMappings: ""
    property string cfg_deviceHistory: ""

    // Helper to parse JSON safely
    function parseCustomMappings() {
        if (!cfg_customIconMappings) return []
        try {
            return JSON.parse(cfg_customIconMappings)
        } catch (e) {
            return []
        }
    }

    function saveCustomMappings(mappings) {
        cfg_customIconMappings = JSON.stringify(mappings)
    }

    function parseDeviceHistory() {
        if (!cfg_deviceHistory) return []
        try {
            return JSON.parse(cfg_deviceHistory)
        } catch (e) {
            return []
        }
    }

    // Theme Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Theme")
    }

    QQC2.ComboBox {
        id: themeModeCombo
        Kirigami.FormData.label: i18n("Theme:")
        model: [i18n("Dark"), i18n("Light"), i18n("Follow System")]
    }

    // Basic Settings Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Basic Settings")
    }

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

    // Custom Icon Mappings Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Custom Device Icons")
    }

    ColumnLayout {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Icon Mappings:")
        Kirigami.FormData.buddyFor: addMappingButton

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Add custom icon mappings based on device name patterns")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
        }

        // List of custom mappings
        Repeater {
            id: mappingsRepeater
            model: ListModel {
                id: mappingsModel
            }

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10

                property int delegateIndex: index

                QQC2.TextField {
                    id: patternField
                    Layout.preferredWidth: 150
                    placeholderText: i18n("Device name pattern")
                    text: model.pattern
                    onTextChanged: {
                        if (text !== model.pattern) {
                            mappingsModel.setProperty(delegateIndex, "pattern", text)
                            updateConfig()
                        }
                    }
                }

                QQC2.Label {
                    text: "→"
                }

                QQC2.ComboBox {
                    id: iconCombo
                    Layout.preferredWidth: 150

                    property var iconList: [
                        "earbuds",
                        "headset",
                        "mouse",
                        "keyboard",
                        "watch",
                        "computer",
                        "speaker",
                        "controller"
                    ]

                    model: iconList

                    Component.onCompleted: {
                        updateCurrentIndex()
                    }

                    Connections {
                        target: mappingsModel
                        function onDataChanged() {
                            iconCombo.updateCurrentIndex()
                        }
                    }

                    function updateCurrentIndex() {
                        if (delegateIndex >= mappingsModel.count) return
                        var iconValue = mappingsModel.get(delegateIndex).icon
                        for (var i = 0; i < iconList.length; i++) {
                            if (iconList[i] === iconValue) {
                                currentIndex = i
                                return
                            }
                        }
                        currentIndex = 0
                    }

                    onActivated: {
                        mappingsModel.setProperty(delegateIndex, "icon", iconList[currentIndex])
                        updateConfig()
                    }
                }

                QQC2.Button {
                    icon.name: "edit-delete"
                    onClicked: {
                        mappingsModel.remove(delegateIndex)
                        updateConfig()
                    }
                }
            }
        }

        QQC2.Button {
            id: addMappingButton
            text: i18n("Add Mapping")
            icon.name: "list-add"
            onClicked: {
                mappingsModel.append({
                    pattern: "",
                    icon: "earbuds"
                })
            }
        }
    }

    // Previously Connected Devices Section
    Item {
        Kirigami.FormData.isSection: true
        Kirigami.FormData.label: i18n("Device History")
    }

    ColumnLayout {
        Layout.fillWidth: true
        Kirigami.FormData.label: i18n("Previously Connected:")

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("Bluetooth devices that have been connected to this system")
            wrapMode: Text.WordWrap
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
        }

        Repeater {
            id: historyRepeater
            model: ListModel {
                id: historyModel
            }

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Kirigami.Icon {
                    source: "network-bluetooth"
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    text: model.name
                    elide: Text.ElideRight
                }

                QQC2.Label {
                    text: model.address
                    opacity: 0.6
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }

                QQC2.Button {
                    text: i18n("Quick Add")
                    icon.name: "list-add"
                    visible: !hasMapping(model.name)
                    onClicked: {
                        mappingsModel.append({
                            pattern: model.name,
                            icon: "earbuds"
                        })
                        updateConfig()
                    }
                }
            }
        }

        QQC2.Label {
            Layout.fillWidth: true
            text: i18n("No devices found in history")
            visible: historyModel.count === 0
            opacity: 0.6
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Helper functions
    function hasMapping(deviceName) {
        for (var i = 0; i < mappingsModel.count; i++) {
            if (mappingsModel.get(i).pattern === deviceName) {
                return true
            }
        }
        return false
    }

    function updateConfig() {
        var mappings = []
        for (var i = 0; i < mappingsModel.count; i++) {
            var item = mappingsModel.get(i)
            if (item.pattern) {  // Only save non-empty patterns
                mappings.push({
                    pattern: item.pattern,
                    icon: item.icon
                })
            }
        }
        saveCustomMappings(mappings)
    }

    function loadConfig() {
        // Load custom mappings
        mappingsModel.clear()
        var mappings = parseCustomMappings()
        for (var i = 0; i < mappings.length; i++) {
            mappingsModel.append(mappings[i])
        }

        // Load device history
        historyModel.clear()
        var history = parseDeviceHistory()
        for (var j = 0; j < history.length; j++) {
            historyModel.append(history[j])
        }
    }

    Component.onCompleted: {
        loadConfig()
    }
}
