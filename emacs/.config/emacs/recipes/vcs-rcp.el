;;; vcs-rcp.el --- magit -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package magit
  :commands (magit-status magit-dispatch magit-blame magit-log-current)
  :custom
  ;; magit-status fills the whole frame; quitting it (q) restores the layout.
  (magit-display-buffer-function #'magit-display-buffer-fullframe-status-v1)
  :config
  ;; On commit, stack the diff below the message (top/bottom) instead of the
  ;; default side-by-side split.
  (add-to-list 'display-buffer-alist
               '("\\`magit-diff:" (display-buffer-below-selected))))

;; Margin diff indicators (the "git gutter"), sharing flymake's column.  diff-hl
;; over git-gutter because it hooks magit's refresh — the gutter updates the
;; moment you stage/commit/checkout instead of polling on a timer.  flydiff
;; updates on edit (not just save); dired markers show changed files in dirvish.
(use-package diff-hl
  :init (global-diff-hl-mode)
  :hook ((magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh)
         (dired-mode         . diff-hl-dired-mode))
  :config
  (diff-hl-flydiff-mode)
  ;; --- One column: diagnostics take precedence over git-diff ---------------
  ;; Put the gutter in the left margin (not the fringe) so it shares flymake's
  ;; column.  On a line that is both changed and flagged we want the diagnostic
  ;; glyph: skip diff-hl's margin marker wherever a flymake diagnostic sits.
  ;; flymake's `(nil . N)' overlay priority doesn't reliably win the margin cell,
  ;; so do it deterministically -- and re-render diff-hl after each flymake update
  ;; (flymake never notifies diff-hl) so markers track errors as they come/go.
  (require 'diff-hl-margin)
  ;; A thin coloured bar for adds/changes; a thick red minus for deletions.
  (setq diff-hl-margin-symbols-alist '((insert . "▎") (delete . "━") (change . "▎")
                                       (unknown . "?") (ignored . "i")))
  ;; The diff-hl-margin-* faces colour the BACKGROUND (a block behind the symbol);
  ;; recolour them to paint the bar glyph itself (foreground, no block) using the
  ;; theme's diff colours.  Re-applied on theme switch.
  (defun my/diff-hl-margin-bar-faces (&rest _)
    (dolist (pair '((diff-hl-margin-insert . diff-hl-insert)
                    (diff-hl-margin-change . diff-hl-change)
                    (diff-hl-margin-delete . diff-hl-delete)))
      (when (facep (car pair))
        (let ((color (face-attribute (cdr pair) :background nil t)))
          (unless (eq color 'unspecified)
            (set-face-attribute (car pair) nil :inherit 'unspecified
                                :foreground color :background 'unspecified))))))
  (my/diff-hl-margin-bar-faces)
  (advice-add 'load-theme :after #'my/diff-hl-margin-bar-faces)
  (diff-hl-margin-mode 1)
  (defun my/diff-hl-yield-to-flymake (orig ovl type shape)
    "Around `diff-hl-highlight-on-margin': yield the cell to a flymake diagnostic."
    (if (and (bound-and-true-p flymake-mode)
             (save-excursion
               (goto-char (overlay-start ovl))
               (flymake-diagnostics (line-beginning-position) (line-end-position))))
        (overlay-put ovl 'before-string nil)
      (funcall orig ovl type shape)))
  (advice-add 'diff-hl-highlight-on-margin :around #'my/diff-hl-yield-to-flymake)

  (defun my/diff-hl-refresh-after-flymake (&rest _)
    "Re-render diff-hl right after flymake updates so the margin markers track
diagnostics (flymake never notifies diff-hl).  Synchronous on purpose -- an idle
timer here fired unreliably and left the diff marker showing under the glyph."
    (when (and (bound-and-true-p diff-hl-mode) (bound-and-true-p diff-hl-margin-mode))
      (diff-hl-update)))
  (with-eval-after-load 'flymake
    (advice-add 'flymake--publish-diagnostics :after #'my/diff-hl-refresh-after-flymake)))

(provide 'vcs-rcp)
;;; vcs-rcp.el ends here
