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
;; Prose serif actually comes from the `variable-pitch' remap below; set anyway.
(setq doom-serif-font (font-spec :family "Merriweather 24pt"))
(setq doom-theme 'doom-moonlight)

;; Merriweather (serif) for reading prose, in eww + org + mu4e.
(defun my/reading-serif ()
  "Remap the current buffer's `variable-pitch' face to Merriweather."
  (face-remap-add-relative 'variable-pitch :family "Merriweather 24pt"))

(add-hook 'eww-mode-hook #'my/reading-serif)

;; org: serif prose, but keep code blocks / tables / metadata monospace.
(defvar my/org-keep-mono-faces
  '(org-block org-block-begin-line org-block-end-line org-code org-verbatim
    org-table org-formula org-meta-line org-document-info-keyword
    org-special-keyword org-property-value org-drawer
    font-lock-comment-face font-lock-comment-delimiter-face
    line-number line-number-current-line)
  "Org faces pinned to `fixed-pitch' (monospace) under `my/org-prose-serif'.")

(defun my/org-prose-serif ()
  "Render org prose in Merriweather (serif); keep code/tables/metadata mono."
  (my/reading-serif)
  (dolist (f my/org-keep-mono-faces)
    (face-remap-add-relative f 'fixed-pitch))
  (variable-pitch-mode 1))

(add-hook 'org-mode-hook #'my/org-prose-serif)

;; mu4e message view: serif body, like eww/org. (Headers list stays mono so its
;; columns keep aligning.)
(defun my/mu4e-prose-serif ()
  "Render the mu4e message view in Merriweather (serif)."
  (my/reading-serif)
  (variable-pitch-mode 1))

(add-hook 'mu4e-view-mode-hook #'my/mu4e-prose-serif)

;; shr bakes hard line breaks at a fixed char width, so when olivetti narrows the
;; body those lines wrap again into ragged half-lines. Turn filling off + soft-wrap
;; instead, so paragraphs reflow to the shown width. Buffer-local so mail (also
;; shr, via mm-shr) keeps its own wrapping.
(defun my/eww-reflow ()
  "Soft-wrap eww paragraphs to the window/olivetti width (no baked-in breaks)."
  (setq-local shr-fill-text nil)
  (visual-line-mode 1))
(add-hook 'eww-mode-hook #'my/eww-reflow)

;; eww is a reading buffer, not a transient popup: pin it to a persistent
;; right-side pane so it joins the normal window tree (movable/splittable).
(set-popup-rule! "^\\*eww\\*" :side 'right :size 0.5 :select t :quit nil :ttl nil)

;; Syntax-highlight <pre> code blocks in eww/shr via font-lock, so they pick up
;; the current Doom theme (matches code buffers). Language comes from the HTML
;; class; `language-detection' guesses when there's no hint.
(use-package! shr-tag-pre-highlight
  :after shr
  :config
  (add-to-list 'shr-external-rendering-functions
               '(pre . shr-tag-pre-highlight)))

;; Centered reading column in eww, off by default; toggle with `SPC m c'.
(after! olivetti (setq olivetti-body-width 80))
(map! :after eww :map eww-mode-map :localleader
      :desc "Toggle centered column" "c" #'olivetti-mode)

(setq display-line-numbers-type 'relative)

;; Auto-compile missing tree-sitter grammars on first file open (no prompt).
(setq treesit-auto-install-grammar 'always)

;; "Focus follows width": grow the selected window to `my/focus-width' (so 80-col
;; code never wraps), shrinking the rest. Toggle with `M-x my/focus-width-mode'.
(defcustom my/focus-width 120
  "Target total width (columns) for the focused window."
  :type 'integer :group 'convenience)

(defun my/focus-width--apply (&rest _)
  "Widen the selected window toward `my/focus-width' when the mode is on."
  (when (and (bound-and-true-p my/focus-width-mode)
             (not (window-minibuffer-p (selected-window)))
             (> (count-windows) 1))
    (let ((delta (- my/focus-width (window-total-width (selected-window)))))
      (when (> delta 0)
        (ignore-errors (window-resize (selected-window) delta t)))))) ; t = horizontal

(define-minor-mode my/focus-width-mode
  "Keep the focused window at least `my/focus-width' columns wide."
  :global t
  (if my/focus-width-mode
      (progn
        (add-hook 'window-selection-change-functions #'my/focus-width--apply)
        (my/focus-width--apply))
    (remove-hook 'window-selection-change-functions #'my/focus-width--apply)
    (balance-windows)))

;; tmux-style fraction-snap window resize (twin of nvim's `snap_resize'): an arrow
;; drags the shared border its way, snapping the window through `my/snap-stops'.
;; A far-edge window moves its *inner* border, so grow/shrink flips for it.
(defconst my/snap-stops '(25 33 50 67 75)
  "Fraction stops (percent of frame) the snap resizer steps through.")

(defun my/snap--next-stop (pct grow)
  "Return the next stop past PCT, upward when GROW else downward."
  (if grow
      (or (seq-find (lambda (s) (> s (+ pct 2))) my/snap-stops)
          (car (last my/snap-stops)))
    (or (seq-find (lambda (s) (< s (- pct 2))) (reverse my/snap-stops))
        (car my/snap-stops))))

(defun my/snap-resize (axis toward-far)
  "Snap-resize the selected window along AXIS (`x' or `y').
TOWARD-FAR means the arrow points right/down. The shared border follows the
arrow; see `my/snap-stops'."
  (let* ((win (selected-window))
         (horizontal (eq axis 'x))
         (at-far (window-at-side-p win (if horizontal 'right 'bottom)))
         (at-near (window-at-side-p win (if horizontal 'left 'top))))
    (unless (and at-far at-near) ; only window on this axis: nothing to push against
      (let* ((total (if horizontal (frame-width) (1- (frame-height)))) ; -1 echo area
             (cur (if horizontal
                      (window-total-width win)
                    (window-total-height win)))
             (grow (if at-far (not toward-far) toward-far)) ; far edge moves its inner border
             (pct (/ (* cur 100) total))
             (target (/ (* total (my/snap--next-stop pct grow)) 100)))
        (ignore-errors (window-resize win (- target cur) horizontal))))))

(map! :leader
      :desc "Snap split border right" "w >" (cmd! (my/snap-resize 'x t))
      :desc "Snap split border left"  "w <" (cmd! (my/snap-resize 'x nil))
      :desc "Snap split border down"  "w +" (cmd! (my/snap-resize 'y t))
      :desc "Snap split border up"    "w -" (cmd! (my/snap-resize 'y nil)))

;; Name the leader prefixes for which-key (a bodyless `:prefix' sets the label
;; without touching the bindings underneath; they otherwise show "+prefix").
(map! :leader
      (:prefix ("b" . "buffer"))
      (:prefix ("c" . "code"))
      (:prefix ("f" . "file"))
      (:prefix ("g" . "git"))
      (:prefix ("h" . "help"))
      (:prefix ("i" . "insert"))
      (:prefix ("m" . "mode (local)"))
      (:prefix ("n" . "notes/org"))
      (:prefix ("o" . "open"))
      (:prefix ("p" . "project"))
      (:prefix ("q" . "quit/session"))
      (:prefix ("s" . "search"))
      (:prefix ("t" . "toggle")))

;; LSP semantic tokens: type-aware highlighting (members, enums, namespaces) over
;; tree-sitter; the theme colors the `lsp-face-semhl-*' faces.
(after! lsp-mode
  (setq lsp-semantic-tokens-enable t)

  ;; Python LSP: pyrefly (`uv tool install pyrefly') — no built-in lsp-mode client.
  ;; Disable other checkers so it's sole; it has no semantic tokens, so Python
  ;; highlighting stays tree-sitter-only.
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
  (map! :n "C-p" #'projectile-find-file))

;;; fzf-lua-style splits: with a candidate highlighted in any vertico finder,
;;; C-v opens it in a vsplit and C-s an hsplit (via embark).
(after! embark
  (defun my/embark-find-file-vsplit (file)
    "Open FILE in a vertical split (embark action)."
    (interactive "FFile: ")
    (select-window (split-window-right))
    (find-file file))
  (defun my/embark-find-file-hsplit (file)
    "Open FILE in a horizontal split (embark action)."
    (interactive "FFile: ")
    (select-window (split-window-below))
    (find-file file))
  (defun my/embark-buffer-vsplit (buffer)
    "Display BUFFER in a vertical split (embark action)."
    (interactive "bBuffer: ")
    (select-window (split-window-right))
    (switch-to-buffer buffer))
  (defun my/embark-buffer-hsplit (buffer)
    "Display BUFFER in a horizontal split (embark action)."
    (interactive "bBuffer: ")
    (select-window (split-window-below))
    (switch-to-buffer buffer))
  (define-key embark-file-map   (kbd "C-v") #'my/embark-find-file-vsplit)
  (define-key embark-file-map   (kbd "C-s") #'my/embark-find-file-hsplit)
  (define-key embark-buffer-map (kbd "C-v") #'my/embark-buffer-vsplit)
  (define-key embark-buffer-map (kbd "C-s") #'my/embark-buffer-hsplit))

(defun my/embark-act-key (keystr)
  "Run `embark-act' on the current target, auto-choosing the action bound to
KEYSTR in that target's action map (no action prompt appears). Used to make a
single minibuffer keypress act on the highlighted candidate."
  (require 'embark)
  (let ((embark-prompter
         (lambda (keymap &optional _update) (lookup-key keymap (kbd keystr)))))
    (embark-act)))

(after! vertico
  (define-key vertico-map (kbd "C-v")
              (lambda () (interactive) (my/embark-act-key "C-v")))
  (define-key vertico-map (kbd "C-s")
              (lambda () (interactive) (my/embark-act-key "C-s"))))

;;; Quick access: org folder + dirvish (also fired by Hammerspoon hotkeys).
(defun my/dirvish-org ()
  "Open the org directory (`org-directory') in Dirvish."
  (interactive)
  (dirvish org-directory))

(defun my/popup-frame (command)
  "Create a focused macOS GUI frame and run COMMAND (a symbol) in it.
Entry point for the global Hammerspoon hotkeys: the daemon has no frame of
its own, so we make one, pull it to the foreground, then invoke COMMAND."
  (select-frame-set-input-focus (make-frame '((window-system . ns))))
  (call-interactively command))

(defun my/center-frame (frame)
  "Center FRAME on its monitor's workarea (never overflows the edges)."
  (let* ((wa (frame-monitor-workarea frame))
         (mx (nth 0 wa)) (my (nth 1 wa)) (mw (nth 2 wa)) (mh (nth 3 wa)))
    (set-frame-position frame
                        (+ mx (/ (- mw (frame-pixel-width frame)) 2))
                        (+ my (/ (- mh (frame-pixel-height frame)) 2)))))

(map! :leader
      :desc "Dirvish (here)"        "o d" #'dirvish
      :desc "Org folder (Dirvish)"  "o n" #'my/dirvish-org)

;; `SPC m w' in dired toggles wdired (editable filenames; `:%s'/visual-block to
;; bulk-rename, `C-c C-c' to apply). Same as the built-in `C-x C-q'.
(map! :after dired :map dired-mode-map :localleader
      :desc "Edit filenames (wdired)" "w" #'dired-toggle-read-only)

;; Dirvish opens full-frame with the preview as a side window, which can't be
;; split — so `SPC w v' is a no-op there. C-v/C-s (matching the vertico finder)
;; grab the file at point, drop the dirvish layout, and open it beside the buffer
;; dirvish was launched from. Bound as plain key chords so they survive a switch
;; off evil (meow/vanilla); the `:n' lines just let them win over evil's own
;; C-v/C-s while evil is in charge.
(defun my/dired-open-in-split (side)
  "Open the file at point in a SIDE (`right'/`below') split.
In a full-frame dirvish session, quit it first so the file lands next to the
buffer dirvish was launched from."
  (let ((file (dired-get-file-for-visit)))
    (when (and (fboundp 'dirvish-curr) (dirvish-curr))
      (dirvish-quit))
    (select-window (if (eq side 'right) (split-window-right) (split-window-below)))
    (find-file file)))

(map! :after dired :map (dired-mode-map dirvish-mode-map)
      "C-v"    (cmd! (my/dired-open-in-split 'right))
      "C-s"    (cmd! (my/dired-open-in-split 'below))
      :n "C-v" (cmd! (my/dired-open-in-split 'right))
      :n "C-s" (cmd! (my/dired-open-in-split 'below)))

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
        ;; mbsync needs this: rename on move so it doesn't see a UID clash and
        ;; spawn duplicates (else trashed mail leaves stale, unreaped All Mail copies).
        mu4e-change-filenames-when-moving t
        message-send-mail-function #'smtpmail-send-it
        ;; Gmail saves its own copy of sent mail; don't let mu4e double it up.
        mu4e-sent-messages-behavior 'delete
        ;; Flip to plain text with RET on the gnus part button (colour fix below).
        mm-text-html-renderer 'shr)

  ;; Gmail keeps an All Mail copy of "deleted" mail, and `flag:trashed' is unused
  ;; here (mbsync trashes by moving), so exclude the Trash/Spam *maildirs*. The
  ;; Inbox bookmark is maildir-scoped, so deletes from it are one-shot.
  (setq mu4e-bookmarks
        '((:name "Inbox"
           :query "maildir:/gmail/INBOX"
           :key ?i)
          (:name "Unread messages"
           :query "flag:unread AND NOT maildir:/gmail/[Gmail]/Trash AND NOT maildir:/gmail/[Gmail]/Spam"
           :key ?u)
          (:name "Today's messages"
           :query "date:today..now AND NOT maildir:/gmail/[Gmail]/Trash AND NOT maildir:/gmail/[Gmail]/Spam"
           :key ?t)
          (:name "Last 7 days"
           :query "date:7d..now AND NOT maildir:/gmail/[Gmail]/Trash AND NOT maildir:/gmail/[Gmail]/Spam"
           :key ?w)
          (:name "Flagged"
           :query "flag:flagged AND NOT maildir:/gmail/[Gmail]/Trash"
           :key ?f)
          (:name "Messages with images"
           :query "mime:image/*"
           :key ?p)))

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

;; shr honours the message's own colours — marketing emails set white backgrounds
;; that become ugly boxes on a dark theme. Drop colours for mail only (via
;; `mm-shr'), leaving eww's page colours and the serif body untouched.
(defun my/mu4e-shr-no-colors (orig &rest args)
  "Render HTML mail without the message's own colours (use theme faces)."
  (let ((shr-use-colors nil))
    (apply orig args)))
(advice-add 'mm-shr :around #'my/mu4e-shr-no-colors)

;;; ---------------------------------------------
;;; //             Spotify (splotch)            //
;;; ---------------------------------------------
;; Search/playlists via the Spotify Web API (creds in Keychain); play/pause/next
;; via the local macOS app over AppleScript (no Premium). Same transport is also
;; bound to global ⌘⌥ hotkeys in ~/.hammerspoon.
(use-package! splotch
  :defer t
  :init
  (setq splotch-transport 'apple
        splotch-status-location 'modeline)
  :config
  ;; NB: Keychain host stays "smudge" (the package was renamed splotch, but the
  ;; stored creds are keyed under "smudge" — kept to avoid re-storing secrets).
  (let ((id  (auth-source-pick-first-password :host "smudge" :user "client-id"))
        (sec (auth-source-pick-first-password :host "smudge" :user "client-secret")))
    (when id  (setq splotch-oauth2-client-id id))
    (when sec (setq splotch-oauth2-client-secret sec)))
  ;; splotch's first Web-API call busy-waits (blocking Emacs) for browser OAuth and
  ;; hides its own message — surface a clear one so it's not mistaken for a hang.
  (advice-add 'splotch-api-oauth2-auth :before
              (lambda (&rest _)
                (message "Splotch: a browser is opening — authorize Spotify there; Emacs resumes once you do.")))
  ;; splotch polls status every 5s but never forces a mode-line repaint, so the
  ;; indicator looks stale after a direct play/pause — force it.
  (advice-add 'splotch-controller-update-player-status :after
              (lambda (&rest _) (force-mode-line-update t)))
  ;; splotch's list keys (l = load more, g = reload) live in its mode-maps, but in
  ;; Doom these buffers open in evil normal state, which shadows them — re-bind.
  (evil-define-key 'normal splotch-playlist-search-mode-map
    "l" #'splotch-playlist-load-more
    "g" #'splotch-playlist-reload)
  (evil-define-key 'normal splotch-track-search-mode-map
    "l" #'splotch-track-load-more
    "g" #'splotch-track-reload
    (kbd "RET") #'splotch-track-select) ; play track-at-point (splotch only binds M-RET)
  ;; `l' reprints the whole list and dumps point at the top; save/restore the line.
  (defun my/splotch-preserve-point (orig &rest args)
    "Keep point on the same line when splotch reprints a list buffer."
    (let ((line (line-number-at-pos)))
      (apply orig args)
      (goto-char (point-min))
      (forward-line (1- line))))
  (advice-add 'splotch-track-search-print    :around #'my/splotch-preserve-point)
  (advice-add 'splotch-playlist-search-print :around #'my/splotch-preserve-point)
  (global-splotch-remote-mode 1))

;; Wake splotch without opening UI: its transport commands aren't autoloaded, so
;; they stay dead until the package loads. This loads it (runs the :config above).
(defun my/splotch-connect ()
  "Load + initialize splotch so transport (play/pause/next/prev) works.
No UI, and no OAuth needed for the AppleScript transport."
  (interactive)
  (require 'splotch)
  ;; :config only runs on first load, so re-connecting after a disconnect needs this.
  (global-splotch-remote-mode 1)
  (ignore-errors (splotch-controller-player-status))
  (message "Splotch ready — transport active."))

;; Hide splotch's modeline info + stop the status poll; transport keeps working.
(defun my/splotch-disconnect ()
  "Turn off splotch's modeline player info + status polling."
  (interactive)
  (when (bound-and-true-p global-splotch-remote-mode)
    (global-splotch-remote-mode -1))
  (message "Splotch: player info hidden."))

;; SPC o M -> Spotify (SPC o m is mu4e).
(map! :leader
      (:prefix ("o M" . "music")
       :desc "Connect / wake"       "c"   #'my/splotch-connect
       :desc "Disconnect / hide"    "C"   #'my/splotch-disconnect
       :desc "Track search"         "s"   #'splotch-track-search
       :desc "Playlist search"      "p"   #'splotch-playlist-search
       :desc "Open playlist"        "m"   #'splotch-open-playlist
       :desc "Add playing→playlist" "a"   #'splotch-add-playing-track-to-playlist
       :desc "Play/pause"           "SPC" #'splotch-controller-toggle-play
       :desc "Next track"           "n"   #'splotch-controller-next-track
       :desc "Previous track"       "N"   #'splotch-controller-previous-track))

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
  (defvar my/emacs-everywhere--osascripts-fixed nil)
  (defun my/emacs-everywhere-recompile-osascripts (&rest _)
    (unless my/emacs-everywhere--osascripts-fixed
      (dolist (s '("app-name" "window-title" "window-geometry"))
        (let ((src (expand-file-name (concat s ".applescript") emacs-everywhere--dir))
              (out (expand-file-name s emacs-everywhere--dir)))
          (when (file-exists-p src)
            (when (file-exists-p out) (delete-file out))
            (call-process "osacompile" nil nil nil "-o" out src)
            (call-process "xattr" nil nil nil "-c" out))))
      (setq my/emacs-everywhere--osascripts-fixed t)))
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled
              :after #'my/emacs-everywhere-recompile-osascripts)
  (emacs-everywhere--ensure-oscascript-compiled)

  ;; Open empty + centered: drop `insert-selection' (its ⌘C/yank fallback leaked a
  ;; stray `c' + stale clipboard) and replace mouse-positioning with centering.
  (defun my/emacs-everywhere-center-frame ()
    (my/center-frame (selected-frame)))
  (setq emacs-everywhere-init-hooks
        (mapcar (lambda (h) (if (eq h 'emacs-everywhere-set-frame-position)
                                #'my/emacs-everywhere-center-frame h))
                (remq 'emacs-everywhere-insert-selection
                      emacs-everywhere-init-hooks)))

  ;; With insert-selection gone the temp .org is empty, so file-templates drops a
  ;; `#+title' into it (on `doom-switch-buffer-hook'). Make file-templates skip
  ;; emacs-everywhere files outright — order-independent, unlike erasing after.
  (defun my/file-templates-skip-everywhere (orig &rest args)
    (unless (and buffer-file-name
                 (fboundp 'emacs-everywhere-file-p)
                 (emacs-everywhere-file-p buffer-file-name))
      (apply orig args)))
  (advice-add '+file-templates-check-h :around #'my/file-templates-skip-everywhere))

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

(setq corfu-auto-prefix 2
      corfu-auto-delay 0.25)

;;; ---------------------------------------------
;;; //          Document reader (reader)        //
;;; ---------------------------------------------
;; MuPDF-backed reader for PDF/EPUB/CBZ/MOBI/…; reader-mode is auto-registered
;; for those extensions (needs `brew install mupdf'). `SPC o D' opens any doc.
(map! :leader :desc "Open document (reader)" "o D" #'reader-open-doc)

;; EWW SVG zoom: rasterise SVGs to a PNG and open them in a zoomable image
;; buffer (i+/i- in EWW), since SVGs can't be scaled reliably inline.
(load! "eww-svg-zoom")

;;; ---------------------------------------------
;;; //           Ghostel terminal             //
;;; ---------------------------------------------
;; libghostty-vt-backed terminal (the Ghostty VT engine, in Emacs); our default
;; terminal now that vterm is disabled (`:term vterm' off). Evil support comes
;; from the bundled `evil-ghostel' (enabled below). Native module auto-downloads
;; on first `M-x ghostel' (`ghostel-module-auto-install' defaults to `ask').

;; vterm-style toggle popup: a persistent 25% bottom pane. The rule routes every
;; ghostel buffer there (all are named "*ghostel..."); `my/ghostel-here' is the
;; in-window escape hatch. Mirrors the old `^\\*vterm' popup the module shipped.
(set-popup-rule! "^\\*ghostel" :size 0.25 :vslot -4 :select t :quit nil :ttl nil)

(defun my/ghostel--in-project (&optional same-window)
  "Open or switch to ghostel rooted at the current project (else `default-directory').
A freshly created terminal starts in the project root; an existing one is
reused as-is (navigate with the shell's own cd/~). With SAME-WINDOW, bypass
the popup rule and open in the current window."
  (let ((default-directory (or (doom-project-root) default-directory)))
    (if same-window
        (let ((display-buffer-alist nil)) (ghostel))
      (ghostel))))

(defun my/ghostel-toggle ()
  "Toggle the ghostel popup, vterm-style: hide it if shown, else open it.
A newly created terminal starts in the current project root."
  (interactive)
  (if-let* ((win (seq-find (lambda (w)
                             (string-prefix-p "*ghostel" (buffer-name (window-buffer w))))
                           (window-list))))
      (delete-window win)
    (my/ghostel--in-project)))

(defun my/ghostel-here ()
  "Open ghostel in the current window (project root), bypassing the popup rule."
  (interactive)
  (my/ghostel--in-project t))

(use-package! ghostel
  :defer t
  :init
  (map! :leader
        :desc "Toggle ghostel popup"      "o t" #'my/ghostel-toggle
        :desc "Ghostel in current window" "o T" #'my/ghostel-here)
  :bind (:map ghostel-semi-char-mode-map
         ("C-s" . consult-line)
         ("M-<backspace>" . ghostel-backward-kill-word)
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl"))))
  :config
  ;; Full redraws are robust against aggressive partial screen updates (zsh
  ;; line-discard on C-u, TUIs); fixes the prompt briefly vanishing until the
  ;; next keystroke, at a little extra CPU.
  (setq ghostel-full-redraw t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

;; Evil integration: its own MELPA package (modeled on evil-collection-vterm).
;; Per-buffer minor mode — starts in insert state, ESC snaps to normal.
(use-package! evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

;; Optional global integrations — flip on once ghostel earns its keep. These
;; reroute eshell visual commands, `compile', and comint buffers through it.
;; (use-package! ghostel-eshell  :hook (eshell-load . ghostel-eshell-visual-command-mode))
;; (use-package! ghostel-compile :hook (after-init . ghostel-compile-global-mode))
;; (use-package! ghostel-comint  :hook (after-init . ghostel-comint-global-mode))
