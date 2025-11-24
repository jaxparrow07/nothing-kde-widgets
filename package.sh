#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 Jack Faith <zinczorphin@email.com>
# SPDX-License-Identifier: GPL-3.0+

# Package KDE Plasma widgets into distributable .plasmoid files

set -e

PACKAGE_DIR="2-packaged"
PACKAGES_SRC="packages"

# Function to package a single widget
package_widget() {
	local WIDGET_NAME="$1"
	local WIDGET_DIR="${PACKAGES_SRC}/${WIDGET_NAME}"
	local METADATA_FILE="${WIDGET_DIR}/metadata.json"

	if [[ ! -f "$METADATA_FILE" ]]; then
		echo "[!] Error: metadata.json not found in ${WIDGET_NAME}"
		return 1
	fi

	echo ""
	echo "================================"
	echo "[*] Packaging: ${WIDGET_NAME}"
	echo "================================"

	# Extract widget information
	local WIDGET_ID=$(jq -r '.KPlugin.Id' "$METADATA_FILE")
	local VERSION=$(jq -r '.KPlugin.Version' "$METADATA_FILE")

	if [[ -z "$WIDGET_ID" || "$WIDGET_ID" == "null" ]]; then
		echo "[!] Error: Invalid widget ID in metadata.json"
		return 1
	fi

	# Create output filename
	local OUTPUT_NAME="${WIDGET_NAME}"
	if [[ -n "$VERSION" && "$VERSION" != "null" ]]; then
		OUTPUT_NAME="${WIDGET_NAME}-${VERSION}"
	fi
	local OUTPUT_FILE="${PACKAGE_DIR}/${OUTPUT_NAME}.plasmoid"

	# Create temp directory for packaging
	local TEMP_DIR=$(mktemp -d)
	trap "rm -rf $TEMP_DIR" EXIT

	echo "[*] Copying widget files to temporary directory (resolving symlinks)..."
	# Use tar with -h flag to dereference (follow) symlinks
	tar -C "${WIDGET_DIR}" -chf - . | tar -C "$TEMP_DIR" -xf -

	# Remove development files that shouldn't be in the package
	echo "[*] Cleaning up development files..."
	find "$TEMP_DIR" -name "*.swp" -delete 2>/dev/null || true
	find "$TEMP_DIR" -name "*.swo" -delete 2>/dev/null || true
	find "$TEMP_DIR" -name "*~" -delete 2>/dev/null || true
	find "$TEMP_DIR" -name ".DS_Store" -delete 2>/dev/null || true
	find "$TEMP_DIR" -name "Thumbs.db" -delete 2>/dev/null || true

	# Create the package directory if it doesn't exist
	mkdir -p "$PACKAGE_DIR"

	# Get absolute path before changing directory
	local ABS_OUTPUT=$(realpath "$OUTPUT_FILE")

	# Create the .plasmoid package
	echo "[*] Creating .plasmoid package..."
	pushd "$TEMP_DIR" > /dev/null
	zip -q -r "$ABS_OUTPUT" .
	popd > /dev/null

	echo "[+] Package created successfully!"
	echo "    Widget ID: ${WIDGET_ID}"
	echo "    Version: ${VERSION}"
	echo "    Output: ${ABS_OUTPUT}"
	echo "    Size: $(du -h "$OUTPUT_FILE" | cut -f1)"

	return 0
}

# Main script logic
if [[ "$1" == "--all" || "$1" == "-a" ]]; then
	echo "[*] Packaging all widgets..."

	# Get all widget directories
	WIDGETS=($(ls -d ${PACKAGES_SRC}/*/ 2>/dev/null | xargs -n 1 basename))

	if [[ ${#WIDGETS[@]} -eq 0 ]]; then
		echo "[!] No widgets found in ${PACKAGES_SRC} directory"
		exit 1
	fi

	echo "[+] Found ${#WIDGETS[@]} widgets to package"

	FAILED_WIDGETS=()
	SUCCESSFUL_WIDGETS=()

	# Package all widgets
	for widget in "${WIDGETS[@]}"; do
		if package_widget "$widget"; then
			SUCCESSFUL_WIDGETS+=("$widget")
		else
			FAILED_WIDGETS+=("$widget")
			echo "[!] Failed to package: $widget"
		fi
	done

	# Summary
	echo ""
	echo "================================"
	echo "[*] Packaging Summary"
	echo "================================"
	echo "[+] Successfully packaged: ${#SUCCESSFUL_WIDGETS[@]}"
	for widget in "${SUCCESSFUL_WIDGETS[@]}"; do
		echo "    ✓ $widget"
	done

	if [[ ${#FAILED_WIDGETS[@]} -gt 0 ]]; then
		echo "[!] Failed to package: ${#FAILED_WIDGETS[@]}"
		for widget in "${FAILED_WIDGETS[@]}"; do
			echo "    ✗ $widget"
		done
	fi

	echo ""
	echo "[+] All packages saved to: $(realpath $PACKAGE_DIR)"

elif [[ -n "$1" && -d "${PACKAGES_SRC}/$1" ]]; then
	# Package single widget
	package_widget "$1"
	echo "[+] Packaging complete!"
else
	if [[ -n "$1" ]]; then
		echo "[!] Widget package not found: $1"
	fi
	echo "[+] Available widgets:"
	ls "$PACKAGES_SRC"
	echo ""
	echo "Usage:"
	echo "  ./package.sh <package_folder>    Package a single widget"
	echo "  ./package.sh --all | -a          Package all widgets"
	exit 1
fi
