import QtQuick

Column {
    id: separator

    property real dotSize: 6
    property color dotColor: "white"
    property real dotSpacing: 6
    property bool blinking: true

    spacing: dotSpacing

    property bool _visible: true

    Timer {
        interval: 1000
        running: separator.blinking
        repeat: true
        onTriggered: separator._visible = !separator._visible
    }

    Rectangle {
        width: separator.dotSize
        height: separator.dotSize
        radius: separator.dotSize / 2
        color: separator.dotColor
        opacity: separator._visible ? 1.0 : 0.3
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
        opacity: separator._visible ? 1.0 : 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }
}
