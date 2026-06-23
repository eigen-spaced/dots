;;; term-rcp.el --- ghostel terminal: popup + full -*- lexical-binding: t; -*-
;; ghostel is an Emacs terminal powered by libghostty-vt (Ghostty's VT engine);
;; its native module auto-downloads on first use, no toolchain needed.
;; SPC o t toggles a bottom popup terminal, SPC o T opens a full one.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package ghostel
  :commands (ghostel ghostel-project my/ghostel-popup my/ghostel-full))

(defun my/ghostel--root ()
  "Project root, or `default-directory' when outside a project."
  (or (when-let ((p (project-current))) (project-root p)) default-directory))

(defvar my/ghostel-popup-buffer nil
  "The dedicated popup terminal buffer.
Held as an object so ghostel's title-driven buffer renames don't lose it.")

(defun my/ghostel-popup ()
  "Toggle a project-rooted popup terminal in a bottom side window.
A separate terminal from `my/ghostel-full' (distinct `ghostel-buffer-name')."
  (interactive)
  (let ((buf (and (buffer-live-p my/ghostel-popup-buffer) my/ghostel-popup-buffer)))
    (if (and buf (get-buffer-window buf))
        (delete-window (get-buffer-window buf))            ; visible -> hide
      (unless buf                                          ; create once
        (let ((default-directory (my/ghostel--root))
              (ghostel-buffer-name "*ghostel-popup*"))
          (setq buf (save-window-excursion (ghostel))
                my/ghostel-popup-buffer buf)))
      (select-window
       (display-buffer-in-side-window
        buf '((side . bottom) (slot . 0) (window-height . 0.3)))))))

(defun my/ghostel-full ()
  "Open a project-rooted terminal in the current window."
  (interactive)
  (let ((default-directory (my/ghostel--root)))
    (ghostel)))

(provide 'term-rcp)
;;; term-rcp.el ends here
