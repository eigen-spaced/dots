;;; vcs-rcp.el --- magit -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package magit
  :commands (magit-status magit-dispatch magit-blame magit-log-current))

;; Fringe diff indicators (the "git gutter").  diff-hl over git-gutter because
;; it hooks magit's refresh — the gutter updates the moment you stage/commit/
;; checkout instead of polling on a timer.  flydiff updates on edit (not just
;; save); dired markers show changed files in dirvish/dired.
(use-package diff-hl
  :init (global-diff-hl-mode)
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode         . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode))

(provide 'vcs-rcp)
;;; vcs-rcp.el ends here
