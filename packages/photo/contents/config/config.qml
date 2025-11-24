import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Image")
        icon: "preferences-desktop-wallpaper"
        source: "config/ConfigImage.qml"
    }
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-theme-global"
        source: "config/ConfigAppearance.qml"
    }
}
