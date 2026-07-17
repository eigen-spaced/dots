#!/usr/bin/env bash
# tmux-sessions.sh — telescope-style fzf popups for tmux
#
# Modes:
#   (default)    session/window navigator: open sessions (MRU first, current
#                last) with their windows nested underneath
#   --quick      quick window switcher: a centered native menu of the current
#                session's windows; pressing a window's number jumps to it
#                instantly (esc closes). Labels match the status bar.
#   --rename     rename the current session in a small popup (fzf as the
#                input field, pre-filled with the current name)
#   --projects   project picker: projectile-style discovery under
#                $PROJECTS_DIR (a dir is a project root if it contains one of
#                $MARKERS; non-project top-level dirs are scanned for nested
#                projects, shown as parent/child; marker-less folders are
#                listed as themselves)
#
#   enter   session/window -> switch to it
#           project        -> create session named after it (cwd there), switch
#           no match       -> create a session named after whatever you typed
#   ctrl-x  (navigator) kill the selected session or window (picker reopens;
#           detach-on-destroy off in .tmux.conf keeps the client in tmux)
#   esc     close
#
# Preview: windows for a session, live pane content for a window,
# directory listing for a project.
#
# Each line is "<meta>\t<display>"; fzf shows only the display field and the
# meta field drives preview/actions.  S=<session>  W=<session>:<index>
# F=<path relative to $PROJECTS_DIR>
#
# Bound in .tmux.conf: PREFIX f (navigator), PREFIX o (projects).

set -uo pipefail

PROJECTS_DIR="${TMUX_PROJECTS_DIR:-$HOME/Documents/projects}"
MARKERS=(.git .hg .svn package.json Cargo.toml pyproject.toml setup.py
         requirements.txt go.mod mix.exs deps.edn project.clj build.gradle
         pom.xml CMakeLists.txt flake.nix .projectile)
MAX_NESTED_DEPTH=2  # how deep to look for projects inside non-project folders

# Nerd-font glyphs via UTF-8 byte escapes
SESSION_ICON=$'\xef\x92\x89'   # nf-oct-terminal
WINDOW_ICON=$'\xef\x8b\x90'    # nf-fa-window-maximize
FOLDER_ICON=$'\xef\x81\xbb'    # nf-fa-folder
TAB=$'\t'

# tmux session names can't contain '.' or ':'
sanitize() { local n=$1; n=${n//./_}; printf '%s' "${n//:/_}"; }

## Session/window navigator ##################################################

list_session() {  # $1 = session name, $2 = suffix label
  printf 'S=%s\t%s %s%s\n' "$1" "$SESSION_ICON" "$1" "$2"
  tmux list-windows -t "=$1" \
    -F "W=$1:#{window_index}${TAB}   $WINDOW_ICON #{window_index} #{window_name}#{?window_active, *,}"
}

list_sessions() {
  local current s
  current=$(tmux display-message -p '#S')
  # Other sessions, most recently attached first (alt-tab style)
  while IFS= read -r s; do
    [[ $s == "$current" ]] && continue
    list_session "$s" ""
  done < <(tmux list-sessions -F '#{session_last_attached} #{session_name}' \
             | sort -rn | cut -d' ' -f2-)
  # Current session last
  list_session "$current" "  (current)"
}

## Project discovery #########################################################

is_project() {
  local m
  for m in "${MARKERS[@]}"; do [[ -e $1/$m ]] && return 0; done
  return 1
}

find_projects_in() {  # emit project dirs under $1, up to $2 levels down
  local dir=$1 rem=$2 d
  for d in "$dir"/*/; do
    [[ -d $d ]] || continue
    d=${d%/}
    [[ $(basename "$d") == node_modules ]] && continue
    if is_project "$d"; then
      printf '%s\n' "$d"
    elif (( rem > 1 )); then
      find_projects_in "$d" $((rem - 1))
    fi
  done
}

list_projects() {
  local d nested rel
  for d in "$PROJECTS_DIR"/*/; do
    [[ -d $d ]] || continue
    d=${d%/}
    if is_project "$d"; then
      printf '%s\n' "$d"
    else
      nested=$(find_projects_in "$d" "$MAX_NESTED_DEPTH")
      # Grouping folder -> list its projects; plain folder -> list itself
      if [[ -n $nested ]]; then printf '%s\n' "$nested"; else printf '%s\n' "$d"; fi
    fi
  done | while IFS= read -r d; do
    rel=${d#"$PROJECTS_DIR"/}
    tmux has-session -t "=$(sanitize "$(basename "$rel")")" 2>/dev/null && continue
    printf 'F=%s\t%s %s\n' "$rel" "$FOLDER_ICON" "$rel"
  done
}

## Preview ###################################################################

preview() {  # $1 = meta field
  case $1 in
    S=*) tmux list-windows -t "=${1#S=}" \
           -F '#I #W  (#{b:pane_current_path})#{?window_active, *,}' ;;
    W=*) tmux capture-pane -ep -t "=${1#W=}" ;;
    F=*) ls -A1 "$PROJECTS_DIR/${1#F=}" 2>/dev/null ;;
  esac
}

