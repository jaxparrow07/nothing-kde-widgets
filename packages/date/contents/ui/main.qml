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

    property string currentDayName: ""
    property string currentDate: ""

    // Load the serif font
    FontLoader {
        id: serifFont
        source: Qt.resolvedUrl("../fonts/serif.otf")
    }
    FontLoader {
        id: serifLightFont
        source: Qt.resolvedUrl("../fonts/serif-light.otf")
    }

    // Timer to update date daily
    Timer {
        interval: 60000 // Update every minute to catch day changes
        running: true
        repeat: true
        onTriggered: updateDate()
        Component.onCompleted: updateDate()
    }

    function updateDate() {
        var now = new Date()
        root.currentDayName = Qt.formatDate(now, "ddd")
        root.currentDate = Qt.formatDate(now, "d")
    }

    // Load ndot font for compact view
    FontLoader {
        id: ndotFont
        source: Qt.resolvedUrl("../fonts/ndot.ttf")
    }

    // Additional date properties for compact view
    property string currentDay: ""
    property string currentMonth: ""

    function updateCompactDate() {
        var now = new Date()
        root.currentDay = Qt.formatDate(now, "d")
        root.currentMonth = Qt.formatDate(now, "MMM").toUpperCase()
    }

    // Update compact date properties alongside full date
    Component.onCompleted: updateCompactDate()
    Connections {
        target: root
        function onCurrentDateChanged() { root.updateCompactDate() }
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
            spacing: compactItem.height * 0.18

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentDay
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.55
                color: nColors.textPrimary
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.currentMonth
                font.family: ndotFont.name
                font.pixelSize: compactItem.height * 0.4
                color: nColors.textSecondary
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
        Layout.minimumHeight: 200

        property bool foldHovered: false

        Rectangle {
            id: mainRect
            anchors.fill: parent
            anchors.margins: 10
            color: nColors.background
            radius: 20
            opacity: 0.95

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: -10

                Text {
                    id: dayNameLabel
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    Layout.topMargin: 10
                    Layout.rightMargin: 10
                    text: root.currentDayName
                    font.family: serifLightFont.name
                    font.pixelSize: Math.min(parent.width * 0.12, parent.height * 0.12)
                    color: nColors.accent
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: dateLabel
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.currentDate
                    font.family: serifFont.name
                    font.pixelSize: Math.min(parent.width * 0.7, parent.height * 0.7)
                    font.weight: Font.Bold
                    color: nColors.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        // Page peel triangle (backside revealed)
        Canvas {
            id: peelTriangle
            x: mainRect.x + mainRect.width - width
            y: mainRect.y + mainRect.height - height
            width: foldHovered ? 45 : 30
            height: foldHovered ? 45 : 30

            property bool isHovered: foldHovered

            Behavior on width {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            Behavior on height {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()

                var outerRadius = isHovered ? 18 : 16 // Rounded corner at top-left
                var innerRadius = 4  // Inward curves at top-right and bottom-left

                // Draw the peel triangle: top-left, top-right, bottom-left
                ctx.fillStyle = nColors.pagePeel
                ctx.beginPath()

                // Start from top-left (with rounded corner)
                ctx.moveTo(outerRadius, 0)
                ctx.arcTo(0, 0, 0, outerRadius, outerRadius)

                // Go to bottom-left (with inward curve)
                ctx.lineTo(0, height - innerRadius)
                ctx.quadraticCurveTo(0, height, innerRadius, height - innerRadius)

                // Go to top-right (with inward curve)
                ctx.lineTo(width - innerRadius, innerRadius)
                ctx.quadraticCurveTo(width, 0, width - innerRadius, 0)

                ctx.closePath()
                ctx.fill()
            }

            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onIsHoveredChanged: requestPaint()

            Connections {
                target: nColors
                function onPagePeelChanged() { peelTriangle.requestPaint() }
            }

            // Mouse area for hover detection
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: foldHovered = true
                onExited: foldHovered = false
            }
        }
    }
}
