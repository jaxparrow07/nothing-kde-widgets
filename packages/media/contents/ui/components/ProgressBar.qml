import QtQuick

Item {
    id: progressRoot

    // Public properties
    property real position: 0
    property real length: 0
    property string backgroundColor: "#2a2a2a"
    property string progressColor: "white"
    property int barRadius: 2
    property int animationDuration: 1000

    implicitHeight: 4

    // Background track
    Rectangle {
        anchors.fill: parent
        color: progressRoot.backgroundColor
        radius: progressRoot.barRadius
    }

    // Progress indicator
    Rectangle {
        width: progressRoot.length > 0 ? (parent.width * (progressRoot.position / progressRoot.length)) : 0
        height: parent.height
        color: progressRoot.progressColor
        radius: progressRoot.barRadius

        Behavior on width {
            NumberAnimation { duration: progressRoot.animationDuration }
        }
    }
}
