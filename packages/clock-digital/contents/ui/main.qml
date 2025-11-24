import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property bool use24HourFormat: plasmoid.configuration.use24HourFormat

    property string currentHours: ""
    property string currentMinutes: ""
    property bool colonVisible: true

    // Individual digits
    property string hoursDigit1: "0"
    property string hoursDigit2: "0"
    property string minutesDigit1: "0"
    property string minutesDigit2: "0"

    // Load the ndot font
    FontLoader {
        id: ndotFont
        source: Qt.resolvedUrl("../fonts/ndot.ttf")
    }

    // Timer to update time every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: updateTime()
        Component.onCompleted: updateTime()
    }

    // Timer to blink the colon separator (every 500ms)
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.colonVisible = !root.colonVisible
    }

    function updateTime() {
        var now = new Date()
        var hours = now.getHours()

        // Convert to 12-hour format if needed
        if (!root.use24HourFormat) {
            hours = hours % 12
            if (hours === 0) hours = 12
        }

        var minutes = now.getMinutes()

        // Format as strings with zero-padding
        var hoursStr = hours < 10 ? "0" + hours : hours.toString()
        var minutesStr = minutes < 10 ? "0" + minutes : minutes.toString()

        root.currentHours = hoursStr
        root.currentMinutes = minutesStr

        // Split into individual digits
        root.hoursDigit1 = hoursStr.length > 1 ? hoursStr[0] : "0"
        root.hoursDigit2 = hoursStr.length > 1 ? hoursStr[1] : hoursStr[0]
        root.minutesDigit1 = minutesStr[0]
        root.minutesDigit2 = minutesStr[1]
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 100

        readonly property real dotSize: Math.min(height * 0.075,10)

        // Calculate pill-shape radius based on aspect ratio
        readonly property real calculatedRadius: {
            var w = width
            var h = height
            var aspectRatio = w / h

            // If width is twice the height (or more), make it pill-shaped
            if (aspectRatio >= 1.8) {
                return h / 2
            }

            // Otherwise use standard radius
            return 20
        }

        // Determine if we should use pill mode (horizontal layout)
        readonly property bool isPillMode: (width / height) >= 1.8

        Rectangle {
            id: mainRect
            anchors.fill: parent
            anchors.margins: 10
            color: "#1a1a1a"
            radius: parent.calculatedRadius
            opacity: 0.95

            // Vertical layout (default square mode)
            Item {
                anchors.fill: parent
                visible: !parent.parent.isPillMode

                Column {
                    anchors.centerIn: parent
                    spacing: 5

                    // Hours display (separated digits)
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.hoursDigit1
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.hoursDigit2
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    // Minutes display (separated digits)
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 12

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.minutesDigit1
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.minutesDigit2
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: "#ffffff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Horizontal layout (pill mode)
            Item {
                anchors.fill: parent
                visible: parent.parent.isPillMode

                Row {
                    anchors.centerIn: parent
                    spacing: 12

                    // Hours digit 1
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.hoursDigit1
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Hours digit 2
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.hoursDigit2
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Blinking circles separator
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Math.min(parent.parent.height * 0.1, 8)

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min(parent.parent.parent.height * 0.07, 10)
                            height: width
                            radius: width / 2
                            color: "#ffffff"
                            opacity: root.colonVisible ? 1.0 : 0.3

                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min(parent.parent.parent.height * 0.07, 10)
                            height: width
                            radius: width / 2
                            color: "#ffffff"
                            opacity: root.colonVisible ? 1.0 : 0.3

                            Behavior on opacity {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }

                    // Minutes digit 1
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.minutesDigit1
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Minutes digit 2
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.minutesDigit2
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: "#ffffff"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
