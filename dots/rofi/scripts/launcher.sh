#!/bin/bash

THEME="$HOME/.config/rofi/themes/launcher.rasi"

if pgrep -x "rofi" > /dev/null; then
    pkill -x rofi
else
    rofi -show drun -theme "$THEME"
fi
