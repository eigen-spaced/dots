;;; javelin-rcp.el --- harpoon-style buffer pinning, scoped per project+branch -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; Default keys are M-1..9 (= digit-argument); move them to A-<n> (right-Option,
;; see early-init) so javelin sits beside the H-<n> workspace keys on the right
;; hand -- modifier under the right thumb, number under the left.
(use-package javelin
  :config
  (global-javelin-minor-mode 1)
  (let ((m javelin-minor-mode-map))
    (dotimes (i 9)
      (let ((n (1+ i)))
        (define-key m (kbd (format "A-%d" n))
                    (intern (format "javelin-go-or-assign-to-%d" n)))
        (define-key m (kbd (format "M-%d" n)) nil)))
    (define-key m (kbd "A-0") (lookup-key m (kbd "M-0")))   ; delete sub-map
    (define-key m (kbd "M-0") nil)
    (define-key m (kbd "A--") #'javelin-toggle-quick-menu)
    (define-key m (kbd "M--") nil)))

;; Javelin stores its pins as plain file bookmarks named "javelin:PROJECT:N", so
;; they otherwise blend into `consult-bookmark' under the generic "File" group.
;; Re-tag them into their own "Javelin" group (narrow with `j') -- display only,
;; the bookmark records and javelin's own jump are untouched.
(defun my/consult-bookmark-tag-javelin (cands)
  "Tag javelin entries in CANDS so `consult-bookmark' groups them as Javelin."
  (dolist (c cands cands)
    (when (string-prefix-p "javelin:" c)
      (put-text-property 0 (length c) 'consult--type ?j c))))

(with-eval-after-load 'consult
  (add-to-list 'consult-bookmark-narrow '(?j "Javelin"))
  (advice-add 'consult--bookmark-candidates :filter-return
              #'my/consult-bookmark-tag-javelin))

;; Javelin pins are plain bookmarks, so Emacs marks them with the built-in
;; bookmark *fringe* bitmap -- which lands in the left fringe beside diff-hl's
;; git gutter, and a fringe can only hold monochrome bitmaps (no nerd glyph).
;; Override the mark to draw a nerd bookmark icon in the left *margin* instead,
;; i.e. the same column flymake uses (`flymake-indicator-type 'margins').
(require 'nerd-icons)
(defface my/bookmark-margin
  '((t :inherit bookmark-face))
  "Face for the bookmark glyph in the left margin.")
(defvar my/bookmark-margin-icon
  (if (fboundp 'nerd-icons-mdicon)
      (nerd-icons-mdicon "nf-md-bookmark" :face 'my/bookmark-margin :height 0.85)
    "B")
  "Glyph marking bookmarked lines in the left margin.")

(defun my/bookmark--set-margin-mark ()
  "Mark the bookmarked line with `my/bookmark-margin-icon' in the left margin.
Overrides `bookmark--set-fringe-mark'; keeps the overlay `category' so
`bookmark--remove-fringe-mark' still finds and clears it."
  (when (display-graphic-p)
    ;; Margin must have width to show; flymake sets this in prog buffers, but a
    ;; bookmark may sit in a buffer without flymake -- carve out a column then.
    (when (zerop left-margin-width)
      (setq left-margin-width 1)
      (dolist (w (get-buffer-window-list nil nil t))
        (set-window-margins w left-margin-width right-margin-width)))
    (let ((bm (make-overlay (pos-bol) (1+ (pos-bol)))))
      (overlay-put bm 'category 'bookmark)
      (overlay-put bm 'evaporate t)
      (overlay-put bm 'before-string
                   (propertize " " 'display
                               `((margin left-margin) ,my/bookmark-margin-icon))))))
(advice-add 'bookmark--set-fringe-mark :override #'my/bookmark--set-margin-mark)

(provide 'javelin-rcp)
;;; javelin-rcp.el ends here
