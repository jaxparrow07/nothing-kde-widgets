import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

// Square layout Page 1: Current temperature with icon
Item {
    id: root

    // Required properties
    required property QtObject colors
    required property string currentTemp
    required property string weatherIconPath
    required property bool isLoading
    required property string errorMessage
    required property string location

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 0

        // Temperature display
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 15
            text: currentTemp + "°"
            font.pixelSize: parent.width * 0.20
            font.weight: Font.Normal
            color: root.colors.textPrimary
            opacity: isLoading ? 0.5 : 1.0
        }

        // Weather icon
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Kirigami.Icon {
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: parent.height * 0.9
                source: weatherIconPath
                color: root.colors.iconColor
                isMask: true
                visible: !isLoading && errorMessage === ""
            }

            // Loading indicator
            QQC2.BusyIndicator {
                anchors.centerIn: parent
                width: 48
                height: 48
                running: isLoading
                visible: isLoading
            }
        }

        // Location name
        Text {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.bottomMargin: 12
            Layout.topMargin: 10
            text: errorMessage !== "" ? errorMessage : location
            font.pixelSize: parent.width * 0.11
            color: errorMessage !== "" ? root.colors.accent : root.colors.textPrimary
            opacity: 0.9
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.weight: Font.Light
        }
    }
}
