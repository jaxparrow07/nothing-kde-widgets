import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "battery"
        source: "config/ConfigGeneral.qml"
    }
}
