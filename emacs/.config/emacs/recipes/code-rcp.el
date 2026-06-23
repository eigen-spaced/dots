;;; code-rcp.el --- apheleia, aggressive-indent, quickrun -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package apheleia
  :init (apheleia-global-mode +1))

;; Keep code correctly indented as you type / edit.  Global, minus modes where
;; it misbehaves — indentation-sensitive (python/yaml) or formatter-owned (go);
;; aggressive-indent's stock exclude list predates the tree-sitter variants.
;; Opt-in for Lisp only — where Emacs's own indentation is the canonical style
;; and there's no external formatter.  Everywhere else electric-indent (live) +
;; apheleia (format on save) own indentation; aggressive-indent has no concept
;; of .clang-format/prettier/etc. and would just fight them.
(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-interaction-mode lisp-mode scheme-mode)
         . aggressive-indent-mode))

;; Match clang-format's typical IndentWidth for live typing in c/c++ (both ts
;; modes share this); clang-format still has the final say on save.
(setq c-ts-mode-indent-offset 4)

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
