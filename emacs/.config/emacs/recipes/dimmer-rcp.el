;;; dimmer-rcp.el --- dim inactive windows to spotlight the current one -*- lexical-binding: t; -*-
;; Continuously dims non-selected windows so the active one stands out.  Child
;; frames (corfu, eldoc-box) are auto-excluded by dimmer (2026+), so the only
;; tweaks needed are the popup helpers for which-key/magit/org.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package dimmer
  :custom
  (dimmer-fraction 0.4)                   ; how much to dim inactive windows (0.2 subtle … 0.5 strong)
  (dimmer-adjustment-mode :foreground)    ; fade the text, leave the background
  (dimmer-watch-frame-focus-events nil)   ; don't dim when Emacs loses macOS focus
  :config
  (dimmer-configure-which-key)            ; keep the which-key popup bright
  (dimmer-configure-magit)                ; and magit's transient popups
  (dimmer-configure-org)                  ; and org src/edit buffers
  (dimmer-mode 1))

(provide 'dimmer-rcp)
;;; dimmer-rcp.el ends here
