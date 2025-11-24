import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "battery"
        source: "config/ConfigGeneral.qml"
    }
}
