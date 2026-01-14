#!/usr/bin/env bash

lock="󰌾  Lock"
suspend="󰤄  Suspend"
logout="󰍃  Logout"
reboot="󰜉  Reboot"
shutdown="󰐥  Shutdown"

options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/themes/powermenu.rasi)"

case $chosen in
    $lock)     loginctl lock-session ;;
    $suspend)  systemctl suspend ;;
    $logout)   loginctl terminate-session self ;;
    $reboot)   systemctl reboot ;;
    $shutdown) systemctl poweroff ;;
esac
