# Translating Nothing KDE Widgets

The widgets use KDE's standard `i18n()` translation system. All user-facing strings are already marked as translatable , you just need to provide the translations for your language.

## How It Works

```
template.pot  →  your_language.po  →  compiled .mo  →  bundled in widget
  (source)        (you translate)      (build.sh)      (install.sh)
```

1. Each widget has a `template.pot` file containing all translatable strings
2. You copy it to create a `.po` file for your language (e.g., `nl.po` for Dutch)
3. You translate the strings in the `.po` file
4. `build.sh` compiles your translations into binary `.mo` files
5. `install.sh` automatically bundles them into the widget when installing

## Contributing a Translation

### 1. Pick a widget and copy the template

```bash
cd translate/<package>/
cp template.pot <language_code>.po
```

For example, to start a Dutch translation for the clock:
```bash
cd translate/clock-digital/
cp template.pot nl.po
```

Language codes follow the [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) standard:
| Language | Code |
|----------|------|
| Dutch | `nl` |
| French | `fr` |
| German | `de` |
| Spanish | `es` |
| Portuguese (Brazil) | `pt_BR` |
| Japanese | `ja` |
| Korean | `ko` |
| Chinese (Simplified) | `zh_CN` |

### 2. Edit the `.po` file

Open the `.po` file in a translation editor:

- **[Lokalize](https://apps.kde.org/lokalize/)** — KDE's translation tool (recommended)
- **[Poedit](https://poedit.net/)** — Cross-platform PO editor
- **Any text editor** — PO files are plain text

Each entry looks like:
```po
#: packages/date/contents/ui/config/ConfigGeneral.qml:16
msgid "Theme:"
msgstr ""
```

Fill in `msgstr` with your translation:
```po
#: packages/date/contents/ui/config/ConfigGeneral.qml:16
msgid "Theme:"
msgstr "Thema:"
```

Also update the header at the top of the file:
- Set `Language:` to your language code (e.g., `nl`)
- Set `Content-Type` charset to `UTF-8`
- Fill in `Last-Translator` with your name

### 3. Submit a Pull Request

Commit your `.po` file and open a PR. That's it — the maintainer handles the rest.

## Available Widgets

| Package | Strings | Template |
|---------|---------|----------|
| `battery` | 23 | [template.pot](battery/template.pot) |
| `clock-analog` | 13 | [template.pot](clock-analog/template.pot) |
| `clock-digital` | 19 | [template.pot](clock-digital/template.pot) |
| `clock-digital-large` | 24 | [template.pot](clock-digital-large/template.pot) |
| `date` | 6 | [template.pot](date/template.pot) |
| `media` | 6 | [template.pot](media/template.pot) |
| `photo` | 33 | [template.pot](photo/template.pot) |
| `weather` | 19 | [template.pot](weather/template.pot) |

## For Maintainers

### Regenerate templates after changing strings

If you add or modify `i18n()` strings in QML files, regenerate the templates:

```bash
./translate/merge.sh
```

This updates all `template.pot` files and merges changes into any existing `.po` files.

### Build and install translations

Translations are automatically compiled when you run `install.sh`. You can also build them manually:

```bash
./translate/build.sh
```

This compiles all `.po` files into `.mo` binaries and places them in:
```
packages/<widget>/contents/locale/<lang>/LC_MESSAGES/plasma_applet_<id>.mo
```

### Requirements

The build scripts require `gettext`:

```bash
# Debian/Ubuntu
sudo apt install gettext

# Fedora
sudo dnf install gettext

# Arch
sudo pacman -S gettext
```
