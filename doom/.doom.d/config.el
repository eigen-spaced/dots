;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Open new frames maximized (use '(fullscreen . fullboth) for native fullscreen).
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Launcher frames made via `emacsclient -e (make-frame)' skip Doom's theme/font
;; init hook and come up unthemed — re-run it on the first such frame.
(when (daemonp)
  (dolist (fn '(doom-init-theme-h doom-init-fonts-h))
    (when (fboundp fn)
      (add-hook 'after-make-frame-functions fn))))

(setq doom-font (font-spec :family "Cascadia Code NF" :size 17))
;; fixed-pitch-serif is unused by default; prose serif comes from the
;; `variable-pitch' remap below. (Static family name is "Merriweather 24pt".)
(setq doom-serif-font (font-spec :family "Merriweather 24pt"))
(setq doom-theme 'doom-moonlight)

;; Merriweather (serif) for reading prose, in eww + org only.
(defun cust/reading-serif ()
  "Remap the current buffer's `variable-pitch' face to Merriweather."
  (face-remap-add-relative 'variable-pitch :family "Merriweather 24pt"))

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

;; Centered reading column in eww, off by default; toggle with `SPC m c'.
(after! olivetti (setq olivetti-body-width 80))
(map! :after eww :map eww-mode-map :localleader
      :desc "Toggle centered column" "c" #'olivetti-mode)

(setq display-line-numbers-type t)

;; Auto-compile missing tree-sitter grammars on first file open (no prompt).
(setq treesit-auto-install-grammar 'always)

;; LSP semantic tokens: type-aware highlighting (members, enums, namespaces) over
;; tree-sitter; the theme colors the `lsp-face-semhl-*' faces.
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t)

  ;; Python LSP: pyrefly (`uv tool install pyrefly'); lsp-mode has no built-in
  ;; client. Disable the other type checkers so pyrefly is sole; ruff stays for
  ;; lint/format. (pyrefly has no semantic tokens, so Python is tree-sitter-only.)
  (dolist (client '(pyright pyls mspyls ty-ls))
    (add-to-list 'lsp-disabled-clients client))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("pyrefly" "lsp"))
    :activation-fn (lsp-activate-on "python")
    :priority 2
    :server-id 'pyrefly)))

;; `org-directory' must be set before org loads.
(setq org-directory "~/org/")

;; GTD-lite org setup: agenda, capture, refile, reading list, roam, clocking.
(load! "org-config")

;;; ---------------------------------------------
;;; //              Keybindings                //
;;; ---------------------------------------------
;; Window navigation (evil normal state).
(map! :n
      "C-h" #'evil-window-left
      "C-l" #'evil-window-right
      "C-k" #'evil-window-up
      "C-j" #'evil-window-down)

(after! evil
  (setq evil-escape-key-sequence "jk")
  (map! :n "C-b" #'consult-buffer
        :n "C-p" #'projectile-find-file))

;;; fzf-lua-style splits: with a candidate highlighted in any vertico finder,
;;; C-v opens it in a vsplit and C-s an hsplit (via embark).
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

;;; Quick access: org folder + dirvish (also fired by Hammerspoon hotkeys).
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

;; Stow-symlinked config: Doom's SPC f p skips symlinks, so reimplement it
;; symlink-aware.
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

;; Machine-local, git-ignored name/email (see private.el.example). 3rd arg = noerror.
(load! "private" nil t)

;; Read secrets (Gmail app password, Spotify creds) from the macOS Keychain.
(after! auth-source
  (add-to-list 'auth-sources 'macos-keychain-internet))

;;; ---------------------------------------------
;;; //               Email (mu4e)              //
;;; ---------------------------------------------
;; mbsync (isync) syncs Gmail into ~/.mail; mu indexes it. Secrets via Keychain
;; (auth-source for SMTP, PassCmd in ~/.mbsyncrc for IMAP); identity in private.el.
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
;; Search/playlists via the Spotify Web API (creds in Keychain); play/pause/next
;; via the local macOS app over AppleScript (no Premium). Same transport is also
;; bound to global ⌘⌥ hotkeys in ~/.hammerspoon.
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
  ;; smudge's first Web-API call busy-waits (blocking Emacs) for browser OAuth and
  ;; hides its own message — surface a clear one so it's not mistaken for a hang.
  (advice-add 'smudge-api-oauth2-auth :before
              (lambda (&rest _)
                (message "Smudge: a browser is opening — authorize Spotify there; Emacs resumes once you do.")))
  ;; smudge polls status every 5s but never forces a mode-line repaint, so the
  ;; indicator looks stale after a direct play/pause — force it.
  (advice-add 'smudge-controller-update-player-status :after
              (lambda (&rest _) (force-mode-line-update t)))
  ;; smudge's list keys (l = load more, g = reload) live in its mode-maps, but in
  ;; Doom these buffers open in evil normal state, which shadows them — re-bind.
  (evil-define-key 'normal smudge-playlist-search-mode-map
    "l" #'smudge-playlist-load-more
    "g" #'smudge-playlist-reload)
  (evil-define-key 'normal smudge-track-search-mode-map
    "l" #'smudge-track-load-more
    "g" #'smudge-track-reload
    (kbd "RET") #'smudge-track-select) ; play track-at-point (smudge only binds M-RET)
  ;; `l' reprints the whole list and dumps point at the top; save/restore the line.
  (defun cust/smudge-preserve-point (orig &rest args)
    "Keep point on the same line when smudge reprints a list buffer."
    (let ((line (line-number-at-pos)))
      (apply orig args)
      (goto-char (point-min))
      (forward-line (1- line))))
  (advice-add 'smudge-track-search-print    :around #'cust/smudge-preserve-point)
  (advice-add 'smudge-playlist-search-print :around #'cust/smudge-preserve-point)
  (global-smudge-remote-mode 1))

;; Wake smudge without opening UI: its transport commands aren't autoloaded, so
;; they stay dead until the package loads. This loads it (runs the :config above).
(defun cust/smudge-connect ()
  "Load + initialize smudge so transport (play/pause/next/prev) works.
No UI, and no OAuth needed for the AppleScript transport."
  (interactive)
  (require 'smudge)
  ;; :config only runs on first load, so re-connecting after a disconnect needs this.
  (global-smudge-remote-mode 1)
  (ignore-errors (smudge-controller-player-status))
  (message "Smudge ready — transport active."))

;; Hide smudge's modeline info + stop the status poll; transport keeps working.
(defun cust/smudge-disconnect ()
  "Turn off smudge's modeline player info + status polling."
  (interactive)
  (when (bound-and-true-p global-smudge-remote-mode)
    (global-smudge-remote-mode -1))
  (message "Smudge: player info hidden."))

;; SPC o M -> Spotify (SPC o m is mu4e).
(map! :leader
      (:prefix ("o M" . "music")
       :desc "Connect / wake"       "c"   #'cust/smudge-connect
       :desc "Disconnect / hide"    "C"   #'cust/smudge-disconnect
       :desc "Track search"         "s"   #'smudge-track-search
       :desc "Playlist search"      "p"   #'smudge-playlist-search
       :desc "My playlists"         "m"   #'smudge-my-playlists
       :desc "Add playing→playlist" "a"   #'smudge-add-playing-track-to-playlist
       :desc "Play/pause"           "SPC" #'smudge-controller-toggle-play
       :desc "Next track"           "n"   #'smudge-controller-next-track
       :desc "Previous track"       "N"   #'smudge-controller-previous-track))

;;; ---------------------------------------------
;;; //          emacs-everywhere (macOS)        //
;;; ---------------------------------------------
;; emacs-everywhere compiles its osascript helpers into the resource fork in an
;; obsolete format, so osascript dies with errOSADataFormatObsolete (-1758).
;; Delete each helper first (clears the resource fork), then recompile clean.
(after! emacs-everywhere
  ;; BUG: `--ensure-oscascript-compiled' checks file-exists against the caller's
  ;; default-directory, so it recompiles on every call — bind default-directory.
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled :around
              (lambda (orig &rest args)
                (let ((default-directory emacs-everywhere--dir))
                  (apply orig args))))
  ;; Recompile clean + strip the resource fork/FinderInfo, once per session.
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
