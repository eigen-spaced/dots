;;; workspace-rcp.el --- perspective.el workspaces (Doom-style) -*- lexical-binding: t; -*-
;; Project-agnostic, buffer-isolated workspaces; s-1..s-9 switch by position.
;;; Code:
(eval-when-compile (require 'use-package))

(defun my/persp-switch-by-index (index)
  "Switch to the INDEX-th workspace (1-based) in creation order.
`persp-sort' is \\='created (newest first), so reverse for a stable
oldest-first ordering: s-1 is the first workspace, new ones append."
  (let ((name (nth (1- index) (reverse (persp-names)))))
    (when name (persp-switch name))))

(use-package perspective
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  (persp-state-default-file (expand-file-name "persp-state" user-emacs-directory))
  (persp-suppress-no-prefix-key-warning t)
  (persp-sort 'created)                  ; s-N -> Nth workspace by creation order
  :init
  (persp-mode)
  :config
  (add-hook 'kill-emacs-hook #'persp-state-save)
  (dotimes (i 9)
    (define-key global-map (kbd (format "s-%d" (1+ i)))
                (let ((n (1+ i))) (lambda () (interactive) (my/persp-switch-by-index n))))))

(provide 'workspace-rcp)
;;; workspace-rcp.el ends here
