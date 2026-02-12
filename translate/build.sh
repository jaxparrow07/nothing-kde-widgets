#!/usr/bin/env bash

# build.sh - Compile .po translations into .mo files and install into packages
#
# This script compiles all .po translation files into binary .mo files and
# places them in the correct location within each widget package so they
# are included when the widget is installed.
#
# Usage:
#   ./translate/build.sh              # Build all packages
#   ./translate/build.sh clock-digital # Build a single package
#
# Requirements: gettext (msgfmt)
#   On Debian/Ubuntu: sudo apt install gettext
#   On Fedora:        sudo dnf install gettext
#   On Arch:          sudo pacman -S gettext

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Check for required tools
if ! command -v msgfmt &>/dev/null; then
    echo "[!] msgfmt not found. Install gettext:"
    echo "    Debian/Ubuntu: sudo apt install gettext"
    echo "    Fedora:        sudo dnf install gettext"
    echo "    Arch:          sudo pacman -S gettext"
    exit 1
fi

# Build translations for a single package
build_package() {
    local PACKAGE_NAME="$1"
    local PACKAGE_DIR="${PROJECT_DIR}/packages/${PACKAGE_NAME}"
    local METADATA_FILE="${PACKAGE_DIR}/metadata.json"
    local PO_DIR="${SCRIPT_DIR}/${PACKAGE_NAME}"

    if [[ ! -f "$METADATA_FILE" ]]; then
        echo "[!] No metadata.json found for: ${PACKAGE_NAME}"
        return 1
    fi

    if [[ ! -d "$PO_DIR" ]]; then
        echo "[*] No translations directory for: ${PACKAGE_NAME}, skipping"
        return 0
    fi

    local PLUGIN_ID
    PLUGIN_ID=$(jq -r ".KPlugin.Id" "$METADATA_FILE")
    local DOMAIN="plasma_applet_${PLUGIN_ID}"

    echo "[*] Building translations: ${PACKAGE_NAME} (${DOMAIN})"

    local LANG_COUNT=0
    for PO_FILE in "${PO_DIR}"/*.po; do
        [[ -f "$PO_FILE" ]] || continue

        local LANG_CODE
        LANG_CODE=$(basename "$PO_FILE" .po)
        local LOCALE_DIR="${PACKAGE_DIR}/contents/locale/${LANG_CODE}/LC_MESSAGES"
        local MO_FILE="${LOCALE_DIR}/${DOMAIN}.mo"

        # Check for translation completeness
        local STATS
        STATS=$(msgfmt --statistics "$PO_FILE" 2>&1 || true)

        mkdir -p "$LOCALE_DIR"
        msgfmt -o "$MO_FILE" "$PO_FILE"

        echo "    [+] ${LANG_CODE}: ${MO_FILE}"
        echo "        ${STATS}"
        LANG_COUNT=$((LANG_COUNT + 1))
    done

    if [[ $LANG_COUNT -eq 0 ]]; then
        echo "    [*] No .po files found, skipping"
    else
        echo "    [+] Built ${LANG_COUNT} language(s)"
    fi

    return 0
}

# Main
echo "================================"
echo "Nothing KDE Widgets - Translation Build"
echo "================================"
echo ""

if [[ -n "$1" ]]; then
    # Build single package
    if [[ ! -d "${PROJECT_DIR}/packages/$1" ]]; then
        echo "[!] Package not found: $1"
        exit 1
    fi
    build_package "$1"
else
    # Build all packages
    for PACKAGE_DIR in "${PROJECT_DIR}"/packages/*/; do
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
        build_package "$PACKAGE_NAME" || true
    done
fi

echo ""
echo "[+] Done! Translations compiled and installed into packages."
echo "[*] Run ./install.sh to update your installed widgets."
