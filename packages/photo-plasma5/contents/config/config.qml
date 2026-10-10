import QtQuick 2.15
import org.kde.plasma.configuration 2.0

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
