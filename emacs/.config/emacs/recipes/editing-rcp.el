;;; editing-rcp.el --- avy, undo-fu, evil-matchit, mwim -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; Smart line motion: M-h/M-l toggle between code/line beginning and end.
(use-package mwim
  :bind (("M-h" . mwim-beginning)
         ("M-l" . mwim-end)))

(use-package avy
  :commands (avy-goto-char-timer avy-goto-char-2 avy-goto-word-1 avy-goto-line avy-resume)
  :custom
  (avy-timeout-seconds 0.3)
  (avy-all-windows nil)
  (avy-background t))

(use-package undo-fu
  :commands (undo-fu-only-undo undo-fu-only-redo))

(use-package evil-matchit
  :commands (evilmi-jump-items-native))

;; Surround: change/delete/add pairs (C-, a/c/d).  Quick add is also on the
;; meow-normal open-pair keys (see meow-rcp's my/meow-surround-*).
(use-package embrace
  :bind ("C-," . embrace-commander))

(provide 'editing-rcp)
;;; editing-rcp.el ends here
