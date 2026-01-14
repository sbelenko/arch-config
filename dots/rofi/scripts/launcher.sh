#!/bin/bash

THEME="$HOME/.config/rofi/themes/raycast.rasi"

if pgrep -x "rofi" > /dev/null; then
    pkill -x rofi
else
    rofi -show drun -theme "$THEME"
fi
