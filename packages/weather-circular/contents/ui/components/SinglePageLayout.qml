import QtQuick
import QtQuick.Layouts

// Single-page grid layout
Item {
    id: root

    required property string weatherIconPath
    required property string condition
    required property string currentTemp
    required property string highTemp
    required property string lowTemp
    required property bool isLoading

    // Main container with margins (like other widgets)
    Item {
        anchors.fill: parent
        anchors.margins: 10

        // Calculate grid dimensions
        readonly property real cellWidth: width / 2
        readonly property real cellHeight: height / 2
        readonly property real spacing: 8

        // Top pill shape (spans 2 columns)
        Rectangle {
            id: topPill
            x: parent.spacing / 2
            y: parent.spacing / 2
            width: parent.width - parent.spacing
            height: parent.cellHeight - parent.spacing
            color: "#1a1a1a"
            radius: height / 2
            opacity: 0.95

            RowLayout {
                anchors.fill: parent
                anchors.margins: parent.height * 0.15
                spacing: 10

                // Weather icon
                CircleWeatherIcon {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.height
                    weatherIconPath: root.weatherIconPath
                    isLoading: root.isLoading
                    iconScale: 0.8
                }

                // Condition text
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.condition
                    font.pixelSize: parent.height * 0.22
                    font.weight: Font.Light
                    color: "#ffffff"
                    opacity: root.isLoading ? 0.5 : 0.95
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    
                }
            }
        }

        // Bottom-left circle (current temperature)
        Rectangle {
            id: bottomLeftCircle
            x: parent.spacing / 2
            y: parent.cellHeight + parent.spacing / 2
            width: parent.cellWidth - parent.spacing
            height: parent.cellHeight - parent.spacing
            color: "#1a1a1a"
            radius: width / 2
            opacity: 0.95

            CircleTemperature {
                anchors.centerIn: parent
                width: parent.width * 0.8
                height: parent.height * 0.8
                temperature: root.currentTemp
                isLoading: root.isLoading
                textScale: 0.35
            }
        }

        // Bottom-right circle (high/low)
        Rectangle {
            id: bottomRightCircle
            x: parent.cellWidth + parent.spacing / 2
            y: parent.cellHeight + parent.spacing / 2
            width: parent.cellWidth - parent.spacing
            height: parent.cellHeight - parent.spacing
            color: "#1a1a1a"
            radius: width / 2
            opacity: 0.95

            CircleHighLow {
                anchors.centerIn: parent
                width: parent.width * 0.7
                height: parent.height * 0.7
                highTemp: root.highTemp
                lowTemp: root.lowTemp
                isLoading: root.isLoading
                textScale: 0.2
                spacing: 6
            }
        }
    }
}
