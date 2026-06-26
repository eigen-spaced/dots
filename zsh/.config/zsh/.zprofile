eval "$(/opt/homebrew/bin/brew shellenv)"

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
eval "$(mise activate zsh)"

# personal scripts
export PATH="$HOME/.config/scripts:$PATH"

# pnpm — PNPM_HOME is where `pnpm add -g` puts global binaries (pnpm itself is
# managed by mise).
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
