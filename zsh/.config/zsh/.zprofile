[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# --- PATH / runtime env -----------------------------------------------------
# Login-shell env. Lives here (not interactive-only .zshrc) so a freshly
# launched GUI/daemon Emacs can import a complete PATH via a fast login shell
# (exec-path-from-shell with `-l`, no `-i`). Interactive shells inherit this.
typeset -U path
path=(
    $HOME/.bin
    $HOME/.local/bin
    $HOME/.cargo/bin
    $path
)

# mise — runtime version manager
command -v mise >/dev/null && eval "$(mise activate zsh)"

# personal scripts
export PATH="$HOME/.config/scripts:$PATH"

# pnpm — PNPM_HOME is where `pnpm add -g` puts global binaries (pnpm itself is
# managed by mise).  pnpm's home dir is platform-specific; bins land in <home>/bin.
if [[ "$OSTYPE" == darwin* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
