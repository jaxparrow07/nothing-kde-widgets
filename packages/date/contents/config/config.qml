import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "view-calendar"
        source: "config/ConfigGeneral.qml"
    }
}
