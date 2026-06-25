;;; base-rcp.el --- editor defaults, which-key, window, winner -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; GUI/daemon Emacs on macOS doesn't inherit the shell PATH; import it so gls,
;; rg, fd, language servers and mise shims are found.
(use-package exec-path-from-shell
  :config
  (when (or (daemonp) (memq window-system '(mac ns x)))
    (exec-path-from-shell-initialize)))

;; Defer GC to idle time so it never fires mid-scroll/typing (the consistent
;; input lag a fixed threshold causes).  This is Doom's gcmh setup.
(use-package gcmh
  :init (gcmh-mode 1)
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 64 1024 1024)))

(defun my/split-right-follow ()
  "Split side-by-side and select the new window."
  (interactive) (select-window (split-window-right)))

(defun my/split-below-follow ()
  "Split stacked and select the new window."
  (interactive) (select-window (split-window-below)))

;; Persistence/global modes that needn't be live during (daemon) boot.  Enabled
;; once, on the first command: `pre-command-hook' fires *before* that command, so
;; opening a file as your first action still gets `save-place' restore.
;; (`recentf' is NOT here -- it stays eager to feed the startup dashboard.)
(defun my/enable-deferred-modes ()
  (remove-hook 'pre-command-hook #'my/enable-deferred-modes)
  (savehist-mode 1)
  (save-place-mode 1)
  (global-auto-revert-mode 1))

(use-package emacs
  :ensure nil
  :custom
  (indent-tabs-mode nil)
  (tab-width 2)
  (standard-indent 2)
  (fill-column 80)
  (ring-bell-function #'ignore)
  (use-short-answers t)
  (create-lockfiles nil)
  (find-file-visit-truename t)           ; resolve symlinks (dotfiles) so projectile/magit see the real repo
  (sentence-end-double-space nil)
  (require-final-newline t)
  (scroll-conservatively 101)
  (scroll-margin 3)
  (mouse-wheel-progressive-speed nil)
  (inhibit-compacting-font-caches t)
  (bidi-inhibit-bpa t)
  (fast-but-imprecise-scrolling t)
  (redisplay-skip-fontification-on-input t)
  (vc-handled-backends '(Git))
  (display-line-numbers-type 'relative)
  (global-auto-revert-non-file-buffers t)
  (uniquify-buffer-name-style 'forward)
  (custom-file (expand-file-name "custom.el" user-emacs-directory))
  (backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory))))
  (backup-by-copying t)
  (version-control t)
  (delete-old-versions t)
  (auto-save-file-name-transforms
   `((".*" ,(expand-file-name "autosave/" user-emacs-directory) t)))
  :init
  ;; Emacs won't create these itself — without them backups/auto-save error out.
  (make-directory (expand-file-name "backups"   user-emacs-directory) t)
  (make-directory (expand-file-name "autosave/" user-emacs-directory) t)
  (column-number-mode 1)
  (delete-selection-mode 1)
  (electric-pair-mode 1)
  (show-paren-mode 1)
  (global-hl-line-mode 1)
  (dolist (h '(prog-mode-hook conf-mode-hook text-mode-hook))
    (add-hook h #'display-line-numbers-mode))
  (setq-default bidi-paragraph-direction 'left-to-right)
  (global-so-long-mode 1)
  (recentf-mode 1)                       ; eager: feeds the startup dashboard's recents
  (add-hook 'pre-command-hook #'my/enable-deferred-modes)
  ;; Move point into help buffers (describe-key/function/…) so they're readable
  ;; and q-dismissable straight away.
  (setq help-window-select t)
  (add-hook 'after-init-hook
            (lambda () (when (file-exists-p custom-file) (load custom-file nil t))))
  :bind
  (
   ("C-h"  . windmove-left)
   ("C-l"  . windmove-right)
   ("C-q"  . delete-window)
   ("s-q"  . my/delete-frame-confirm)   ; Cmd-Q closes the frame (not the daemon)
   ("C-x C-r" . eval-region)            ; eval the region (was find-file-read-only)
   ("C-."     . find-file)              ; same as the `SPC .' leader
   :map minibuffer-local-map
   ("C-w"  . backward-kill-word)))

(setq-default js-indent-level 2
              typescript-ts-mode-indent-offset 2
              css-indent-offset 2
              sgml-basic-offset 2
              sh-basic-offset 2
              lua-indent-level 2
              c-basic-offset 2
              python-indent-offset 4)   ; Python convention

(use-package which-key
  :ensure nil
  :custom
  (which-key-idle-delay 0.4)
  (which-key-add-column-padding 3)       ; breathing room between columns (doom-ish)
  (which-key-separator "  ")
  (which-key-min-display-lines 2)
  :init (which-key-mode 1))

(use-package window
  :ensure nil
  :custom
  (switch-to-buffer-obey-display-actions t)
  (even-window-sizes 'height-only)
  (split-height-threshold 80)
  (split-width-threshold 140))

(use-package winner
  :ensure nil
  :init (winner-mode 1))

;; "Focus follows width": grow the selected window toward `my/focus-width' (so
;; 80-col code never wraps), shrinking the rest.  Toggle on SPC w f.
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
        (ignore-errors (window-resize (selected-window) delta t))))))

