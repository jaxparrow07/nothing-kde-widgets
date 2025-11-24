import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // Configuration properties
    property string imagePath: plasmoid.configuration.imagePath
    property bool borderEnabled: plasmoid.configuration.borderEnabled
    property int borderSize: plasmoid.configuration.borderSize
    property bool pillShapeEnabled: plasmoid.configuration.pillShapeEnabled
    property int imageFillMode: plasmoid.configuration.imageFillMode
    property bool grayscaleEnabled: plasmoid.configuration.grayscaleEnabled

    // Calculate the appropriate corner radius for outer background
    readonly property real outerRadius: {
        if (!pillShapeEnabled) {
            return 20  // Standard rounded corners
        }

        // Pill shape logic for outer background
        var w = root.width
        var h = root.height
        var aspectRatio = w / h

        // If nearly square (within 10% tolerance), make it a circle
        if (aspectRatio >= 0.9 && aspectRatio <= 1.1) {
            return Math.min(w, h) / 2
        }

        // Horizontal pill (wider than tall)
        if (w > h) {
            return h / 2
        }

        // Vertical pill (taller than wide)
        return w / 2
    }

    // Calculate the appropriate corner radius for inner content (respects border)
    // Formula: Border radius of inner = Border radius of outer - margin
    readonly property real calculatedRadius: {
        var margin = borderEnabled ? borderSize : 0
        return Math.max(0, outerRadius - margin)
    }

    // Map config value to QML fillMode
    readonly property int qmlFillMode: {
        switch(imageFillMode) {
            case 0: return Image.PreserveAspectCrop  // Crop (Fill Frame)
            case 1: return Image.PreserveAspectFit   // Fit (Show All)
            case 2: return Image.Stretch             // Stretch
            default: return Image.PreserveAspectCrop
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 200
        Layout.preferredHeight: 200
        Layout.minimumWidth: 200
        Layout.minimumHeight: 200
        anchors.margins: 10

        // Outer background rectangle (always visible to show the border)
        Rectangle {
            id: outerBackground
            anchors.fill: parent
            color: "#1a1a1a"
            opacity: 0.95
            radius: root.outerRadius
        }

        // Main content rectangle with configurable margin
        Rectangle {
            id: mainRect
            anchors.fill: parent
            anchors.margins: borderEnabled ? borderSize : 0
            color: "#1a1a1a"
            radius: root.calculatedRadius
            clip: true

            // Source image (hidden, used for masking)
            Image {
                id: photoImage
                anchors.fill: parent
                source: {
                    if (!root.imagePath) return ""
                    if (root.imagePath.startsWith("/") || root.imagePath.startsWith("file://")) {
                        return root.imagePath
                    }
                    // Relative path from contents/ui to contents/default
                    return Qt.resolvedUrl("../" + root.imagePath)
                }
                fillMode: root.qmlFillMode
                smooth: true
                visible: false
                layer.enabled: true
                cache: true
            }

            // Mask for rounded corners
            Item {
                id: roundedMask
                anchors.fill: parent
                layer.enabled: true
                visible: false

                Rectangle {
                    anchors.fill: parent
                    radius: root.calculatedRadius
                    color: "white"
                }
            }

            // Background layer (blocks anything beneath if needed)
            Rectangle {
                anchors.fill: parent
                color: "#1a1a1a"
                radius: root.calculatedRadius
                z: 1
            }

            // Photo effects layer
            Item {
                anchors.fill: parent
                z: 2

                MultiEffect {
                    id: photoEffect
                    anchors.fill: parent
                    source: photoImage
                    maskEnabled: true
                    maskSource: roundedMask
                    visible: root.imagePath !== ""
                }

                // Grayscale overlay
                MultiEffect {
                    anchors.fill: parent
                    source: photoEffect
                    visible: root.grayscaleEnabled && root.imagePath !== ""
                    colorization: 1.0
                    colorizationColor: "#808080"
                    brightness: 0.5
                    contrast: 1
                }
            }

            // Fallback when no image is selected
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                radius: root.calculatedRadius
                visible: root.imagePath === ""
                z: 2

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.parent.width * 0.3, 64)
                        Layout.preferredHeight: Math.min(parent.parent.height * 0.3, 64)
                        source: "image-x-generic"
                        color: "#666666"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No Image"
                        font.pixelSize: 14
                        color: "#666666"
                        visible: mainRect.width > 120 && mainRect.height > 120
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.parent.width * 0.7, 150)
                        text: "Right-click to configure"
                        font.pixelSize: 10
                        color: "#555555"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: mainRect.width > 150 && mainRect.height > 150
                    }
                }
            }

            // Error state when image fails to load
            Rectangle {
                anchors.fill: parent
                color: "#2a2a2a"
                radius: root.calculatedRadius
                visible: root.imagePath !== "" && photoImage.status === Image.Error
                z: 3

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    Kirigami.Icon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.parent.width * 0.3, 64)
                        Layout.preferredHeight: Math.min(parent.parent.height * 0.3, 64)
                        source: "dialog-error"
                        color: "#d32f2f"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Image Error"
                        font.pixelSize: 14
                        color: "#d32f2f"
                        visible: mainRect.width > 120 && mainRect.height > 120
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.parent.width * 0.7, 150)
                        text: "Failed to load image"
                        font.pixelSize: 10
                        color: "#888888"
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        visible: mainRect.width > 150 && mainRect.height > 150
                    }
                }
            }
        }
    }
}
