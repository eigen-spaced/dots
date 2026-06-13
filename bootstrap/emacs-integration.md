# Emacs deep-integration setup (macOS)

How to bring up the full Emacs setup on a fresh Mac: the daemon, Doom, the
global Hammerspoon hotkeys, **mu4e** (Gmail), **smudge** (Spotify), and
**emacs-everywhere**. The package installs and symlinks are handled by the
bootstrap (`mac.sh` + `install.sh`); this doc covers the manual, credential-
bearing steps the bootstrap can't automate.

> **Secrets never live in this repo.** Passwords and API keys go in the macOS
> **Keychain**; personal values (name/email) go in `doom/.doom.d/private.el`,
> which is git-ignored (template: `private.el.example`). Run any command that
> takes a secret in a **private terminal**, and use `read -rs` so it stays out
> of your shell history.
>
> **Shortcut:** `bootstrap/setup-emacs-integration.sh` walks through sections
> 1–3 below interactively (prompts for secrets → Keychain, writes `~/.mbsyncrc`,
> runs the first sync, opens the Accessibility pane). It's idempotent and
> prompts before storing anything. The rest of this doc is the reference for
> what it does / how to do it by hand.

---

## 0. Prerequisites (handled by the bootstrap)

`bootstrap/mac.sh` installs: `emacs-plus@30`, `mu`, `isync`, `pinentry-mac`,
`terminal-notifier`, `vips` (dirvish thumbnails), and the `hammerspoon` cask.
`bootstrap/install.sh` stows the `doom` and `hammerspoon` packages and offers to
install the `com.sunny.emacs-daemon` LaunchAgent.

After bootstrap, also do the Doom side once:

```bash
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
~/.emacs.d/bin/doom install
~/.emacs.d/bin/doom sync          # builds mu4e, emacs-everywhere, smudge, …
```

Create your private values from the template:

```bash
cp ~/.doom.d/private.el.example ~/.doom.d/private.el
$EDITOR ~/.doom.d/private.el      # set user-full-name + user-mail-address
```

Restart the daemon so everything loads:
`launchctl kickstart -k gui/$(id -u)/com.sunny.emacs-daemon`

---

## 1. mu4e (Gmail)

Mail is synced by **mbsync** (config: `~/.mbsyncrc`, not in this repo) into
`~/.mail/gmail`, indexed by **mu**, and read in **mu4e**. The app password is
pulled from the Keychain — by mbsync via `PassCmd`, and by Emacs SMTP via
`auth-source` (`macos-keychain-internet`).

1. **App password.** Enable 2-Step Verification on the Google account, then
   create an App Password: <https://myaccount.google.com/apppasswords>
   (16 chars; spaces don't matter).

2. **Store it in the Keychain** (IMAP for sync + SMTP for send). In a private
   terminal:

   ```bash
   read -rs PW       # paste the app password, Enter (input hidden)
   security add-internet-password -U -s imap.gmail.com -a <you>@gmail.com -r imap -P 993 -w "$PW"
   security add-internet-password -U -s smtp.gmail.com -a <you>@gmail.com -r smtp -P 587 -w "$PW"
   unset PW
   ```

3. **Make sure `~/.mbsyncrc` exists** (User/PassCmd reference `<you>@gmail.com`).
   It is local-only; recreate it if missing — see the template at the bottom of
   this doc.

4. **First sync + index:**

   ```bash
   mkdir -p ~/.mail/gmail
   mu init --maildir=~/.mail --my-address=<you>@gmail.com
   mbsync -a          # the [Gmail]/All Mail archive can take a while
   mu index
   ```

5. **Use it:** `SPC o m` (or `M-x mu4e`). mu4e refetches every 5 min.

**Sanity check** (no secret printed): `mbsync -l gmail` should list your IMAP
folders — that proves the Keychain password + Gmail auth both work.

---

## 2. smudge (Spotify)

Search/playlists go through the Spotify **Web API** (free developer app);
play/pause/next drive the **local macOS app** via AppleScript
(`smudge-transport` = `apple`), so **no Premium is required** for transport.

1. **Create a free app** at <https://developer.spotify.com/dashboard>.
2. **Redirect URI** — set it to exactly:
   `http://127.0.0.1:8080/smudge_api_callback`
3. **Store client id/secret in the Keychain** (private terminal):

   ```bash
   read -rs ID;  security add-internet-password -U -s smudge -a client-id     -w "$ID";  unset ID
   read -rs SEC; security add-internet-password -U -s smudge -a client-secret -w "$SEC"; unset SEC
   ```

4. **Restart the daemon** so smudge reads the creds:
   `launchctl kickstart -k gui/$(id -u)/com.sunny.emacs-daemon`
5. **Use it:** `SPC o M` (s=search, p=playlist search, m=my playlists,
   SPC=play/pause, n/N=next/prev). First search opens a browser OAuth flow.
   Transport (play/pause) also works globally via ⌘⌥P / ⌘⌥] / ⌘⌥[ and needs no
   credentials.

---

## 3. emacs-everywhere

Edit any macOS text field in Emacs: focus a field in any app, press **⌘⌥E**,
edit, then **`C-c C-c`** to send it back (`C-c C-k` aborts).

- **First use** prompts macOS to let **Emacs** (not Hammerspoon) control
  "System Events" — grant it, or the copy/paste-back won't work
  (System Settings → Privacy & Security → Automation / Accessibility).
- **Known gotcha (auto-handled):** emacs-everywhere compiles its osascript
  helpers in a way that, on current macOS, leaves the compiled files' data fork
  empty → `script error -1758`. `config.el` advises its compile step to
  recompile them as plain data-fork `.scpt`, so this self-heals (including after
  a package rebuild). No action needed.

---

## 4. Hammerspoon (global hotkeys)

Config is the `hammerspoon` stow package (`~/.hammerspoon/init.lua`). Launch
Hammerspoon once (`open -a Hammerspoon`); it auto-loads and reloads on change
(⌘⌥R to reload by hand). Hotkeys:

| Key | Action |
|-----|--------|
| ⌘⌥O | org folder in dirvish |
| ⌘⌥F | dirvish |
| ⌘⌥E | emacs-everywhere |
| ⌘⌥P / ⌘⌥] / ⌘⌥[ | Spotify play-pause / next / prev |
| ⌘⌥I | Spotify now-playing notification |
| ⌘⌥R | reload Hammerspoon config |

(Plain Emacs-launch hotkeys need no Accessibility grant; only emacs-everywhere's
copy/paste does.) Note: ⌘⌥D is macOS's built-in Dock-hide toggle — avoid it.

---

## Reference

- **Restart the daemon:** `launchctl kickstart -k gui/$(id -u)/com.sunny.emacs-daemon`
- **Apply a `config.el` edit without restart:**
  `emacsclient -e '(load (expand-file-name "config.el" doom-user-dir) nil t)'`
  (note: `doom/reload` does *not* re-eval config.el; newly-enabled *modules*
  need a full restart)
- **Debugging a config that won't load:** `emacsclient -e` returns exit 0 even
  when the elisp errors — wrap the load in `condition-case` to see the real
  error.

### `~/.mbsyncrc` template (recreate if missing — local-only, not in this repo)

```
IMAPAccount gmail
Host imap.gmail.com
User <you>@gmail.com
PassCmd "security find-internet-password -s imap.gmail.com -a <you>@gmail.com -w"
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
```
