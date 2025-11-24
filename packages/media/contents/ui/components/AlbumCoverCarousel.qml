import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: carouselRoot

    // Public properties - Media data
    property string albumArt: ""
    property bool isPlaying: false
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canPlay: false
    property bool canPause: false

    // Public signals
    signal previousClicked()
    signal nextClicked()
    signal playPauseClicked()

    // Internal hover states
    property bool leftHovered: false
    property bool rightHovered: false
    property bool centerHovered: false

    // Base rounded rectangle background
    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.margins: 10
        color: "#1a1a1a"
        radius: 20
        opacity: 0.95
        clip: true

        // Control icons layer (below album cover)
        Item {
            id: controlsLayer
            anchors.fill: parent

            // Previous icon (left side, vertically centered)
            Kirigami.Icon {
                id: previousIcon
                anchors {
                    left: parent.left
                    leftMargin: parent.width * 0.035
                    verticalCenter: parent.verticalCenter
                }
                width: 32
                height: 32
                source: "media-skip-backward"
                color: "white"
                visible: carouselRoot.canGoPrevious
            }

            // Next icon (right side, vertically centered)
            Kirigami.Icon {
                id: nextIcon
                anchors {
                    right: parent.right
                    rightMargin: parent.width * 0.035
                    verticalCenter: parent.verticalCenter
                }
                width: 32
                height: 32
                source: "media-skip-forward"
                color: "white"
                visible: carouselRoot.canGoNext
            }
        }

        // Album cover layer (on top with z-index)
        Item {
            id: albumCoverContainer
            anchors.fill: parent
            z: 0

            // Smooth animations for position changes
            Behavior on anchors.leftMargin {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            Behavior on anchors.rightMargin {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            // Apply margins based on hover state
            anchors.leftMargin: carouselRoot.leftHovered ? parent.width * 0.27 : 0
            anchors.rightMargin: carouselRoot.rightHovered ? parent.width * 0.27 : 0

            // Use the AlbumArtwork component
            AlbumArtwork {
                anchors.fill: parent
                artUrl: carouselRoot.albumArt
                cornerRadius: 20
                backgroundColor: "#1a1a1a"
                z: 2
            }

            // Dim overlay when hovering center and playing
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                radius: 20
                opacity: (carouselRoot.centerHovered && carouselRoot.isPlaying) ? 0.5 : 0.0
                z: 5

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }

            // Center play/pause icon overlay (on top of album art)
            Kirigami.Icon {
                id: centerPlayPauseIcon
                anchors.centerIn: parent
                width: 48
                height: 48
                source: carouselRoot.isPlaying ? "media-playback-pause" : "media-playback-start"
                color: "white"
                z: 10
                // Show if paused OR if playing and hovering center
                visible: (carouselRoot.canPlay || carouselRoot.canPause) && (!carouselRoot.isPlaying || carouselRoot.centerHovered)
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Hover detection zones
        // Left zone for previous
        MouseArea {
            id: leftHoverArea
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * 0.1
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 10

            onEntered: carouselRoot.leftHovered = true
            onExited: carouselRoot.leftHovered = false
            onClicked: if (carouselRoot.canGoPrevious) carouselRoot.previousClicked()
        }

        // Right zone for next
        MouseArea {
            id: rightHoverArea
            anchors {
                right: parent.right
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * 0.1
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 10

            onEntered: carouselRoot.rightHovered = true
            onExited: carouselRoot.rightHovered = false
            onClicked: if (carouselRoot.canGoNext) carouselRoot.nextClicked()
        }

        // Center zone for play/pause
        MouseArea {
            id: centerHoverArea
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.6
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            z: 10

            onEntered: carouselRoot.centerHovered = true
            onExited: carouselRoot.centerHovered = false
            onClicked: if (carouselRoot.canPlay || carouselRoot.canPause) carouselRoot.playPauseClicked()
        }
    }
}
