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
  (global-treesit-auto-mode)

  ;; `treesit-auto-install-all' only fetches *missing* grammars, so it can't fix a
  ;; grammar that's present but stale.
  (defun my/treesit-reinstall-grammars ()
    "Force-recompile every treesit-auto grammar (fixes ABI mismatch after upgrade)."
    (interactive)
    (let ((treesit-language-source-alist (treesit-auto--build-treesit-source-alist)))
      (cl-letf (((symbol-function 'y-or-n-p) (lambda (&rest _) t)))
        (dolist (lang (mapcar #'car treesit-language-source-alist))
          (message "treesit: reinstalling %s..." lang)
          (treesit-install-language-grammar lang))))))

(provide 'tree-sitter-rcp)
;;; tree-sitter-rcp.el ends here
