import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import "../components"

Item {
    id: compactItem

    required property QtObject colors
    required property string currentHours
    required property string currentMinutes
    required property string ndotFontFamily
    required property int currentSeconds

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
            text: compactItem.currentHours
            font.family: compactItem.ndotFontFamily
            font.pixelSize: compactItem.height * 0.55
            color: compactItem.colors.textPrimary
        }

        BlinkingSeparator {
            anchors.verticalCenter: parent.verticalCenter
            dotSize: Math.max(compactItem.height * 0.08, 3)
            dotColor: compactItem.colors.textPrimary
            dotSpacing: Math.max(compactItem.height * 0.04, 2)
            seconds: compactItem.currentSeconds
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: compactItem.currentMinutes
            font.family: compactItem.ndotFontFamily
            font.pixelSize: compactItem.height * 0.55
            color: compactItem.colors.textPrimary
        }
    }
}
