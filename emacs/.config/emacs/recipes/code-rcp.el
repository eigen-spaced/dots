;;; code-rcp.el --- quickrun, xref -*- lexical-binding: t; -*-
;; Formatting (apheleia, aggressive-indent, formatter templates) lives in
;; format-rcp.el.
;;; Code:
(eval-when-compile (require 'use-package))

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
