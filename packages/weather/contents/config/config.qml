import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-weather"
        source: "config/ConfigGeneral.qml"
    }
}
