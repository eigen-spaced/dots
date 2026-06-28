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
                                       (width         . 70)
                                       (height        . 25)))
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

  ;; --- Show only the popup --------------------------------------------
  ;; macOS activation is per-APP: raising the popup raises every visible Emacs
  ;; frame with it.  There is no per-window activation, so the only way to show
  ;; the popup alone (a WM like yabai would float it; we have none) is to make
  ;; the existing frames invisible while it's up and restore them on finish.
  ;; `make-frame-invisible' is instant (no minimise animation), and the popup is
  ;; spawned async right after, so the swap isn't perceptible.
  (defvar my/ee--hidden-frames nil)
  (defun my/ee-hide-others (&rest _)
    (setq my/ee--hidden-frames (seq-filter #'frame-visible-p (frame-list)))
    (dolist (f my/ee--hidden-frames) (make-frame-invisible f t)))
  (defun my/ee-restore-others (&rest _)
    ;; Restore visible-but-behind: `emacs-everywhere-finish' refocuses the source
    ;; app next, so we don't want these flashed to the front.
    (dolist (f my/ee--hidden-frames)
      (when (frame-live-p f) (make-frame-visible f) (lower-frame f)))
    (setq my/ee--hidden-frames nil))
  (defun my/ee-restore-on-abort (frame)
    "Restore if the popup is closed without finishing (e.g. deleted)."
    (when (and my/ee--hidden-frames (frame-parameter frame 'emacs-everywhere-app))
      (my/ee-restore-others)))
  ;; Only macOS raises every app window together; elsewhere a WM handles it.
  (when (eq system-type 'darwin)
    (advice-add 'emacs-everywhere        :before #'my/ee-hide-others)
    (advice-add 'emacs-everywhere-finish :before #'my/ee-restore-others)
    (add-hook 'delete-frame-functions #'my/ee-restore-on-abort)))

;; Pre-warm at idle so the FIRST capture isn't the cold one.  The first osascript
;; per session pays a one-off AppleScript-runtime init; on a fresh daemon that
;; overruns `emacs-everywhere-clipboard-sleep-delay' (0.1s on macOS), so the
;; finish pastes before the source app refocuses and the text is lost.  Loading
;; the package (compiles the helper scripts) and spending one throwaway osascript
;; pays that cost up front, so the first real C-c C-c behaves like the rest.
(run-with-idle-timer
 2 nil
 (lambda ()
   (require 'emacs-everywhere nil t)
   (when (eq system-type 'darwin)
     (call-process "osascript" nil nil nil "-e" "return 1"))))

(provide 'emacs-everywhere-rcp)
;;; emacs-everywhere-rcp.el ends here
