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

(set-face-attribute 'default nil :font "Cascadia Code NF" :height 180)

(provide 'ui-rcp)
;;; ui-rcp.el ends here