(define-minor-mode my/focus-width-mode
  "Keep the focused window at least `my/focus-width' columns wide."
  :global t
  (if my/focus-width-mode
      (progn
        (add-hook 'window-selection-change-functions #'my/focus-width--apply)
        (my/focus-width--apply))
    (remove-hook 'window-selection-change-functions #'my/focus-width--apply)
    (balance-windows)))

;; Doom's `SPC f p': jump to a config file (recipes + top-level), bound SPC P.
;; `recipes/' is a symlink into the dotfiles repo, so we must follow symlinks
;; (5th arg) AND skip package/cache dirs while descending (4th arg predicate) —
;; otherwise the recursion either misses recipes/ or drowns in elpa.
(defvar my/config-skip-dirs '("elpa" "eln-cache" ".git" "backups" "autosave")
  "Directory names `my/find-in-config' never descends into.")

(defvar my/config-skip-files '("custom.el" "org-clock-save.el")
  "Auto-generated .el files `my/find-in-config' hides.")

(defun my/find-in-config ()
  "Open any .el file under the Emacs config directory, recursively."
  (interactive)
  (let* ((root (expand-file-name user-emacs-directory))
         (files (directory-files-recursively
                 root "\\.el\\'" nil
                 (lambda (d)
                   (not (member (file-name-nondirectory (directory-file-name d))
                                my/config-skip-dirs)))
                 t))                     ; follow symlinks (recipes/ is one)
         (files (seq-remove
                 (lambda (f) (member (file-name-nondirectory f) my/config-skip-files))
                 files))
         (rel (mapcar (lambda (f) (file-relative-name f root)) files)))
    (find-file (expand-file-name (completing-read "Config: " rel nil t) root))))

(defun my/read-event-esc-quits (orig &rest args)
  "Around-advice: make ESC quit during ORIG's `read-event` loop.
Passes ARGS to ORIG."
  (cl-letf* ((real (symbol-function 'read-event))
             ((symbol-function 'read-event)
              (lambda (&rest a)
                (let ((ev (apply real a)))
                  (if (memq ev '(?\e escape)) (keyboard-quit) ev)))))
    (apply orig args)))

;; Kill-modified-buffer prompt: ESC = "no, don't kill".
(advice-add 'kill-buffer--possibly-save :around #'my/read-event-esc-quits)

(defun my/delete-frame-confirm ()
  (interactive)
  (when (eq ?y (car (my/read-event-esc-quits
                     #'read-multiple-choice
                     "Delete this frame?"
                     '((?y "yes" "delete this frame")
                       (?n "no"  "keep this frame")))))
    (delete-frame)))

(defun my/reveal-in-finder ()
  "Reveal the current file in macOS Finder (the directory if no file)."
  (interactive)
  (unless (eq system-type 'darwin)
    (user-error "Reveal in Finder is macOS-only"))
  (let ((file (if (derived-mode-p 'dired-mode)
                  (dired-get-file-for-visit)
                buffer-file-name)))
    (if file
        (call-process "open" nil nil nil "-R" (expand-file-name file))
      (call-process "open" nil nil nil (expand-file-name default-directory)))))

(defun my/reveal-project-in-finder ()
  "Reveal the current project root in macOS Finder."
  (interactive)
  (unless (eq system-type 'darwin)
    (user-error "Reveal in Finder is macOS-only"))
  (call-process "open" nil nil nil
                (expand-file-name
                 (or (and (fboundp 'projectile-project-root) (projectile-project-root))
                     default-directory))))

;; macOS daemon: a Dock-launcher client frame (`emacsclient -c -n') opens BEHIND
;; the frontmost app — the daemon isn't the active process, so the frame can't
;; raise itself.  `ns-hide-emacs 'activate' self-activates (no AppleScript
;; app-name race) once the GUI frame is up.
(when (and (daemonp) (featurep 'ns))
  (defun my/ns-raise-emacs-on-server-frame ()
    (when (display-graphic-p)
      (select-frame-set-input-focus (selected-frame))
      (ns-hide-emacs 'activate)))
  (add-hook 'server-after-make-frame-hook #'my/ns-raise-emacs-on-server-frame t))

(use-package webjump
  :ensure nil
  :commands (webjump)
  :bind ("C-x /" . webjump)
  :custom
  (webjump-sites
   '(("DuckDuckGo" . [simple-query "duckduckgo.com" "duckduckgo.com/?q=" ""])
     ("Google"     . [simple-query "google.com" "google.com/search?q=" ""])
     ("YouTube"    . [simple-query "youtube.com/feed/subscriptions" "youtube.com/results?search_query=" ""])
     ("Wikipedia"  . [simple-query "wikipedia.org" "wikipedia.org/wiki/" ""])
     ("Archwiki"   . [simple-query "wiki.archlinux.org" "wiki.archlinux.org/index.php?search=" ""])
     ("ChatGPT"    . [simple-query "chatgpt.com" "chatgpt.com/?q=" ""]))))

(provide 'base-rcp)
;;; base-rcp.el ends here
