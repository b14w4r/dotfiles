#!/usr/bin/env bash

config="$HOME/.config/gtk-3.0/settings.ini"
[ -f "$config" ] || exit 1

gnome_schema="org.gnome.desktop.interface"
gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_size="$(grep 'gtk-cursor-theme-size' "$config" | sed 's/.*\s*=\s*//')"
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"
prefer_dark_theme="$(grep 'gtk-application-prefer-dark-theme' "$config" | sed 's/.*\s*=\s*//')"

terminal="ghostty"

if [ "$prefer_dark_theme" = "0" ]; then
    prefer_dark_theme_value="prefer-light"
else
    prefer_dark_theme_value="prefer-dark"
fi

gsettings set "$gnome_schema" gtk-theme "$gtk_theme"
gsettings set "$gnome_schema" icon-theme "$icon_theme"
gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
gsettings set "$gnome_schema" font-name "$font_name"
gsettings set "$gnome_schema" color-scheme "$prefer_dark_theme_value"

if [ -f "$HOME/.config/hypr/conf/cursor.conf" ]; then
    echo "exec-once = hyprctl setcursor $cursor_theme $cursor_size" > "$HOME/.config/hypr/conf/cursor.conf"
    hyprctl setcursor "$cursor_theme" "$cursor_size"
fi

if gsettings list-schemas | grep -qx 'com.github.stunkymonkey.nautilus-open-any-terminal'; then
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal "$terminal"
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-generic-terminal-name "true"
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal keybindings "<Ctrl><Alt>t"
fi

