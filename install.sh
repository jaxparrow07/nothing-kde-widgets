#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build translations if gettext is available
build_translations() {
	if command -v msgfmt &>/dev/null; then
		echo "[*] Compiling translations..."
		"${SCRIPT_DIR}/translate/build.sh" 2>/dev/null || true
	fi
}

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

	if command -v kpackagetool6 &> /dev/null; then
		KPACKAGE="kpackagetool6"
	elif command -v kpackagetool5 &> /dev/null; then
		KPACKAGE="kpackagetool5"
	elif command -v plasmapkg2 &> /dev/null; then
		KPACKAGE="plasmapkg2"
	fi

	# Extract widget ID first
	local widgetId=$(jq -r ".KPlugin.Id" "$METADATA_FILE")

	# Stage the widget with symlinks resolved so the installed copy is self-contained
	local STAGE_DIR=$(mktemp -d)
	trap "rm -rf $STAGE_DIR" EXIT
	echo "[*] Resolving symlinks into staging directory..."
	tar -C "${WIDGET_DIR}" -chf - . | tar -C "$STAGE_DIR" -xf -

	if [[ -n "$KPACKAGE" ]]; then
		if [[ -d "$HOME/.local/share/plasma/plasmoids/${widgetId}" ]]; then
			echo "[+] Widget already installed. Updating: ${widgetId}"
			$KPACKAGE --type=Plasma/Applet -u "$STAGE_DIR"
			local install_result=$?
		else
			echo "[+] Installing widget: ${widgetId}"
			$KPACKAGE --type=Plasma/Applet -i "$STAGE_DIR"
			local install_result=$?
		fi
	else
		echo "[!] Packaging tools not found, falling back to manual copy..."
		local DEST_DIR="$HOME/.local/share/plasma/plasmoids/${widgetId}"
		mkdir -p "$HOME/.local/share/plasma/plasmoids/"
		if [[ -d "$DEST_DIR" ]]; then
			echo "[+] Widget already installed. Updating: ${widgetId} (manual copy)"
			rm -rf "$DEST_DIR"
		else
			echo "[+] Installing widget: ${widgetId} (manual copy)"
		fi
		cp -r "$STAGE_DIR" "$DEST_DIR"
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
		if command -v killall &> /dev/null; then
			killall plasmashell && (kstart plasmashell || kstart5 plasmashell || plasmashell &)
		elif command -v pkill &> /dev/null; then
			pkill plasmashell && (kstart plasmashell || kstart5 plasmashell || plasmashell &)
		else
			echo "[!] Could not restart plasmashell automatically (killall/pkill not found)."
		fi
		echo "[+] Plasmashell restarted"
	fi

	return 0
}

# Main script logic
if [[ "$1" == "--all" || "$1" == "-a" ]]; then
	echo "[*] Installing all widgets..."
	build_translations

	# Determine Plasma version
	PLASMA_VER=""
	if [[ "$2" == "--plasma5" || "$2" == "-p5" ]]; then
		PLASMA_VER=5
		echo "[*] Forced Plasma 5 installation"
	elif [[ "$2" == "--plasma6" || "$2" == "-p6" ]]; then
		PLASMA_VER=6
		echo "[*] Forced Plasma 6 installation"
	elif command -v kpackagetool6 &> /dev/null; then
		PLASMA_VER=6
		echo "[*] Detected Plasma 6"
	else
		PLASMA_VER=5
		echo "[*] Detected Plasma 5"
	fi

	# Get all widget directories
	ALL_WIDGETS=($(ls -d packages/*/ 2>/dev/null | xargs -n 1 basename))
	WIDGETS=()

	for w in "${ALL_WIDGETS[@]}"; do
		if [[ "$PLASMA_VER" == "6" ]]; then
			if [[ ! "$w" == *"-plasma5" ]]; then
				WIDGETS+=("$w")
			fi
		else
			if [[ "$w" == *"-plasma5" ]]; then
				WIDGETS+=("$w")
			fi
		fi
	done

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
	if command -v killall &> /dev/null; then
		killall plasmashell && (kstart plasmashell || kstart5 plasmashell || plasmashell &)
	elif command -v pkill &> /dev/null; then
		pkill plasmashell && (kstart plasmashell || kstart5 plasmashell || plasmashell &)
	else
		echo "[!] Could not restart plasmashell automatically."
	fi
	echo "[+] All done!"

elif [[ -n "$1" && -d "packages/$1" ]]; then
	# Install single widget with reload
	build_translations
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
	echo "  ./install.sh --all --plasma5     Install all KDE 5 widgets"
	echo "  ./install.sh --all --plasma6     Install all KDE 6 widgets"
	exit 1
fi
