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

(provide 'project-rcp)
;;; project-rcp.el ends here
