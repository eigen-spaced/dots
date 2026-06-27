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

(provide 'javelin-rcp)
;;; javelin-rcp.el ends here
