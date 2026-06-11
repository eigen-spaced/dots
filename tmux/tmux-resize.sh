#!/usr/bin/env bash
# tmux-resize.sh — drag the pane border in the arrow direction, snapping the
# pane to the next fraction of the window
#
#   tmux-resize.sh <left|right> <pane-w> <window-w> <pane-id> <at-right> <at-left>
#   tmux-resize.sh <up|down>    <pane-h> <window-h> <pane-id> <at-bottom> <at-top>
#
# Stops: 25% 33% 50% 67% 75% (±2% tolerance so integer rounding doesn't get
# stuck). The arrow always moves the divider in the arrow's direction: a pane
# glued to the right/bottom edge of the window only has its left/top border
# to drag, so grow/shrink inverts for it (right-arrow on a right pane moves
# its left border right = shrink). Middle panes use plain grow semantics.
# Bound to PREFIX arrows (sticky 'resize' key table) in .tmux.conf.

set -uo pipefail

arrow=$1 cur=$2 total=$3 pane=$4 at_far=$5 at_near=$6

case $arrow in
  left|right) axis=x ;;
  up|down)    axis=y ;;
esac
case $arrow in
  right|down) dir=grow ;;
  *)          dir=shrink ;;
esac
# Pane sits on the far (right/bottom) edge only: its draggable border is the
# near one, so the arrow's grow/shrink meaning flips
if (( at_far == 1 && at_near == 0 )); then
  if [[ $dir == grow ]]; then dir=shrink; else dir=grow; fi
fi

pct=$(( cur * 100 / total ))
STOPS=(25 33 50 67 75)
new=""

if [[ $dir == grow ]]; then
  for s in "${STOPS[@]}"; do
    (( s > pct + 2 )) && { new=$s; break; }
  done
  new=${new:-75}
else
  for (( i = ${#STOPS[@]} - 1; i >= 0; i-- )); do
    (( STOPS[i] < pct - 2 )) && { new=${STOPS[i]}; break; }
  done
  new=${new:-25}
fi

tmux resize-pane -t "$pane" -"$axis" "$new%"
