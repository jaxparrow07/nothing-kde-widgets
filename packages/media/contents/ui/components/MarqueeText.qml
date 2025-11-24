import QtQuick

Item {
    id: marqueeRoot

    // Public properties
    property string text: ""
    property int fontSize: 18
    property bool bold: true
    property string textColor: "white"
    property int scrollSpeed: 20  // pixels per character difference
    property int initialPause: 2000
    property int endPause: 1000

    clip: true

    Text {
        id: scrollingText
        text: marqueeRoot.text
        font.pixelSize: marqueeRoot.fontSize
        font.bold: marqueeRoot.bold
        color: marqueeRoot.textColor

        property bool needsScrolling: width > parent.width

        x: 0

        SequentialAnimation on x {
            running: scrollingText.needsScrolling
            loops: Animation.Infinite

            // Initial pause
            PauseAnimation { duration: marqueeRoot.initialPause }

            // Scroll to the left
            NumberAnimation {
                from: 0
                to: -(scrollingText.width - scrollingText.parent.width)
                duration: scrollingText.needsScrolling ? (scrollingText.width - scrollingText.parent.width) * marqueeRoot.scrollSpeed : 0
                easing.type: Easing.Linear
            }

            // Pause at the end
            PauseAnimation { duration: marqueeRoot.endPause }

            // Scroll back to the right
            NumberAnimation {
                from: -(scrollingText.width - scrollingText.parent.width)
                to: 0
                duration: scrollingText.needsScrolling ? (scrollingText.width - scrollingText.parent.width) * marqueeRoot.scrollSpeed : 0
                easing.type: Easing.Linear
            }
        }
    }
}
