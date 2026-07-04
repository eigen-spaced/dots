;;; ui-rcp.el --- theme, icons, font -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; Theme packages -- switch any time with `SPC t t' (persists across restarts).
;; ef-dream (Prot's ef-themes) is the default; modus-themes + doom-themes stay
;; installed to switch to.
(use-package modus-themes
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  (modus-themes-org-blocks 'gray-background))

(use-package ef-themes)

(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (doom-themes-org-config))

;; doom-themes + Emacs 31 face-inheritance cycle (doomemacs/themes#875): Emacs 31
;; now forbids cyclic :inherit and ERRORS while realizing the face, which aborts
;; new GUI-frame creation -- emacsclient -c (the launcher, ⌘⌃ binds) then makes no
;; frame.  The cycle: Emacs 31's `gnus-group-news-low' inherits
;; `gnus-group-news-low-empty', which doom-themes points back at
;; `gnus-group-news-low'.  We don't use gnus, so flatten the gnus-group faces'
;; inheritance via a top-priority override after every `load-theme' (also guards
;; switching to a doom theme).  Drop once doom-themes ships the fix (v2.4.0).
(defun my/flatten-gnus-faces (&rest _)
  (dolist (f (face-list))
    (when (string-prefix-p "gnus-group-" (symbol-name f))
      (ignore-errors
        (face-spec-set f '((t :inherit unspecified)) 'face-override-spec)))))
(advice-add 'load-theme :after #'my/flatten-gnus-faces)
;; The advice only reaches faces that exist when the theme loads; the gnus-group
;; faces are defined later in startup (so the initial flatten misses them, leaving
;; the cycle to abort the first GUI frame).  Re-run once init is done -- on a
;; daemon this is before any client frame realizes faces.
(add-hook 'emacs-startup-hook #'my/flatten-gnus-faces)

(defvar my/default-theme 'ef-dream
  "Fallback theme when `my/theme-file' holds no saved choice.")

;; Persist the SPC t t pick: `consult-theme' writes the chosen theme to a
;; machine-local file (gitignored), and startup/reload prefers it over
;; `my/default-theme' -- so a theme switch survives restarts.
(defvar my/theme-file (expand-file-name "theme" user-emacs-directory)
  "File holding the last theme picked with `consult-theme'.")

(defun my/saved-theme ()
  "Theme saved in `my/theme-file' (if still installed), else `my/default-theme'."
  (or (when (file-readable-p my/theme-file)
        (let ((sym (intern (string-trim
                            (with-temp-buffer
                              (insert-file-contents my/theme-file)
                              (buffer-string))))))
          (car (memq sym (custom-available-themes)))))
      my/default-theme))

(defun my/theme-persist (&rest _)
  "Save the active theme to `my/theme-file'."
  (when-let* ((theme (car custom-enabled-themes)))
    (with-temp-file my/theme-file (insert (symbol-name theme) "\n"))))
(advice-add 'consult-theme :after #'my/theme-persist)

(load-theme (my/saved-theme) t)

;; On a daemon the theme loads before any GUI frame exists, so frame-dependent
;; face attributes (notably the default background) never get set -- you get the
;; theme's foreground on a white background.  Re-apply once a graphical frame is
;; up, then drop the hook (same pattern as the dashboard reload).
(when (daemonp)
  (defun my/theme-reapply-on-frame ()
    (when (display-graphic-p)
      (load-theme (my/saved-theme) t)
      (remove-hook 'server-after-make-frame-hook #'my/theme-reapply-on-frame)))
  (add-hook 'server-after-make-frame-hook #'my/theme-reapply-on-frame))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  ;; Icons only appear once this hooks marginalia's annotation pipeline. Add it
  ;; for future toggles AND run it now -- marginalia-mode is already enabled, so
  ;; its mode-hook won't fire again.
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)
  (nerd-icons-completion-marginalia-setup))

;; Darker background for UI buffers (minibuffer, popups, sidebars) vs file buffers.
(use-package solaire-mode
  :config (solaire-global-mode +1))

;; Doom-style thin window dividers instead of the native border.
(setq window-resize-pixelwise nil
      window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(add-hook 'after-init-hook #'window-divider-mode)

(set-face-attribute 'default nil :font "Cascadia Code NF" :height 180)

;; macOS: blend the titlebar into the theme and force dark window chrome.
;; Guard on the OS, not `window-system' -- on the daemon that's nil at load time
;; (see the doom-themes note above), so a `(memq window-system ...)' check would
;; skip these and emacsclient frames would miss them.  The ns- params are ignored
;; off ns frames, so gating on darwin is safe.
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))

(provide 'ui-rcp)
;;; ui-rcp.el ends here
