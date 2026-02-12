import QtQuick
import "../components"

Item {
    id: fullItem

    required property QtObject colors
    required property string hoursDigit1
    required property string hoursDigit2
    required property string minutesDigit1
    required property string minutesDigit2
    required property string ndotFontFamily
    required property int currentSeconds

    Layout.preferredWidth: 200
    Layout.preferredHeight: 200
    Layout.minimumWidth: 200
    Layout.minimumHeight: 200
    Layout.maximumWidth: 200
    Layout.maximumHeight: 200

    readonly property real dotSize: Math.min(height * 0.075, 10)

    readonly property real calculatedRadius: {
        var w = width
        var h = height
        var aspectRatio = w / h
        if (aspectRatio >= 1.8) {
            return h / 2
        }
        return 20
    }

    readonly property bool isPillMode: (width / height) >= 1.8

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 10
        color: fullItem.colors.background
        radius: fullItem.calculatedRadius
        opacity: 0.95

        // Vertical layout (default square mode)
        Item {
            anchors.fill: parent
            visible: !fullItem.isPillMode

            Column {
                anchors.centerIn: parent
                spacing: 5

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Text {
                        width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                        text: fullItem.hoursDigit1
                        font.family: fullItem.ndotFontFamily
                        font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                        color: fullItem.colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                        text: fullItem.hoursDigit2
                        font.family: fullItem.ndotFontFamily
                        font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                        color: fullItem.colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Text {
                        width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                        text: fullItem.minutesDigit1
                        font.family: fullItem.ndotFontFamily
                        font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                        color: fullItem.colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                        text: fullItem.minutesDigit2
                        font.family: fullItem.ndotFontFamily
                        font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                        color: fullItem.colors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }

        // Horizontal layout (pill mode)
        Item {
            anchors.fill: parent
            visible: fullItem.isPillMode

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: fullItem.hoursDigit1
                    font.family: fullItem.ndotFontFamily
                    font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                    color: fullItem.colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: fullItem.hoursDigit2
                    font.family: fullItem.ndotFontFamily
                    font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                    color: fullItem.colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                BlinkingSeparator {
                    anchors.verticalCenter: parent.verticalCenter
                    dotSize: Math.min(parent.parent.height * 0.07, 10)
                    dotColor: fullItem.colors.textPrimary
                    dotSpacing: Math.min(parent.parent.height * 0.1, 8)
                    seconds: fullItem.currentSeconds
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: fullItem.minutesDigit1
                    font.family: fullItem.ndotFontFamily
                    font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                    color: fullItem.colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: fullItem.minutesDigit2
                    font.family: fullItem.ndotFontFamily
                    font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                    color: fullItem.colors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
