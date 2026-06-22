;;; tree-sitter-rcp.el --- tree-sitter highlighting via treesit-auto -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package treesit
  :ensure nil
  :custom
  (treesit-font-lock-level 4))

(use-package treesit-auto
  :custom
  (treesit-auto-install t)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(provide 'tree-sitter-rcp)
;;; tree-sitter-rcp.el ends here
