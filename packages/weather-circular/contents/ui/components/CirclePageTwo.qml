import QtQuick

// Page 2: Temperature only
Item {
    required property string currentTemp
    required property bool isLoading
    required property QtObject colors

    CircleTemperature {
        anchors.centerIn: parent
        width: parent.width * 0.8
        height: parent.height * 0.8
        temperature: parent.currentTemp
        isLoading: parent.isLoading
        textScale: 0.4
        colors: parent.colors
    }
}
