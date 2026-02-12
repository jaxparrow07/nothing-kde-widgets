import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: configAppearance

    property int cfg_widgetVariant
    property alias cfg_smoothHands: smoothHandsCheckbox.checked
    property alias cfg_themeMode: themeModeCombo.currentIndex

    ColumnLayout {
        spacing: 10

        // --- Style selection ---
        Label {
            text: "Style:"
            font.weight: Font.Medium
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            spacing: 10

            // Swiss Railway card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 0 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 0 ? 2 : 1
                border.color: cfg_widgetVariant === 0 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/swiss.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Swiss Railway"
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 0
                }
            }

            // Minimalist card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: cfg_widgetVariant === 1 ? Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.15) : "transparent"
                radius: 10
                border.width: cfg_widgetVariant === 1 ? 2 : 1
                border.color: cfg_widgetVariant === 1 ? Kirigami.Theme.highlightColor : Kirigami.Theme.disabledTextColor

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        source: Qt.resolvedUrl("../previews/minimalist.png")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Minimalist"
                        font.pointSize: 9
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: cfg_widgetVariant = 1
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- Smooth hands ---
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

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#333333"
            opacity: 0.3
        }

        // --- Theme ---
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