## Quick window switcher #####################################################

quick_switch() {  # $1 = client name (passed by the binding for menu display)
  local client=${1:-} menu=() idx pid cmd dir auto name active label key
  while IFS=$'\t' read -r idx pid cmd dir auto name active; do
    if [[ $auto == 1 ]]; then
      (( ${#dir} > 12 )) && dir="${dir:0:12}…"
      label="$("${0%/*}/tmux-label.sh" "$pid" "$cmd")·$dir"
    else
      label=$name
    fi
    [[ $active == 1 ]] && label="$label  ◂"
    key=$idx; (( idx > 9 )) && key=''
    menu+=("$label" "$key" "select-window -t :$idx")
  done < <(tmux list-windows \
    -F "#{window_index}	#{pane_pid}	#{pane_current_command}	#{b:pane_current_path}	#{?automatic-rename,1,0}	#{window_name}	#{?window_active,1,0}")
  if [[ -n $client ]]; then
    tmux display-menu -c "$client" -T ' windows ' -x C -y C "${menu[@]}"
  else
    printf '%s\n' "${menu[@]}"  # dry run for testing
  fi
}

## Rename ####################################################################

rename_session() {
  local cur new
  cur=$(tmux display-message -p '#S')
  new=$(: | fzf --print-query --query "$cur" --no-info --reverse \
          --prompt ' rename ❯ ' \
          --header 'enter: rename  ·  esc: cancel' | sed -n 1p)
  [[ -z $new || $new == "$cur" ]] && return 0
  new=$(sanitize "$new")
  tmux rename-session -- "$new" 2>/dev/null \
    || tmux display-message "rename failed: is '$new' already taken?"
}

## Main ######################################################################

case ${1:-} in
  --preview) preview "$2"; exit 0 ;;
  --rename)  rename_session; exit 0 ;;
  --quick)   quick_switch "${2:-}"; exit 0 ;;
esac

MODE=sessions LIST_ONLY=0
for a in "$@"; do
  case $a in
    --projects) MODE=projects ;;
    --list)     LIST_ONLY=1 ;;   # for testing/inspection
  esac
done

if [[ $MODE == projects ]]; then
  LIST_CMD=list_projects
  HEADER='enter: open project session'
  EXPECT=''
else
  LIST_CMD=list_sessions
  HEADER='enter: switch  ·  ctrl-x: kill'
  EXPECT='ctrl-x'
fi

if (( LIST_ONLY )); then "$LIST_CMD"; exit 0; fi

out=$("$LIST_CMD" | fzf \
  --reverse --no-sort --print-query --expect="$EXPECT" \
  --delimiter="$TAB" --with-nth=2 --ansi \
  --prompt=' ❯ ' --info=inline-right \
  --header="$HEADER" \
  --preview="\"$0\" --preview {1}" \
  --preview-window='right,55%,border-left')
[[ $? -eq 130 ]] && exit 0  # esc / ctrl-c

query=$(sed -n 1p <<<"$out")
key=$(sed -n 2p <<<"$out")
sel=$(sed -n 3p <<<"$out")
meta=${sel%%"$TAB"*}
type=${meta%%=*}
value=${meta#*=}

if [[ $key == ctrl-x ]]; then
  case $type in
    S) tmux kill-session -t "=$value" ;;
    W) tmux kill-window  -t "=$value" ;;
  esac
  exec "$0" "$@"
fi

if [[ -n $sel ]]; then
  case $type in
    # switch-client accepts session:window, so S and W share a command
    S|W) tmux switch-client -t "=$value" ;;
    F)
      sname=$(sanitize "$(basename "$value")")
      tmux new-session -ds "$sname" -c "$PROJECTS_DIR/$value" 2>/dev/null
      tmux switch-client -t "=$sname"
      ;;
  esac
elif [[ -n $query ]]; then
  sname=$(sanitize "$query")
  tmux new-session -ds "$sname" 2>/dev/null
  tmux switch-client -t "=$sname"
fi
