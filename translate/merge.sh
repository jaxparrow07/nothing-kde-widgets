#!/usr/bin/env bash

# merge.sh - Extract translatable strings from QML files into .pot templates
#
# This script scans all widget packages for i18n() calls in QML files and
# generates .pot (Portable Object Template) files that translators can use
# as the basis for their translations.
#
# Usage:
#   ./translate/merge.sh              # Process all packages
#   ./translate/merge.sh clock-digital # Process a single package
#
# Requirements: gettext (xgettext, msgmerge)
#   On Debian/Ubuntu: sudo apt install gettext
#   On Fedora:        sudo dnf install gettext
#   On Arch:          sudo pacman -S gettext

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Check for required tools
if ! command -v xgettext &>/dev/null; then
    echo "[!] xgettext not found. Install gettext:"
    echo "    Debian/Ubuntu: sudo apt install gettext"
    echo "    Fedora:        sudo dnf install gettext"
    echo "    Arch:          sudo pacman -S gettext"
    exit 1
fi

# Process a single package
merge_package() {
    local PACKAGE_NAME="$1"
    local PACKAGE_DIR="${PROJECT_DIR}/packages/${PACKAGE_NAME}"
    local METADATA_FILE="${PACKAGE_DIR}/metadata.json"

    if [[ ! -f "$METADATA_FILE" ]]; then
        echo "[!] No metadata.json found for: ${PACKAGE_NAME}"
        return 1
    fi

    local PLUGIN_ID
    PLUGIN_ID=$(jq -r ".KPlugin.Id" "$METADATA_FILE")
    local DOMAIN="plasma_applet_${PLUGIN_ID}"
    local POT_DIR="${SCRIPT_DIR}/${PACKAGE_NAME}"
    local POT_FILE="${POT_DIR}/template.pot"

    echo "[*] Processing: ${PACKAGE_NAME} (${DOMAIN})"

    # Find all QML files in the package (relative to project root for clean paths)
    local QML_FILES=()
    while IFS= read -r -d '' file; do
        QML_FILES+=("$file")
    done < <(cd "$PROJECT_DIR" && find "packages/${PACKAGE_NAME}/contents" -name "*.qml" -print0 2>/dev/null)

    if [[ ${#QML_FILES[@]} -eq 0 ]]; then
        echo "    [!] No QML files found, skipping"
        return 0
    fi

    # Create output directory
    mkdir -p "$POT_DIR"

    # Get version from metadata.json
    local VERSION
    VERSION=$(jq -r ".KPlugin.Version // \"1.0\"" "$METADATA_FILE")

    # Extract translatable strings
    # xgettext treats QML i18n() calls correctly with --language=JavaScript
    # Run from project root so file references in .pot are relative paths
    (cd "$PROJECT_DIR" && xgettext \
        --from-code=UTF-8 \
        --language=JavaScript \
        --keyword=i18n:1 \
        --keyword=i18nc:1c,2 \
        --keyword=i18np:1,2 \
        --keyword=i18ncp:1c,2,3 \
        --package-name="${DOMAIN}" \
        --package-version="${VERSION}" \
        --foreign-user \
        --msgid-bugs-address="https://github.com/jaxparrow07/nothing-kde-widgets/issues" \
        -o "$POT_FILE" \
        "${QML_FILES[@]}")

    if [[ ! -f "$POT_FILE" ]]; then
        echo "    [!] No translatable strings found"
        return 0
    fi

    # Clean up placeholder headers that xgettext generates
    local WIDGET_NAME_PRETTY
    WIDGET_NAME_PRETTY=$(jq -r ".KPlugin.Name // \"${PACKAGE_NAME}\"" "$METADATA_FILE")
    sed -i \
        -e "s/# SOME DESCRIPTIVE TITLE./# ${WIDGET_NAME_PRETTY} - Translation Template/" \
        -e "/# Copyright (C)/d" \
        -e "/# This file is distributed/d" \
        -e "/# This file is put in the public domain/d" \
        -e "s/# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR./# Translators:/" \
        -e "s/\"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\\\n\"/\"PO-Revision-Date: 2025-01-01 00:00+0000\\\\n\"/" \
        -e "s/\"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\\\n\"/\"Last-Translator: \\\\n\"/" \
        -e "s/\"Language-Team: LANGUAGE <LL@li.org>\\\\n\"/\"Language-Team: \\\\n\"/" \
        -e "s/charset=CHARSET/charset=UTF-8/" \
        "$POT_FILE"

    local STRING_COUNT
    STRING_COUNT=$(grep -c "^msgid " "$POT_FILE" 2>/dev/null || echo "0")
    # Subtract 1 for the empty msgid header
    STRING_COUNT=$((STRING_COUNT - 1))
    echo "    [+] Extracted ${STRING_COUNT} translatable strings → ${POT_FILE}"

    # Merge existing .po files with updated template
    local PO_COUNT=0
    for PO_FILE in "${POT_DIR}"/*.po; do
        [[ -f "$PO_FILE" ]] || continue
        local LANG_CODE
        LANG_CODE=$(basename "$PO_FILE" .po)
        echo "    [*] Merging: ${LANG_CODE}.po"
        msgmerge --update --no-fuzzy-matching "$PO_FILE" "$POT_FILE"
        PO_COUNT=$((PO_COUNT + 1))
    done

    if [[ $PO_COUNT -gt 0 ]]; then
        echo "    [+] Merged ${PO_COUNT} existing translation(s)"
    fi

    return 0
}

# Main
echo "================================"
echo "Nothing KDE Widgets - String Extraction"
echo "================================"
echo ""

if [[ -n "$1" ]]; then
    # Process single package
    if [[ ! -d "${PROJECT_DIR}/packages/$1" ]]; then
        echo "[!] Package not found: $1"
        exit 1
    fi
    merge_package "$1"
else
    # Process all packages
    for PACKAGE_DIR in "${PROJECT_DIR}"/packages/*/; do
        PACKAGE_NAME=$(basename "$PACKAGE_DIR")
        merge_package "$PACKAGE_NAME" || true
    done
fi

echo ""
echo "[+] Done! Translation templates are in: translate/<package>/template.pot"
echo ""
echo "To start a new translation:"
echo "  cp translate/<package>/template.pot translate/<package>/<lang>.po"
echo "  # Edit <lang>.po with a PO editor (e.g., Lokalize, Poedit)"
echo ""
echo "After translating, run ./translate/build.sh to compile and install."
