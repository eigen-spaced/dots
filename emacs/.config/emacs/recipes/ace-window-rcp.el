;;; ace-window-rcp.el --- jump to any window by label -*- lexical-binding: t; -*-
;; Letter-labelled window selector; complements directional windmove (C-h/C-l).
;; Reachable via `M-o' and the `SPC w w' leader (bound in meow-rcp).
;;; Code:
(eval-when-compile (require 'use-package))

(use-package ace-window
  :bind ("M-o" . ace-window)
  :commands (ace-window)
  :custom
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))   ; home-row window labels
  (aw-scope 'frame)                          ; only the current frame's windows
  (aw-background t))                         ; dim the others while choosing

(provide 'ace-window-rcp)
;;; ace-window-rcp.el ends here
