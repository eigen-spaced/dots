;;; project-rcp.el --- projectile + project.el -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package project :ensure nil)

(use-package projectile
  :custom
  (projectile-project-search-path '("~/dotfiles"))
  (projectile-completion-system 'default)
  :init (projectile-mode +1))

;; Robust project file finder.  `projectile-find-file' expands the picked
;; (root-relative) candidate with `expand-file-name', which silently falls back
;; to the buffer's `default-directory' if the root ever drifts — opening a
;; doubled path like ".../src/audioui/src/audioui/gl.h" that "does not exist".
;; Binding `default-directory' to the resolved root makes expansion exact.
(defun my/project-find-file ()
  "Find a file in the current project, resolving paths against its root."
  (interactive)
  (require 'projectile)
  (let* ((root (projectile-acquire-root))
         (default-directory root)
         (file (projectile-completing-read
                "Find file: " (projectile-project-files root)
                :caller 'projectile-read-file)))
    (when file
      (find-file (expand-file-name file root)))))

;; Harpoon-style buffer pinning, scoped per project + git branch.  Default keys
;; are M-1..9 (= digit-argument); move them to H-<n> (right-Cmd, see early-init).
(use-package javelin
  :config
  (global-javelin-minor-mode 1)
  (let ((m javelin-minor-mode-map))
    (dotimes (i 9)
      (let ((n (1+ i)))
        (define-key m (kbd (format "H-%d" n))
                    (intern (format "javelin-go-or-assign-to-%d" n)))
        (define-key m (kbd (format "M-%d" n)) nil)))
    (define-key m (kbd "H-0") (lookup-key m (kbd "M-0")))   ; delete sub-map
    (define-key m (kbd "M-0") nil)
    (define-key m (kbd "H--") #'javelin-toggle-quick-menu)
    (define-key m (kbd "M--") nil)))

(provide 'project-rcp)
;;; project-rcp.el ends here
