#!/usr/bin/env bash
# tmux-label.sh — friendly process label for a tmux pane
#
#   tmux-label.sh <pane_pid> <pane_current_command>
#
# Interpreters (node, python, …) are resolved to the script they're running
# by inspecting argv in the process tree, so npm-distributed CLIs get their
# real name (codex, npm, …) instead of the interpreter's. Claude Code's
# binary is named after its version (e.g. 2.1.170), which maps to "claude".
# Used by automatic-rename-format in .tmux.conf.

set -uo pipefail

pid=${1:-} cmd=${2:-}

INTERPRETERS='node|deno|bun|python|python2|python3|ruby|perl'

resolve() {  # print the script basename if process $1 is interpreter+script
  local argv
  argv=$(ps -o command= -p "$1" 2>/dev/null) || return 1
  # shellcheck disable=SC2086
  set -- $argv
  # ${var##*/} instead of basename: argv0 of login shells is "-zsh", which
  # macOS basename rejects as an option
  local a0=${1:-} a1=${2:-}
  if [[ ${a0##*/} =~ ^($INTERPRETERS)$ && -n $a1 && ${a1:0:1} != "-" ]]; then
    printf '%s' "${a1##*/}"
    return 0
  fi
  return 1
}

label=""
if [[ $cmd =~ ^($INTERPRETERS)$ ]]; then
  # newest child of the pane root first (the foreground job), then the pane
  # root itself (covers windows started directly with a command, no shell)
  for p in $(pgrep -P "$pid" 2>/dev/null | sort -rn) "$pid"; do
    label=$(resolve "$p") && break
  done
fi
[[ -z $label ]] && label=$cmd
# Claude Code's binary is named after its version
[[ $label =~ ^[0-9][0-9.]*$ ]] && label=claude
printf '%s' "$label"
