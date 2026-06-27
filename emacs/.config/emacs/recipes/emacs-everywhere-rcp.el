;;; emacs-everywhere-rcp.el --- edit any app's text field in Emacs -*- lexical-binding: t; -*-
;; Global hotkey (Hammerspoon ⌘⌥E) fires `emacs-everywhere': it grabs the
;; focused text field of whatever app is frontmost into a dedicated Emacs frame;
;; C-c C-c (or finishing) sends the edited text back and dismisses the frame.
;;
;;; Code:
(eval-when-compile (require 'use-package))

(use-package emacs-everywhere
  :commands (emacs-everywhere)
  :custom
  ;; Match `my/capture-frame': a centered 100x30 window, never fullscreen.
  (emacs-everywhere-frame-parameters '((name          . "emacs-everywhere")
                                       (window-system . ns)
                                       (fullscreen    . nil)
                                       (width         . 90)
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
                      emacs-everywhere-init-hooks)))

  ;; --- Keep the rest of Emacs out of the way --------------------------
  ;; `emacs-everywhere' spawns `emacsclient -c', and a fresh client frame on
  ;; macOS activates the whole app -- so every existing Emacs frame surfaces
  ;; alongside the popup (`my/capture-frame' sidesteps this with an in-process
  ;; `make-frame').  Hide the other frames just before the popup is spawned and
  ;; restore them as it finishes, so only the emacs-everywhere frame shows.
  (defvar my/emacs-everywhere--hidden-frames nil)
  (defun my/emacs-everywhere-hide-others (&rest _)
    (setq my/emacs-everywhere--hidden-frames
          (seq-filter #'frame-visible-p (frame-list)))
    (dolist (f my/emacs-everywhere--hidden-frames)
      (make-frame-invisible f t)))
  (defun my/emacs-everywhere-restore-others (&rest _)
    ;; Show, then immediately order to the back: `emacs-everywhere-finish' next
    ;; refocuses the source app, so we want these visible-but-behind, not flashed
    ;; to the front.
    (dolist (f my/emacs-everywhere--hidden-frames)
      (when (frame-live-p f) (make-frame-visible f) (lower-frame f)))
    (setq my/emacs-everywhere--hidden-frames nil))
  (defun my/emacs-everywhere--maybe-restore (frame)
    "Safety net: restore if the popup frame is closed without finishing."
    (when (and my/emacs-everywhere--hidden-frames
               (equal (frame-parameter frame 'name) "emacs-everywhere"))
      (my/emacs-everywhere-restore-others)))
  (advice-add 'emacs-everywhere        :before #'my/emacs-everywhere-hide-others)
  (advice-add 'emacs-everywhere-finish :before #'my/emacs-everywhere-restore-others)
  (add-hook 'delete-frame-functions #'my/emacs-everywhere--maybe-restore))

(provide 'emacs-everywhere-rcp)
;;; emacs-everywhere-rcp.el ends here
