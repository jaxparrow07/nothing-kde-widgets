import QtQuick

Column {
    id: separator

    property real dotSize: 6
    property color dotColor: "white"
    property real dotSpacing: 6
    property int seconds: 0

    spacing: dotSpacing

    Rectangle {
        width: separator.dotSize
        height: separator.dotSize
        radius: separator.dotSize / 2
        color: separator.dotColor
        opacity: separator.seconds % 2 === 0 ? 1.0 : 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    Rectangle {
        width: separator.dotSize
        height: separator.dotSize
        radius: separator.dotSize / 2
        color: separator.dotColor
        opacity: separator.seconds % 2 === 0 ? 1.0 : 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }
}
