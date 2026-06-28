;;; jinx-rcp.el --- just-in-time spell checking -*- lexical-binding: t; -*-
;; Enchant-backed checker (compiles a C shim on first load via libenchant +
;; pkg-config, both from brew).  org/markdown/message inherit the text-mode hook.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package jinx
  :hook (text-mode . jinx-mode)
  :bind (("C-;"   . jinx-correct)
         ("C-M-;" . jinx-languages)))

(provide 'jinx-rcp)
;;; jinx-rcp.el ends here
