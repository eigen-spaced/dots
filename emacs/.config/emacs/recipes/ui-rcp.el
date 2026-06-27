;;; ui-rcp.el --- theme, icons, font -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package modus-themes)

;; pixel-themes builds on modus-themes; not on an ELPA archive, so install via :vc.
;; bat preview colours are kept in sync in bat/themes/pixel-miri16.tmTheme.
;; Kept installed (not the active theme) so `SPC t t' can switch back to it.
(use-package pixel-themes
  :vc (:url "https://github.com/lucasobx/pixel-themes" :rev :newest)
  :config
  (pixel-themes-mode 1))

;; doom-themes (https://github.com/doomemacs/themes) -- doom-one is active.
;; modus/pixel above stay installed; switch with `SPC t t'.
(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme 'doom-one t)
  (doom-themes-org-config)
  ;; On a daemon the theme loads before any GUI frame exists, so frame-dependent
  ;; face attributes (notably the default background) never get set -- you get
  ;; the theme's foreground on a white background.  Re-apply once a graphical
  ;; frame is up, then drop the hook (same pattern as the dashboard reload).
  (when (daemonp)
    (defun my/theme-reapply-on-frame ()
      (when (display-graphic-p)
        (load-theme 'doom-one t)
        (remove-hook 'server-after-make-frame-hook #'my/theme-reapply-on-frame)))
    (add-hook 'server-after-make-frame-hook #'my/theme-reapply-on-frame)))

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
