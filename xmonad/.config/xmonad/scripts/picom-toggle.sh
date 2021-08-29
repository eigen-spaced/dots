#!/bin/bash
if pgrep -x "picom" > /dev/null
then
  killall picom
else

  # picom -b --config ~/.config/xmonad/scripts/picom.conf
  picom -b --experimental-backends --config ~/.config/xmonad/scripts/picom.conf
fi
