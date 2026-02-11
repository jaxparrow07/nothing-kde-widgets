import QtQuick

// Page 3: High/Low temperatures
Item {
    required property string highTemp
    required property string lowTemp
    required property bool isLoading
    required property QtObject colors

    CircleHighLow {
        anchors.centerIn: parent
        width: parent.width * 0.7
        height: parent.height * 0.7
        highTemp: parent.highTemp
        lowTemp: parent.lowTemp
        isLoading: parent.isLoading
        textScale: 0.25
        spacing: 12
        colors: parent.colors
    }
}
