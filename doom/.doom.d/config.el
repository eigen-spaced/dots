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

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "Cascadia Code NF" :size 17))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;; (setq doom-theme 'doom-badger)
(setq doom-theme 'doom-carbonfox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

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

(after! evil
  (setq evil-escape-key-sequence "jk")
  (evil-escape-mode))

;;; ---------------------------------------------
;;; //                   Misc                  //
;;; ---------------------------------------------

(after! lsp-mode
  (setq lsp-log-io nil))

(after! rustic
  (setq rustic-lsp-client 'lsp-mode))

(after! lsp-mode
  (defun my/lsp-ignore-rust-analyzer-content-modified (orig-fn &rest args)
    "Ignore harmless rust-analyzer stale document errors."
    (let ((msg (format "%S" args)))
      (unless (string-match-p "content modified" msg)
        (apply orig-fn args))))

  (advice-add 'lsp--error :around #'my/lsp-ignore-rust-analyzer-content-modified))

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
  ;; Declutter smudge's list buffers by dropping the mode-line. The column header
  ;; line stays, and now-playing still shows in other buffers' mode-lines.
  (dolist (hook '(smudge-playlist-search-mode-hook smudge-track-search-mode-hook))
    (add-hook hook (lambda () (setq-local mode-line-format nil))))
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
  ;; Feb-2026 Spotify Web API compatibility shims (smudge is unmaintained).
  ;; Kept in a separate file so it's easy to migrate into a fork later.
  (load! "smudge-2026")
  (global-smudge-remote-mode 1))

;; SPC o M -> Spotify (SPC o m is already `=mu4e', the mail launcher). smudge is
;; autoloaded, so these pull it in on first use.
(map! :leader
      (:prefix ("o M" . "music")
       :desc "Track search"     "s"   #'smudge-track-search
       :desc "Playlist search"  "p"   #'smudge-playlist-search
       :desc "My playlists"     "m"   #'smudge-my-playlists
       :desc "Play/pause"       "SPC" #'smudge-controller-toggle-play
       :desc "Next track"       "n"   #'smudge-controller-next-track
       :desc "Previous track"   "N"   #'smudge-controller-previous-track))

;;; ---------------------------------------------
;;; //          emacs-everywhere (macOS)        //
;;; ---------------------------------------------
;; emacs-everywhere compiles its osascript helpers with
;; `osacompile -t osas -r scpt:128', which on current macOS stuffs the compiled
;; script into the file's *resource fork* and leaves the data fork EMPTY.
;; `osascript <file>' reads the data fork, so it runs an empty script and dies
;; with "script error -1758" — which breaks app detection and therefore the
;; C-c C-c paste-back. Self-heal: after the package's own compile step,
;; recompile (plain, data-fork) any helper whose data fork is empty. Idempotent,
;; and re-fixes itself if the package is ever rebuilt.
(after! emacs-everywhere
  (defun cust/emacs-everywhere-fix-osascripts (&rest _)
    (dolist (s '("app-name" "window-title" "window-geometry"))
      (let ((src (expand-file-name (concat s ".applescript") emacs-everywhere--dir))
            (out (expand-file-name s emacs-everywhere--dir)))
        (when (and (file-exists-p src)
                   (zerop (or (file-attribute-size (file-attributes out)) 0)))
          (call-process "osacompile" nil nil nil "-o" out src)))))
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled
              :after #'cust/emacs-everywhere-fix-osascripts))

(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-lens-enable nil
        lsp-rust-analyzer-lens-enable nil
        lsp-inlay-hint-enable nil
        lsp-enable-symbol-highlighting nil
        lsp-enable-on-type-formatting nil
        lsp-headerline-breadcrumb-enable nil
        lsp-enable-folding nil

        ;; Keep diagnostics.
        lsp-diagnostics-provider :flycheck

        ;; Stop automatic “quick fix available” probing.
        lsp-modeline-code-actions-enable nil))

(after! lsp-ui
  (setq lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-doc-enable nil))

;; corfu config
(setq corfu-auto-prefix 2
      corfu-auto-delay 0.25)
