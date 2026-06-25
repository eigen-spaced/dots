;;; ui-rcp.el --- theme, icons, font -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package modus-themes)

;; pixel-themes builds on modus-themes; not on an ELPA archive, so install via :vc.
;; bat preview colours are kept in sync in bat/themes/pixel-miri16.tmTheme.
(use-package pixel-themes
  :vc (:url "https://github.com/lucasobx/pixel-themes" :rev :newest)
  :config
  (pixel-themes-mode 1)
  (pixel-themes-load-theme 'pixel-themes-alia16))

(use-package nerd-icons)

(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode))

;; Darker background for UI buffers (minibuffer, popups, sidebars) vs file buffers.
(use-package solaire-mode
  :config (solaire-global-mode +1))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

;; Doom-style thin window dividers instead of the native border.
(setq window-resize-pixelwise nil
      window-divider-default-places t
      window-divider-default-bottom-width 1
      window-divider-default-right-width 1)
(add-hook 'after-init-hook #'window-divider-mode)

;; A pixel-maximized GUI frame's text area isn't a whole number of rows, so the
;; modeline clips a partial last line (Doom's window settings don't fix this --
;; the divider just hides it behind a tidy rule).  Grow the modeline to swallow
;; the leftover so the bottom line is whole; recomputed per frame, so it adapts
;; to screen / font / divider width.
(defun my/doom-modeline-fit-frame (&rest _)
  (when (and (display-graphic-p) (bound-and-true-p doom-modeline-mode))
    (let* ((ch (frame-char-height))
           (rem (mod (window-body-height (frame-root-window) t) ch)))
      (when (and (> rem 0) (< rem ch))
        (setq doom-modeline-height (+ doom-modeline-height rem))
        (ignore-errors (doom-modeline-refresh-bars))))))
(add-hook 'server-after-make-frame-hook #'my/doom-modeline-fit-frame)
(add-hook 'window-setup-hook #'my/doom-modeline-fit-frame)

(set-face-attribute 'default nil :font "Cascadia Code NF" :height 180)

(provide 'ui-rcp)
;;; ui-rcp.el ends here
