import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property string currentHours: "10"
    property string currentMinutes: "09"
    property string currentDay: "SAT,"
    property string currentDate: "10 SEP"

    FontLoader {
        id: dotMatrixFont
        source: Qt.resolvedUrl("../fonts/ndot.ttf")
    }

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
        var minutes = now.getMinutes()
        
        var hoursStr = hours < 10 ? "0" + hours : hours.toString()
        var minutesStr = minutes < 10 ? "0" + minutes : minutes.toString()
        
        root.currentHours = hoursStr
        root.currentMinutes = minutesStr
        
        var dayNames = ["SUN,", "MON,", "TUE,", "WED,", "THU,", "FRI,", "SAT,"]
        root.currentDay = dayNames[now.getDay()]
        
        var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
        root.currentDate = (now.getDate() < 10 ? "0" + now.getDate() : now.getDate()) + " " + monthNames[now.getMonth()]
    }

    compactRepresentation: Item {
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: root.currentHours + ":" + root.currentMinutes
            font.pixelSize: parent.height * 0.4
            font.bold: true
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 300
        Layout.minimumWidth: 100
        Layout.minimumHeight: 150


        Column {
            id: clockColumn
            anchors.centerIn: parent
            spacing: Math.max(parent.height * 0.02, 2)

            Text {
                text: root.currentHours
                font.family: dotMatrixFont.name
                font.weight: Font.Bold
                font.pixelSize: parent.parent.height * 0.3
                color: "#F0F0F0"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: root.currentMinutes
                font.family: dotMatrixFont.name
                font.weight: Font.Bold
                font.pixelSize: parent.parent.height * 0.3
                color: "#F0F0F0"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: root.currentDay
                font.family: dotMatrixFont.name
                font.pixelSize: parent.parent.height * 0.12
                color: "#F0F0F0"
                horizontalAlignment: Text.AlignLeft
            }

            Text {
                text: root.currentDate
                font.family: dotMatrixFont.name
                font.pixelSize: parent.parent.height * 0.12
                color: "#F0F0F0"
                horizontalAlignment: Text.AlignLeft
            }
        }
    }
}
