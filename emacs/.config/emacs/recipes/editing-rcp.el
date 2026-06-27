;;; editing-rcp.el --- avy, undo-fu, evil-matchit, mwim -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; Smart line motion: M-h/M-l toggle between code/line beginning and end.
(use-package mwim
  :bind (("M-h" . mwim-beginning)
         ("M-l" . mwim-end)))

(use-package avy
  :commands (avy-goto-char-timer avy-goto-char-2 avy-goto-word-1 avy-goto-line avy-resume)
  :bind (("C-:" . avy-goto-char-timer)
         ("C-'" . avy-goto-char-2)
         ("M-g f" . avy-goto-line)
         ("M-g w" . avy-goto-word-1))
  :custom
  (avy-timeout-seconds 0.5)
  (avy-all-windows nil)
  (avy-background t))

(use-package undo-fu
  :commands (undo-fu-only-undo undo-fu-only-redo)
  :custom
  ;; Raise the ceilings so long histories aren't truncated (Doom's values) --
  ;; otherwise persisted undo gets cut off on reload.
  (undo-limit        (* 256 1024))       ; 256kb
  (undo-strong-limit (* 3 1024 1024))    ; 3mb
  (undo-outer-limit  (* 48 1024 1024)))  ; 48mb

(use-package undo-fu-session
  :init (undo-fu-session-global-mode)
  :custom
  (undo-fu-session-directory
   (expand-file-name "undo-fu-session" user-emacs-directory)))

(use-package evil-matchit
  :commands (evilmi-jump-items-native))

(use-package embrace
  :bind ("M-," . embrace-commander)
  ;; Drop the inverse-video "boxes" on the pair previews -> clean coloured text,
  ;; closer to meow's thing menu.
  :custom-face
  (embrace-help-pair-face ((t (:inherit font-lock-function-name-face)))))

(provide 'editing-rcp)
;;; editing-rcp.el ends here
