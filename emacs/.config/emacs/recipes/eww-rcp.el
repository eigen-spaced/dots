;;; eww-rcp.el --- eww reading: serif prose, soft-wrap, side pane, SVG zoom -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(defun my/reading-serif ()
  "Remap the current buffer's `variable-pitch' face to Merriweather.
Shared by eww, org prose, and the notmuch message view."
  (face-remap-add-relative 'variable-pitch :family "Merriweather 24pt"))

(defun my/eww-reflow ()
  "Soft-wrap eww paragraphs to the window width (no baked-in shr breaks)."
  (setq-local shr-fill-text nil)
  (visual-line-mode 1))

(use-package shr-tag-pre-highlight
  :after shr
  :config
  (add-to-list 'shr-external-rendering-functions
               '(pre . shr-tag-pre-highlight)))

(use-package olivetti
  :commands (olivetti-mode)
  :custom (olivetti-body-width 80))

(use-package eww
  :ensure nil
  :commands (eww eww-readable)
  :hook ((eww-mode . my/reading-serif)
         (eww-mode . my/eww-reflow))
  :bind (:map eww-mode-map ("C-c c" . olivetti-mode))
  :config
  ;; A normal splittable window on the right (not a locked side-window).
  (add-to-list 'display-buffer-alist
               '("\\*eww\\*"
                 (display-buffer-in-direction)
                 (direction . right)
                 (window-width . 0.5)))
  (require 'eww-svg-zoom))

(provide 'eww-rcp)
;;; eww-rcp.el ends here
