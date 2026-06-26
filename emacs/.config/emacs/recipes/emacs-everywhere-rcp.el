;;; emacs-everywhere-rcp.el --- edit any app's text field in Emacs -*- lexical-binding: t; -*-
;; Global hotkey (Hammerspoon ⌘⌥E) fires `emacs-everywhere': it grabs the
;; focused text field of whatever app is frontmost into a dedicated Emacs frame;
;; C-c C-c (or finishing) sends the edited text back and dismisses the frame.
;;
;; macOS needs Emacs granted Accessibility + Automation ("control System
;; Events") on first use -- accept the prompt, or copy-in / paste-back can't
;; reach the source app.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package emacs-everywhere
  :commands (emacs-everywhere)
  :custom
  ;; Match `my/capture-frame': a centered 100x30 window, never fullscreen.
  (emacs-everywhere-frame-parameters '((name          . "emacs-everywhere")
                                       (window-system . ns)
                                       (fullscreen    . nil)
                                       (width         . 100)
                                       (height        . 30)))
  :config
  ;; --- macOS osascript helpers ----------------------------------------
  ;; emacs-everywhere compiles its AppleScript helpers into the resource fork
  ;; in an obsolete format, so osascript dies with errOSADataFormatObsolete
  ;; (-1758).  Recompile them clean and strip the resource fork/FinderInfo.

  ;; BUG: `--ensure-oscascript-compiled' checks file-exists against the caller's
  ;; default-directory, so it recompiles on every call -- bind default-directory.
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled :around
              (lambda (orig &rest args)
                (let ((default-directory emacs-everywhere--dir))
                  (apply orig args))))

  (defvar my/emacs-everywhere--osascripts-fixed nil)
  (defun my/emacs-everywhere-recompile-osascripts (&rest _)
    "Recompile the bundled .applescript helpers clean, once per session."
    (unless my/emacs-everywhere--osascripts-fixed
      (dolist (s '("app-name" "window-title" "window-geometry"))
        (let ((src (expand-file-name (concat s ".applescript") emacs-everywhere--dir))
              (out (expand-file-name s emacs-everywhere--dir)))
          (when (file-exists-p src)
            (when (file-exists-p out) (delete-file out))
            (call-process "osacompile" nil nil nil "-o" out src)
            (call-process "xattr" nil nil nil "-c" out))))
      (setq my/emacs-everywhere--osascripts-fixed t)))
  (advice-add 'emacs-everywhere--ensure-oscascript-compiled
              :after #'my/emacs-everywhere-recompile-osascripts)
  (emacs-everywhere--ensure-oscascript-compiled)

  ;; --- Open empty + centered ------------------------------------------
  ;; Drop `insert-selection' (its ⌘C/yank fallback leaked a stray `c' + stale
  ;; clipboard) and replace mouse-positioning with centering (`my/center-frame'
  ;; lives in org-rcp).
  (defun my/emacs-everywhere-center-frame ()
    (my/center-frame (selected-frame)))
  (setq emacs-everywhere-init-hooks
        (mapcar (lambda (h) (if (eq h 'emacs-everywhere-set-frame-position)
                                #'my/emacs-everywhere-center-frame h))
                (remq 'emacs-everywhere-insert-selection
                      emacs-everywhere-init-hooks))))

(provide 'emacs-everywhere-rcp)
;;; emacs-everywhere-rcp.el ends here
