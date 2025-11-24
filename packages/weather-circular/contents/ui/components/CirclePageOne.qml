import QtQuick
import QtQuick.Controls as QQC2

// Page 1: Weather icon only
Item {
    required property string weatherIconPath
    required property bool isLoading
    required property string errorMessage

    CircleWeatherIcon {
        anchors.centerIn: parent
        width: parent.width * 0.6
        height: parent.height * 0.6
        weatherIconPath: parent.weatherIconPath
        isLoading: parent.isLoading
        iconScale: 1.0
    }

    // Loading indicator
    QQC2.BusyIndicator {
        anchors.centerIn: parent
        width: 48
        height: 48
        running: isLoading
        visible: isLoading
    }

    // Error message
    Text {
        visible: errorMessage !== "" && !isLoading
        anchors.centerIn: parent
        text: errorMessage
        font.pixelSize: parent.width * 0.08
        color: "#ff4444"
        opacity: 0.9
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 0.7
    }
}
