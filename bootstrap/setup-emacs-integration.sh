#!/usr/bin/env bash
# Guided, interactive setup for the Emacs deep-integration stack on macOS:
#   mu4e (Gmail) · smudge (Spotify) · emacs-everywhere
#
# Companion to emacs-integration.md. Secrets go into the macOS Keychain (you're
# prompted; input is hidden and never stored in a file or shell history).
# Idempotent — safe to re-run; you can skip any section you've already done.
#
# NB: no `set -e` — several prompts intentionally return non-zero ("no").
set -uo pipefail

[[ "$OSTYPE" == darwin* ]] || { echo "This script is macOS-only."; exit 1; }

DOOMDIR="${DOOMDIR:-$HOME/.doom.d}"
SECURITY=/usr/bin/security
DAEMON="com.sunny.emacs-daemon"

bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '  %s\n' "$*"; }
ok()    { printf '  \033[32m%s\033[0m\n' "$*"; }
warn()  { printf '  \033[33m%s\033[0m\n' "$*"; }
ask()   { local a; read -rp "$* [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

# Store an internet-password in the Keychain without leaking it into argv.
# $1 service  $2 account  [$3 protocol]  [$4 port]
kc_store() {
  local svc="$1" acct="$2" proto="${3:-}" port="${4:-}" pw
  read -rsp "    paste value for '$acct' (hidden): " pw; echo
  if [[ -z "$pw" ]]; then warn "empty — skipped"; return 1; fi
  local args=(-U -s "$svc" -a "$acct" -w "$pw")
  [[ -n "$proto" ]] && args+=(-r "$proto")
  [[ -n "$port"  ]] && args+=(-P "$port")
  "$SECURITY" add-internet-password "${args[@]}" && ok "stored '$acct' in Keychain"
  unset pw
}
kc_has() { "$SECURITY" find-internet-password -s "$1" -a "$2" >/dev/null 2>&1; }

# --- preflight --------------------------------------------------------------
bold "Emacs integration setup"
for t in mu mbsync "$SECURITY"; do
  command -v "$t" >/dev/null 2>&1 || warn "missing: $t (run bootstrap/mac.sh first)"
done
echo

# ============================================================================
bold "1) mu4e — Gmail"
if ask "Set up / update mu4e (Gmail) now?"; then
  echo
  info "Prereq: enable 2-Step Verification, then create an App Password at"
  info "  https://myaccount.google.com/apppasswords"
  echo

  # Email address: default from private.el if present.
  default_email=""
  [[ -f "$DOOMDIR/private.el" ]] && default_email=$(
    grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+' "$DOOMDIR/private.el" | head -1)
  read -rp "  Gmail address${default_email:+ [$default_email]}: " email
  email="${email:-$default_email}"
  if [[ -z "$email" ]]; then
    warn "no address given — skipping mu4e"
  else
    # Keychain: IMAP (sync) + SMTP (send).
    for pair in "imap.gmail.com imap 993" "smtp.gmail.com smtp 587"; do
      read -r host proto port <<<"$pair"
      if kc_has "$host" "$email"; then
        ok "$host already has a Keychain entry"
        ask "    replace it?" && kc_store "$host" "$email" "$proto" "$port"
      else
        info "storing app password for $host"
        kc_store "$host" "$email" "$proto" "$port"
      fi
    done

    # ~/.mbsyncrc (local-only; not in the dotfiles repo).
    if [[ -f "$HOME/.mbsyncrc" ]] && ! ask "  ~/.mbsyncrc exists — overwrite?"; then
      info "keeping existing ~/.mbsyncrc"
    else
      cat > "$HOME/.mbsyncrc" <<EOF
IMAPAccount gmail
Host imap.gmail.com
User $email
PassCmd "security find-internet-password -s imap.gmail.com -a $email -w"
TLSType IMAPS
AuthMechs LOGIN
PipelineDepth 50

IMAPStore gmail-remote
Account gmail

MaildirStore gmail-local
Subfolders Verbatim
Path ~/.mail/gmail/
Inbox ~/.mail/gmail/INBOX

Channel gmail
Far :gmail-remote:
Near :gmail-local:
Patterns "INBOX" "[Gmail]/Sent Mail" "[Gmail]/Drafts" "[Gmail]/Trash" "[Gmail]/All Mail" "[Gmail]/Starred"
Create Both
Expunge Both
SyncState *
CopyArrivalDate yes
EOF
      ok "wrote ~/.mbsyncrc"
    fi

    # Initialise mu + first sync.
    mkdir -p "$HOME/.mail/gmail"
    mu init --maildir="$HOME/.mail" --my-address="$email" 2>/dev/null && ok "mu initialised"
    if ask "  Run the first sync now (mbsync -a && mu index)? May take a while."; then
      mbsync -a && mu index && ok "mail synced + indexed (open with SPC o m)"
    else
      info "later: mbsync -a && mu index"
    fi
  fi
fi
echo

# ============================================================================
bold "2) smudge — Spotify"
if ask "Set up / update smudge (Spotify) now?"; then
  echo
  info "Prereq: create a free app at https://developer.spotify.com/dashboard"
  info "and set its Redirect URI to exactly:"
  info "  http://127.0.0.1:8080/smudge_api_callback"
  echo
  for acct in client-id client-secret; do
    if kc_has smudge "$acct"; then
      ok "smudge/$acct already in Keychain"
      ask "    replace it?" && kc_store smudge "$acct"
    else
      info "storing $acct"
      kc_store smudge "$acct"
    fi
  done
  info "Use it with SPC o M (first search opens a browser OAuth flow)."
fi
echo

# ============================================================================
bold "3) emacs-everywhere — Accessibility"
info "⌘⌥E edits any text field in Emacs; C-c C-c sends it back."
info "First use prompts macOS to let *Emacs* control System Events — grant it."
if ask "Open the Accessibility settings pane now?"; then
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
fi
echo

# ============================================================================
bold "Done."
if ask "Restart the Emacs daemon now (so new Keychain creds load)?"; then
  launchctl kickstart -k "gui/$(id -u)/$DAEMON" && ok "daemon restarted"
fi
info "Full reference: bootstrap/emacs-integration.md"
