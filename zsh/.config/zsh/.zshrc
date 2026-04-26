# ~/.config/zsh/.zshrc
# Sourced for every interactive zsh. Keep it lean — feature blocks live in
# zsh-functions, zsh-vim, zsh-aliases, zsh-aliases-{mac,arch}, zsh-prompt.

# --- OS detection -----------------------------------------------------------
unset IS_MAC IS_ARCH
case "$OSTYPE" in
    darwin*) IS_MAC=1 ;;
    linux*)  [[ -f /etc/arch-release ]] && IS_ARCH=1 ;;
esac

# --- PATH (deduped) ---------------------------------------------------------
typeset -U path
path=(
    $HOME/.bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $path
)

# --- History ----------------------------------------------------------------
HISTFILE="$HOME/.config/zsh/zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# --- Shell options ----------------------------------------------------------
setopt autocd extendedglob interactive_comments
setopt AUTO_PARAM_SLASH      # tab-completing a directory appends a /
setopt GLOB_DOTS             # globs match dotfiles
unsetopt BEEP
unsetopt nomatch             # let unmatched globs pass through literally
unsetopt MENU_COMPLETE       # don't auto-insert first match on tab
unsetopt AUTO_MENU           # don't open menu on second tab automatically

# Word boundaries for ^W and friends (slash is removed by my-backward-delete-word)
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

zle_highlight=('paste:none')

# --- Completion -------------------------------------------------------------
autoload -U compinit && compinit -u
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
_comp_options+=(globdots)    # let completion see hidden files

# --- Modular config (loader helpers + utility funcs come first) -------------
source "$ZDOTDIR/zsh-functions"

zsh_add_file "zsh-vim"
zsh_add_file "zsh-aliases"
[[ -n $IS_MAC  ]] && zsh_add_file "zsh-aliases-mac"
[[ -n $IS_ARCH ]] && zsh_add_file "zsh-aliases-arch"
zsh_add_file "zsh-prompt"

# --- Plugins ----------------------------------------------------------------
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "zsh-users/zsh-history-substring-search"
zsh_add_plugin "hlissner/zsh-autopair"
# More plugins:    https://github.com/unixorn/awesome-zsh-plugins
# More completions: https://github.com/zsh-users/zsh-completions

# Disable underline styling on paths in syntax highlighting
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Bindings whose targets are defined in zsh-functions / plugins
bindkey '^W' my-backward-delete-word

# --- Editor -----------------------------------------------------------------
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

# --- Tool integrations ------------------------------------------------------
# mise — runtime version manager
eval "$(mise activate zsh)"

# pip safety: require a virtualenv unless gpip is used (defined in zsh-functions)
export PIP_REQUIRE_VIRTUALENV=true

# pnpm (path differs by OS)
if [[ -n $IS_MAC ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
elif [[ -n $IS_ARCH ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
if [[ -n "$PNPM_HOME" ]]; then
    case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
    esac
fi

# Optional: dictionary helper if you have it installed
[[ -f "$HOME/.config/scripts/define.sh" ]] && source "$HOME/.config/scripts/define.sh"

# Personal/private overrides — not committed
[[ -f "$HOME/.zshrc-personal" ]] && source "$HOME/.zshrc-personal"
