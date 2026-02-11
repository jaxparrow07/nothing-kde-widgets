import QtQuick
import QtQuick.Effects
import org.kde.kirigami as Kirigami

Item {
    id: artworkRoot

    // NothingColors reference
    required property QtObject colors

    // Public properties
    property string artUrl: ""
    property int cornerRadius: 20
    property color backgroundColor: colors.background
    property color fallbackIconColor: colors.textDisabled
    property string fallbackIcon: "media-optical-audio"

    // Source image (hidden)
    Image {
        id: albumCover
        anchors.fill: parent
        source: artworkRoot.artUrl
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
        layer.enabled: true
    }

    // Mask for rounded corners
    Item {
        id: roundedMask
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: artworkRoot.cornerRadius
            color: "white"
        }
    }

    // Background layer to block content beneath
    Rectangle {
        anchors.fill: parent
        color: artworkRoot.backgroundColor
        radius: artworkRoot.cornerRadius
        z: 1
    }

    // MultiEffect with rounded corner mask
    MultiEffect {
        id: albumEffect
        anchors.fill: parent
        source: albumCover
        maskEnabled: true
        maskSource: roundedMask
        visible: artworkRoot.artUrl !== ""
        z: 2
    }

    // Fallback when no album art
    Rectangle {
        anchors.fill: parent
        color: artworkRoot.colors.surface
        radius: artworkRoot.cornerRadius
        visible: artworkRoot.artUrl === ""
        z: 2

        Kirigami.Icon {
            anchors.centerIn: parent
            width: parent.width * 0.4
            height: parent.height * 0.4
            source: artworkRoot.fallbackIcon
            color: artworkRoot.fallbackIconColor
        }
    }
}
