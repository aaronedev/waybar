#!/usr/bin/env bash
# Toggles between native Waybar icons and the hyprland-autoname-workspaces service

readonly MODULES_CONFIG="$HOME/.config/waybar/modules.jsonc"
readonly SERVICE_NAME="hyprland-autoname-workspaces.service"

# Check if the systemd service is active
if systemctl --user is-active --quiet "$SERVICE_NAME"; then
  # --- SWITCH TO MANUAL MODE ---
  echo "Switching to Manual Mode..."

  # Stop the systemd service
  systemctl --user stop "$SERVICE_NAME"

  # Reset workspace names to just IDs
  hyprctl workspaces -j | jq -r '.[] | .id' | while read -r id; do
    hyprctl dispatch renameworkspace "$id" "$id"
  done

  # Update Waybar config: Uncomment Manual, Comment Autoname
  sed -i 's|^\s*\"format\":.*###MODE_AUTONAME###|    //"format": "{name}", // ###MODE_AUTONAME###|' "$MODULES_CONFIG"
  sed -i 's|^\s*//\"format\":.*###MODE_MANUAL###|    "format": "<b>{id}</b> {icon}", // ###MODE_MANUAL###|' "$MODULES_CONFIG"

  notify-send -a "Waybar" -i "preferences-desktop-icons" "Workspace Icons" "Manual Mode (Native)"
else
  # --- SWITCH TO AUTONAME MODE ---
  echo "Switching to Autoname Mode..."

  # Start the systemd service
  systemctl --user start "$SERVICE_NAME"

  # Update Waybar config: Comment Manual, Uncomment Autoname
  sed -i 's|^\s*\"format\":.*###MODE_MANUAL###|    //"format": "<b>{id}</b> {icon}", // ###MODE_MANUAL###|' "$MODULES_CONFIG"
  sed -i 's|^\s*//\"format\":.*###MODE_AUTONAME###|    "format": "{name}", // ###MODE_AUTONAME###|' "$MODULES_CONFIG"

  notify-send -a "Waybar" -i "preferences-system-symbolic" "Workspace Icons" "Service Mode (Autoname)"
fi

# Reload Waybar
killall -USR2 waybar
