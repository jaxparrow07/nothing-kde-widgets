#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2024 Jack Faith <zinczorphin@email.com>
# SPDX-License-Identifier: GPL-3.0+

set -e

# Function to install a single widget
install_widget() {
	local WIDGET_NAME="$1"
	local SKIP_RELOAD="${2:-false}"
	local WIDGET_DIR="packages/${WIDGET_NAME}"
	local METADATA_FILE="${WIDGET_DIR}/metadata.json"

	echo ""
	echo "================================"
	echo "[*] Processing widget: ${WIDGET_NAME}"
	echo "================================"

	# Extract widget ID first
	local widgetId=$(jq -r ".KPlugin.Id" "$METADATA_FILE")


	if [[ -d "$HOME/.local/share/plasma/plasmoids/${widgetId}" ]]; then
		echo "[+] Widget already installed. Updating: ${widgetId}"
		kpackagetool6 --type=Plasma/Applet -u "${WIDGET_DIR}"
		local install_result=$?
	else
		echo "[+] Installing widget: ${widgetId}"
		kpackagetool6 --type=Plasma/Applet -i "${WIDGET_DIR}"
		local install_result=$?
	fi
	
	# Check installation result
	if [[ $install_result -eq 0 ]]; then
		echo "[+] Widget installed/updated successfully!"
	else
		echo "[!] Installation/update failed"
		return 1
	fi

	# Post-install hook: Restart plasmashell (unless skipped)
	if [[ "$SKIP_RELOAD" != "true" ]]; then
		echo "[*] Post-install hook: restarting plasmashell..."
		killall plasmashell && kstart plasmashell
		echo "[+] Plasmashell restarted"
	fi

	return 0
}

# Main script logic
if [[ "$1" == "--all" || "$1" == "-a" ]]; then
	echo "[*] Installing all widgets..."

	# Get all widget directories
	WIDGETS=($(ls -d packages/*/ 2>/dev/null | xargs -n 1 basename))

	if [[ ${#WIDGETS[@]} -eq 0 ]]; then
		echo "[!] No widgets found in packages directory"
		exit 1
	fi

	echo "[+] Found ${#WIDGETS[@]} widgets to install"

	FAILED_WIDGETS=()
	SUCCESSFUL_WIDGETS=()

	# Install all widgets without reloading
	for widget in "${WIDGETS[@]}"; do
		if install_widget "$widget" "true"; then
			SUCCESSFUL_WIDGETS+=("$widget")
		else
			FAILED_WIDGETS+=("$widget")
			echo "[!] Failed to install: $widget"
		fi
	done

	# Summary
	echo ""
	echo "================================"
	echo "[*] Installation Summary"
	echo "================================"
	echo "[+] Successfully installed: ${#SUCCESSFUL_WIDGETS[@]}"
	for widget in "${SUCCESSFUL_WIDGETS[@]}"; do
		echo "    ✓ $widget"
	done

	if [[ ${#FAILED_WIDGETS[@]} -gt 0 ]]; then
		echo "[!] Failed to install: ${#FAILED_WIDGETS[@]}"
		for widget in "${FAILED_WIDGETS[@]}"; do
			echo "    ✗ $widget"
		done
	fi

	# Reload plasmashell once at the end
	echo ""
	echo "[*] Reloading plasmashell..."
	killall plasmashell && kstart plasmashell
	echo "[+] All done!"

elif [[ -n "$1" && -d "packages/$1" ]]; then
	# Install single widget with reload
	install_widget "$1" "false"
	echo "[+] Installation complete!"
else
	if [[ -n "$1" ]]; then
		echo "[!] Widget package not found: $1"
	else
		echo "[!] No widget specified"
	fi
	echo "[+] Pick any of the following available packages:"
	ls packages
	echo ""
	echo "Usage:"
	echo "  ./install.sh <package_folder>    Install a single widget"
	echo "  ./install.sh --all | -a          Install all widgets"
	exit 1
fi
