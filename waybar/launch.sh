#!/usr/bin/env bash

exec 200>/tmp/waybar-launch.lock
flock -n 200 || exit 0

killall waybar || true
pkill waybar || true
sleep 0.5

# Тема: папка с config и папка с style.css (могут совпадать)
THEME_DIR="$HOME/.config/waybar/themes/starter/"
STYLE_DIR="$HOME/.config/waybar/themes/starter"

# Переопределить, если есть кастомные файлы
CONFIG_FILE="config"
STYLE_FILE="style.css"

[ -f "$THEME_DIR/config-custom" ] && CONFIG_FILE="config-custom"
[ -f "$STYLE_DIR/style-custom.css" ] && STYLE_FILE="style-custom.css"

HYPRLAND_INSTANCE_SIGNATURE=$(hyprctl instances -j | jq -r '.[0].instance')
export HYPRLAND_INSTANCE_SIGNATURE

# waybar -c "$THEME_DIR/$CONFIG_FILE" -s "$STYLE_DIR/$STYLE_FILE" &
waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css

flock -u 200
exec 200>&-

