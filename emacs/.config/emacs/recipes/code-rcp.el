;;; code-rcp.el --- eglot, apheleia, quickrun -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; LSP client (lsp-mode) lives in lsp-mode-rcp.el.

(use-package apheleia
  :init (apheleia-global-mode +1))

(use-package quickrun
  :commands (quickrun quickrun-region quickrun-shell quickrun-replace-region))

(use-package xref
  :ensure nil
  :custom
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (xref-search-program 'ripgrep)
  (xref-history-storage 'xref-window-local-history))

(provide 'code-rcp)
;;; code-rcp.el ends here
