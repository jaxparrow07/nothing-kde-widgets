import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    // NothingColors reference
    required property QtObject colors

    // Public properties - Media data
    property string albumArt: ""
    property string track: ""
    property string artist: ""
    property string playerIdentity: ""
    property real position: 0
    property real length: 0

    Rectangle {
        anchors.fill: parent
        anchors.margins: 10
        color: compactRoot.colors.surfaceAlt
        radius: 20
        opacity: 0.95

        // Subtle gradient overlay
        Rectangle {
            anchors.fill: parent
            radius: 20
            gradient: Gradient {
                GradientStop { position: 0.0; color: compactRoot.colors.surfaceGradient }
                GradientStop { position: 1.0; color: compactRoot.colors.surfaceAlt }
            }
            opacity: 0.6
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 6

            // Top row: Album art + Player Identity
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 80

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Album artwork thumbnail
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        color: compactRoot.colors.surface
                        radius: 12
                        clip: true

                        Image {
                            id: thumbnailImage
                            anchors.fill: parent
                            source: compactRoot.albumArt
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            visible: compactRoot.albumArt !== ""
                        }

                        // Fallback icon
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 48
                            height: 48
                            source: "media-optical-audio"
                            color: compactRoot.colors.textDisabled
                            visible: compactRoot.albumArt === ""
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Player Identity Icon
                    Rectangle {
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 22
                        color: compactRoot.colors.surface
                        opacity: 0.8

                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
                            source: {
                                // Try to map common player names to their icons
                                var identity = compactRoot.playerIdentity.toLowerCase()
                                if (identity.includes("spotify")) return "spotify"
                                if (identity.includes("vlc")) return "vlc"
                                if (identity.includes("firefox")) return "firefox"
                                if (identity.includes("chrome")) return "google-chrome"
                                if (identity.includes("mpv")) return "mpv"
                                if (identity.includes("strawberry")) return "strawberry"
                                if (identity.includes("elisa")) return "elisa"
                                if (identity.includes("amarok")) return "amarok"
                                if (identity.includes("rhythmbox")) return "rhythmbox"
                                if (identity.includes("clementine")) return "clementine"
                                // Default fallback
                                return "media-player"
                            }
                            color: compactRoot.colors.textPrimary
                        }
                    }
                }
            }

            // Track title with marquee effect
            MarqueeText {
                Layout.fillWidth: true
                Layout.preferredHeight: 18 + 4
                Layout.topMargin: 4
                Layout.bottomMargin: -4
                text: compactRoot.track || "No Track"
                fontSize: 18
                bold: true
                textColor: compactRoot.colors.textPrimary
            }

            // Artist name
            Text {
                Layout.fillWidth: true
                text: compactRoot.artist || "Unknown Artist"
                font.pixelSize: 12
                height: font.pixelSize + 4
                color: compactRoot.colors.textPlaceholder
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // Progress bar
            ProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                position: compactRoot.position
                length: compactRoot.length
                backgroundColor: compactRoot.colors.surface
                progressColor: compactRoot.colors.textPrimary
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
