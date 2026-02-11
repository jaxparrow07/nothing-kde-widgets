import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import "components"

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
    }

    property bool use24HourFormat: plasmoid.configuration.use24HourFormat

    property string currentHours: ""
    property string currentMinutes: ""

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

    compactRepresentation: Item {
        id: compactItem

        states: [
            State {
                name: "horizontalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Horizontal

                PropertyChanges {
                    compactItem.Layout.fillHeight: true
                    compactItem.Layout.fillWidth: false
                    compactItem.Layout.minimumWidth: compactRow.implicitWidth + compactItem.height * 0.4
                    compactItem.Layout.maximumWidth: compactItem.Layout.minimumWidth
                }
            },
            State {
                name: "verticalPanel"
                when: Plasmoid.formFactor === PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.fillHeight: false
                    compactItem.Layout.fillWidth: true
                    compactItem.Layout.minimumHeight: compactRow.implicitHeight + compactItem.width * 0.4
                    compactItem.Layout.maximumHeight: compactItem.Layout.minimumHeight
                }
            },
            State {
                name: "desktop"
                when: Plasmoid.formFactor !== PlasmaCore.Types.Horizontal && Plasmoid.formFactor !== PlasmaCore.Types.Vertical

                PropertyChanges {
                    compactItem.Layout.minimumWidth: compactRow.implicitWidth + 8
                    compactItem.Layout.minimumHeight: compactRow.implicitHeight + 8
                }
            }
        ]

        Row {
            id: compactRow
            anchors.centerIn: parent
            spacing: 4

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentHours
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.55
                color: nColors.textPrimary
            }

            BlinkingSeparator {
                anchors.verticalCenter: parent.verticalCenter
                dotSize: Math.max(compactItem.height * 0.08, 3)
                dotColor: nColors.textPrimary
                dotSpacing: Math.max(compactItem.height * 0.04, 2)
                blinking: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentMinutes
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.55
                color: nColors.textPrimary
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
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
            color: nColors.background
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
                            color: nColors.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.hoursDigit2
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: nColors.textPrimary
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
                            color: nColors.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            width: Math.min(parent.parent.parent.width * 0.2, parent.parent.parent.height * 0.15)
                            text: root.minutesDigit2
                            font.family: ndotFont.name
                            font.pixelSize: Math.min(parent.parent.parent.width * 0.25, parent.parent.parent.height * 0.2)
                            color: nColors.textPrimary
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
                        color: nColors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Hours digit 2
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.hoursDigit2
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: nColors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Blinking circles separator
                    BlinkingSeparator {
                        anchors.verticalCenter: parent.verticalCenter
                        dotSize: Math.min(parent.parent.height * 0.07, 10)
                        dotColor: nColors.textPrimary
                        dotSpacing: Math.min(parent.parent.height * 0.1, 8)
                        blinking: true
                    }

                    // Minutes digit 1
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.minutesDigit1
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: nColors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Minutes digit 2
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.minutesDigit2
                        font.family: ndotFont.name
                        font.pixelSize: Math.min(parent.parent.width * 0.15, parent.parent.height * 0.5)
                        color: nColors.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }
}
