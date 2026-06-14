;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Fit new frames to the screen as a normal maximized window (daemon/
;; emacsclient frames included). For native macOS fullscreen (own Space),
;; use '(fullscreen . fullboth) instead.
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; In daemon mode Doom only loads the theme/fonts via
;; `server-after-make-frame-hook', which fires for `emacsclient -c/-t' frames
;; but NOT for frames created by `emacsclient -e "(make-frame ...)"' (how the
;; Emacs.app launcher opens a focused frame). Without this, launcher frames come
;; up unthemed (white) with the wrong font. `doom-init-theme-h' is idempotent
;; and themes/fonts are global, so running it on the first such frame is enough.
(when (daemonp)
  (dolist (fn '(doom-init-theme-h doom-init-fonts-h))
    (when (fboundp fn)
      (add-hook 'after-make-frame-functions fn))))

(setq doom-font (font-spec :family "Cascadia Code NF" :size 17))
;; `doom-serif-font' sets the `fixed-pitch-serif' face — which nothing uses by
;; default. eww/shr and variable-pitch-mode render prose with the `variable-pitch'
;; face instead, so we actually get serif by remapping THAT (below), buffer-locally.
;; (Static optical-size family is "Merriweather 24pt", not "Merriweather".)
(setq doom-serif-font (font-spec :family "Merriweather 24pt"))
(setq doom-theme 'doom-carbonfox)

;; --- Merriweather (serif) for reading prose, in eww + org only ---------------
(defun cust/reading-serif ()
  "Remap the current buffer's `variable-pitch' face to Merriweather."
  (face-remap-add-relative 'variable-pitch :family "Merriweather 24pt"))

;; eww: shr renders body text with `variable-pitch' → serif while reading.
(add-hook 'eww-mode-hook #'cust/reading-serif)

;; org: serif prose, but keep code blocks / tables / metadata monospace.
(defvar cust/org-keep-mono-faces
  '(org-block org-block-begin-line org-block-end-line org-code org-verbatim
    org-table org-formula org-meta-line org-document-info-keyword
    org-special-keyword org-property-value org-drawer
    font-lock-comment-face font-lock-comment-delimiter-face
    line-number line-number-current-line)
  "Org faces pinned to `fixed-pitch' (monospace) under `cust/org-prose-serif'.")

(defun cust/org-prose-serif ()
  "Render org prose in Merriweather (serif); keep code/tables/metadata mono."
  (cust/reading-serif)
  (dolist (f cust/org-keep-mono-faces)
    (face-remap-add-relative f 'fixed-pitch))
  (variable-pitch-mode 1))

(add-hook 'org-mode-hook #'cust/org-prose-serif)

;; Centered reading column in eww — OFF by default (eww keeps its normal width);
;; toggle a centered, fixed-width column per-buffer with `SPC m c' (olivetti).
(after! olivetti (setq olivetti-body-width 80))
(map! :after eww :map eww-mode-map :localleader
      :desc "Toggle centered column" "c" #'olivetti-mode)

(setq display-line-numbers-type t)

;; `org-directory' must be set before org loads.
(setq org-directory "~/org/")

;; GTD-lite org setup: agenda, capture, refile, reading list, roam, clocking.
(load! "org-config")

;;; ---------------------------------------------
;;; //              Keybindings                //
;;; ---------------------------------------------
;; Switch to a window based on key binding in normal mode (Evil mode)
(map! :n
      "C-h" #'evil-window-left
      "C-l" #'evil-window-right
      "C-k" #'evil-window-up
      "C-j" #'evil-window-down)

;; Split-opening of files is now handled by the embark C-v / C-s bindings below
;; (works in any vertico finder), so the old split-first commands are gone and
;; SPC f s reverts to Doom's `save-buffer'.
(after! evil
  (setq evil-escape-key-sequence "jk")
  (evil-escape-mode)
  (map! :n "C-b" #'consult-buffer
        :n "C-p" #'projectile-find-file))

;;; fzf-lua-style splits from the minibuffer (embark).
;; With a file/buffer candidate highlighted in ANY vertico finder (find-file,
;; projectile, consult-buffer, …), C-v opens it in a vertical split and C-s in a
;; horizontal one, then closes the minibuffer — mirroring fzf-lua's C-v / C-s.
;; embark resolves the candidate (and its directory), so paths are always right.
(after! embark
  (defun cust/embark-find-file-vsplit (file)
    "Open FILE in a vertical split (embark action)."
    (interactive "FFile: ")
    (select-window (split-window-right))
    (find-file file))
  (defun cust/embark-find-file-hsplit (file)
    "Open FILE in a horizontal split (embark action)."
    (interactive "FFile: ")
    (select-window (split-window-below))
    (find-file file))
  (defun cust/embark-buffer-vsplit (buffer)
    "Display BUFFER in a vertical split (embark action)."
    (interactive "bBuffer: ")
    (select-window (split-window-right))
    (switch-to-buffer buffer))
  (defun cust/embark-buffer-hsplit (buffer)
    "Display BUFFER in a horizontal split (embark action)."
    (interactive "bBuffer: ")
    (select-window (split-window-below))
    (switch-to-buffer buffer))
  (define-key embark-file-map   (kbd "C-v") #'cust/embark-find-file-vsplit)
  (define-key embark-file-map   (kbd "C-s") #'cust/embark-find-file-hsplit)
  (define-key embark-buffer-map (kbd "C-v") #'cust/embark-buffer-vsplit)
  (define-key embark-buffer-map (kbd "C-s") #'cust/embark-buffer-hsplit))

(defun cust/embark-act-key (keystr)
  "Run `embark-act' on the current target, auto-choosing the action bound to
KEYSTR in that target's action map (no action prompt appears). Used to make a
single minibuffer keypress act on the highlighted candidate."
  (require 'embark)
  (let ((embark-prompter
         (lambda (keymap &optional _update) (lookup-key keymap (kbd keystr)))))
    (embark-act)))

(after! vertico
  (define-key vertico-map (kbd "C-v")
              (lambda () (interactive) (cust/embark-act-key "C-v")))
  (define-key vertico-map (kbd "C-s")
              (lambda () (interactive) (cust/embark-act-key "C-s"))))

;;; Quick access: org folder + dirvish.
;; These same commands are also fired by the global Hammerspoon hotkeys
;; (~/.hammerspoon/init.lua) via `emacsclient -e', so the leader keys and the
;; system-wide hotkeys do exactly the same thing.
(defun cust/dirvish-org ()
  "Open the org directory (`org-directory') in Dirvish."
  (interactive)
  (dirvish org-directory))

(defun cust/popup-frame (command)
  "Create a focused macOS GUI frame and run COMMAND (a symbol) in it.
Entry point for the global Hammerspoon hotkeys: the daemon has no frame of
its own, so we make one, pull it to the foreground, then invoke COMMAND."
  (select-frame-set-input-focus (make-frame '((window-system . ns))))
  (call-interactively command))

(map! :leader
      :desc "Dirvish (here)"        "o d" #'dirvish
      :desc "Org folder (Dirvish)"  "o n" #'cust/dirvish-org)

;;; ---------------------------------------------
;;; //                   Misc                  //
;;; ---------------------------------------------

;; ~/.doom.d is stow symlinks into ~/dotfiles, and `doom/find-file-in-private-config'
;; (SPC f p) lists files via projectile's `find', which skips symlinks — so it
;; came up empty. Reimplement it symlink-aware with `directory-files-recursively'
;; (which includes symlinked files but doesn't chase symlinked dirs).
(defun doom/find-file-in-private-config ()
  "Find a file under `doom-user-dir' (symlink-aware; our config is stowed)."
  (interactive)
  (let* ((dir doom-user-dir)
         (rel (mapcar (lambda (f) (file-relative-name f dir))
                      (directory-files-recursively dir "" nil))))
    (find-file (expand-file-name
                (completing-read "Find file in config: " rel nil t)
                dir))))

(after! rustic
  (setq rustic-lsp-client 'lsp-mode))

;; Machine-local, *git-ignored* personal values (name + email) live in
;; private.el, loaded here if present (3rd arg = noerror). Keeps your address
;; out of this tracked file; a fresh clone simply skips it. See
;; private.el.example for the template to recreate it on a new machine.
(load! "private" nil t)

;; Read secrets (Gmail app password, Spotify client id/secret) from the macOS
;; Keychain so nothing sensitive lives in this (repo-tracked) file.
(after! auth-source
  (add-to-list 'auth-sources 'macos-keychain-internet))

;;; ---------------------------------------------
;;; //               Email (mu4e)              //
;;; ---------------------------------------------
;; `mbsync' (isync) syncs Gmail into ~/.mail; `mu' indexes it. The Gmail *app
;; password* is read from the macOS Keychain — via auth-source here (SMTP) and
;; via `PassCmd' in ~/.mbsyncrc (IMAP) — so no secret is stored in this file.
;; Name/address come from private.el (`user-mail-address' / `user-full-name').
;; First-time setup steps live in the comment block at the end of ~/.mbsyncrc.
(after! mu4e
  (setq mu4e-root-maildir "~/.mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300            ; background fetch every 5 min
        mu4e-attachment-dir "~/Downloads"
        message-send-mail-function #'smtpmail-send-it
        ;; Gmail saves its own copy of sent mail; don't let mu4e double it up.
        mu4e-sent-messages-behavior 'delete)

  (set-email-account! "gmail"
    `((user-mail-address      . ,user-mail-address)
      (user-full-name         . ,user-full-name)
      (mu4e-sent-folder       . "/gmail/[Gmail]/Sent Mail")
      (mu4e-drafts-folder     . "/gmail/[Gmail]/Drafts")
      (mu4e-trash-folder      . "/gmail/[Gmail]/Trash")
      (mu4e-refile-folder     . "/gmail/[Gmail]/All Mail")
      (smtpmail-smtp-user     . ,user-mail-address)
      (smtpmail-smtp-server   . "smtp.gmail.com")
      (smtpmail-smtp-service  . 587)
      (smtpmail-stream-type   . starttls))
    t))

;;; ---------------------------------------------
;;; //             Spotify (smudge)            //
;;; ---------------------------------------------
;; Search / playlist browsing use the Spotify Web API (needs a free developer
;; app — client id/secret, kept in the Keychain, see setup notes), while
;; play/pause/next drive the local macOS app via AppleScript
;; (`smudge-transport' = 'apple) so no Premium is required for transport.
;; The same transport is also exposed as global ⌘⌥ hotkeys in ~/.hammerspoon.
(use-package! smudge
  :defer t
  :init
  (setq smudge-transport 'apple
        smudge-status-location 'modeline)
  :config
  (let ((id  (auth-source-pick-first-password :host "smudge" :user "client-id"))
        (sec (auth-source-pick-first-password :host "smudge" :user "client-secret")))
    (when id  (setq smudge-oauth2-client-id id))
    (when sec (setq smudge-oauth2-client-secret sec)))
  ;; smudge's first Web-API call runs an OAuth flow that busy-waits (blocking
  ;; Emacs) until you authorize in the browser — and it hides its own "waiting"
  ;; message. Surface a clear instruction so the block isn't mistaken for a hang.
  ;; Once authorized, the token persists (~/.emacs.d/.local/cache/oauth2.plstore)
  ;; and later calls don't block.
  (advice-add 'smudge-api-oauth2-auth :before
              (lambda (&rest _)
                (message "Smudge: a browser is opening — authorize Spotify there; Emacs resumes once you do.")))
  ;; smudge refreshes its mode-line status var on a 5s poll timer but never calls
  ;; `force-mode-line-update', so the indicator only repaints on the next user
  ;; action — it looks stale after a direct play/pause in Spotify. Force a repaint
  ;; whenever the status string is updated.
  (advice-add 'smudge-controller-update-player-status :after
              (lambda (&rest _) (force-mode-line-update t)))
  ;; smudge's list-buffer keys (l = load more / next page, g = reload) are in its
  ;; mode-maps, but in Doom these buffers come up in evil normal state where l/g
  ;; are evil motions, so they never reach smudge. Re-bind for evil normal state
  ;; so pagination works as documented. (smudge also binds a/r/f/u/k, likewise
  ;; shadowed by evil — add here too if you start using them.)
  (evil-define-key 'normal smudge-playlist-search-mode-map
    "l" #'smudge-playlist-load-more
    "g" #'smudge-playlist-reload)
  (evil-define-key 'normal smudge-track-search-mode-map
    "l" #'smudge-track-load-more
    "g" #'smudge-track-reload
    (kbd "RET") #'smudge-track-select) ; play track-at-point (smudge only binds M-RET)
  ;; `l' (load-more) reprints the whole tabulated list and dumps point at the
  ;; top despite remember-pos. Save/restore the line around the reprint so paging
  ;; keeps you where you were. (Named advice => idempotent across config reloads.)
  (defun cust/smudge-preserve-point (orig &rest args)
    "Keep point on the same line when smudge reprints a list buffer."
    (let ((line (line-number-at-pos)))
      (apply orig args)
      (goto-char (point-min))
      (forward-line (1- line))))
  (advice-add 'smudge-track-search-print    :around #'cust/smudge-preserve-point)
  (advice-add 'smudge-playlist-search-print :around #'cust/smudge-preserve-point)
  ;; Feb-2026 Spotify Web API fixes now live in our fork (eigen-spaced/smudge,
  ;; pinned in packages.el) rather than the old smudge-2026.el override shim.
  (global-smudge-remote-mode 1))

;; Wake up smudge without opening any UI. smudge is deferred and its transport
;; commands (play/pause/next/prev) aren't autoloaded, so they're dead until the
;; package loads — previously you had to open playlists (SPC o M m) and `q' out
;; just to kick it alive. This loads smudge (which runs the :config above:
;; transport, creds, global-smudge-remote-mode) so transport works immediately.
(defun cust/smudge-connect ()
  "Load + initialize smudge so transport (play/pause/next/prev) works.
No UI, and no OAuth needed for the AppleScript transport."
  (interactive)
  (require 'smudge)
  ;; Enable explicitly: smudge's :config only runs on first load, so after a
  ;; `cust/smudge-disconnect' the mode would otherwise stay off.
  (global-smudge-remote-mode 1)
  (ignore-errors (smudge-controller-player-status))
  (message "Smudge ready — transport active."))

;; Inverse of the above: hide smudge's player info from the modeline and stop its
;; status poll when you don't want it. Transport (play/pause/next/prev) keeps
;; working if smudge is already loaded — this only affects the modeline display.
(defun cust/smudge-disconnect ()
  "Turn off smudge's modeline player info + status polling."
  (interactive)
  (when (bound-and-true-p global-smudge-remote-mode)
    (global-smudge-remote-mode -1))
  (message "Smudge: player info hidden."))

;; SPC o M -> Spotify (SPC o m is already `=mu4e', the mail launcher). smudge is
;; autoloaded, so these pull it in on first use.
(map! :leader
      (:prefix ("o M" . "music")
       :desc "Connect / wake"    "c"   #'cust/smudge-connect
       :desc "Disconnect / hide" "C"   #'cust/smudge-disconnect
       :desc "Track search"      "s"   #'smudge-track-search
       :desc "Playlist search"   "p"   #'smudge-playlist-search
       :desc "My playlists"      "m"   #'smudge-my-playlists
       :desc "Add playing→playlist" "a" #'smudge-add-playing-track-to-playlist
       :desc "Play/pause"        "SPC" #'smudge-controller-toggle-play
       :desc "Next track"        "n"   #'smudge-controller-next-track
       :desc "Previous track"    "N"   #'smudge-controller-previous-track))

;;; ---------------------------------------------
;;; //          emacs-everywhere (macOS)        //
;;; ---------------------------------------------
;; emacs-everywhere compiles its osascript helpers with `osacompile -t osas
;; -r scpt:128', which on current macOS writes the script into the file's
;; *resource fork* with an 'osas' FinderInfo type. `osascript' reads that
;; resource-fork script, which is in an obsolete format, and dies with
;; errOSADataFormatObsolete (-1758) — breaking app detection and the C-c C-c
;; paste-back. A plain recompile isn't enough: the stale resource fork lingers
;; and keeps shadowing the data fork. So DELETE each helper first (clearing the
;; resource fork + FinderInfo), then recompile as a clean data-fork .scpt. Run
;; once per session: eagerly on load, and after the package's own compile step.
(after! emacs-everywhere
  ;; BUG in emacs-everywhere: `--ensure-oscascript-compiled' tests
  ;; (file-exists-p "app-name") against the *caller's* default-directory (the
  ;; package dir is only bound inside the body), so the test fails for any
  ;; caller and it RE-COMPILES on every `app-info' call. Bind default-directory
  ;; around it so the test is correct and it skips once the scripts exist.
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled :around
              (lambda (orig &rest args)
                (let ((default-directory emacs-everywhere--dir))
                  (apply orig args))))
  ;; And what it does compile uses `-t osas -r scpt:128', leaving an obsolete
  ;; resource-fork script (errOSADataFormatObsolete / -1758). Recompile clean +
  ;; strip the resource fork/FinderInfo. Once per session (the :around above
  ;; stops the package from re-breaking it afterwards).
  (defvar cust/emacs-everywhere--osascripts-fixed nil)
  (defun cust/emacs-everywhere-recompile-osascripts (&rest _)
    (unless cust/emacs-everywhere--osascripts-fixed
      (dolist (s '("app-name" "window-title" "window-geometry"))
        (let ((src (expand-file-name (concat s ".applescript") emacs-everywhere--dir))
              (out (expand-file-name s emacs-everywhere--dir)))
          (when (file-exists-p src)
            (when (file-exists-p out) (delete-file out))
            (call-process "osacompile" nil nil nil "-o" out src)
            (call-process "xattr" nil nil nil "-c" out))))
      (setq cust/emacs-everywhere--osascripts-fixed t)))
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled
              :after #'cust/emacs-everywhere-recompile-osascripts)
  ;; Fix immediately on load.
  (emacs-everywhere--ensure-oscascript-compiled))

(after! lsp-mode
  (setq lsp-log-io nil
        lsp-idle-delay 1.0
        lsp-lens-enable nil
        lsp-rust-analyzer-lens-enable nil
        lsp-inlay-hint-enable nil
        lsp-enable-symbol-highlighting nil
        lsp-enable-on-type-formatting nil
        lsp-headerline-breadcrumb-enable nil
        lsp-enable-folding nil
        lsp-diagnostics-provider :flycheck      ; keep diagnostics
        lsp-modeline-code-actions-enable nil)   ; stop "quick fix available" probing

  ;; Ignore harmless rust-analyzer "content modified" errors.
  (defun my/lsp-ignore-rust-analyzer-content-modified (orig-fn &rest args)
    (let ((msg (format "%S" args)))
      (unless (string-match-p "content modified" msg)
        (apply orig-fn args))))
  (advice-add 'lsp--error :around #'my/lsp-ignore-rust-analyzer-content-modified))

(after! lsp-ui
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-doc-enable nil))

;; corfu config
(setq corfu-auto-prefix 2
      corfu-auto-delay 0.25)
