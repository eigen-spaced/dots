;;; markdown-rcp.el --- markdown editing -*- lexical-binding: t; -*-
;; Loaded after tree-sitter-rcp so these auto-mode entries beat any markdown-ts remap.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package markdown-mode
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :custom
  (markdown-fontify-code-blocks-natively t)
  (markdown-enable-math t)
  (markdown-header-scaling t)
  (markdown-hide-urls nil)
  :config
  (when (executable-find "pandoc")
    (setq markdown-command "pandoc")))

(provide 'markdown-rcp)
;;; markdown-rcp.el ends here
