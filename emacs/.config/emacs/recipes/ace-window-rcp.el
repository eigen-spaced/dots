;;; ace-window-rcp.el --- jump to any window by label -*- lexical-binding: t; -*-
;; Letter-labelled window selector; complements directional windmove (C-h/C-l).
;; Reachable via `M-o' and the `SPC w w' leader (bound in meow-rcp).
;;; Code:
(eval-when-compile (require 'use-package))

(use-package ace-window
  :bind ("M-o" . ace-window)
  :commands (ace-window)
  :custom
  (aw-keys '(?q ?w ?e ?r ?t ?y ?u ?i ?o ?p)) ; top-row labels; frees the home row for dispatch
  (aw-scope 'frame)                          ; only the current frame's windows
  (aw-background t)                          ; dim the others while choosing
  :config
  ;; Dispatch actions on the (now free) home row, off the top-row labels.  Splits
  ;; are named by RESULT, not Emacs' vert/horz (which read backwards in vim terms):
  ;; `v' = side-by-side (vim :vsplit), `s' = stacked (vim :split).
  (setq aw-dispatch-alist
        '((?x aw-delete-window             "Delete window")
          (?d delete-other-windows         "Delete other windows")
          (?m aw-swap-window               "Swap windows")
          (?M aw-move-window               "Move window here")
          (?c aw-copy-window               "Copy window here")
          (?n aw-flip-window               "Flip to previous")
          (?j aw-switch-buffer-in-window   "Select buffer here")
          (?k aw-switch-buffer-other-window "Buffer → other window")
          (?v aw-split-window-horz         "Split → side-by-side (right)")
          (?s aw-split-window-vert         "Split ↓ stacked (below)")
          (?f aw-split-window-fair         "Split fair")
          (?? aw-show-dispatch-help))))

;; Rearrange windows by label (bound under `SPC w' in meow-rcp).  `ace-swap-window'
;; ships interactive; move/copy wrap `aw-select' on the matching action.
(defun my/ace-move-window ()
  "Move the current buffer into a window chosen with ace-window."
  (interactive)
  (require 'ace-window)
  (aw-select " Move buffer to window" #'aw-move-window))

(defun my/ace-copy-window ()
  "Mirror the current buffer into a window chosen with ace-window (kept here too)."
  (interactive)
  (require 'ace-window)
  (aw-select " Copy buffer to window" #'aw-copy-window))

(provide 'ace-window-rcp)
;;; ace-window-rcp.el ends here
