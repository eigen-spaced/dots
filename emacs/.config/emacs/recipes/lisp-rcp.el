;;; lisp-rcp.el --- Common Lisp (SLY + SBCL) and structural editing -*- lexical-binding: t; -*-
;; SLY is the CL IDE (REPL/xref/completion/eldoc/debugger) -- CL does NOT use
;; eglot.  puni gives structural (paren-aware) editing across the whole Lisp
;; family.  aggressive-indent (format-rcp) already auto-indents lisp-mode, and
;; electric-pair + show-paren (base-rcp) stay on -- puni pairs via electric-pair
;; and only takes over deletion/killing/slurp-barf.
;;; Code:
(eval-when-compile (require 'use-package))

;;; SLY --------------------------------------------------------------
;; Talks to SBCL over a socket.  Defaults are good: C-c C-c compiles the defun,
;; C-c C-k the file, C-c C-z switches to the REPL, M-. / M-, jump, C-c C-d d
;; describes.  Companions load with SLY (sly-quicklisp adds `ql:quickload' with
;; completion; sly-asdf loads ASDF systems; sly-macrostep expands macros in place).
(use-package sly
  :commands (sly sly-connect)
  :hook (lisp-mode . sly-editing-mode)
  :custom
  (inferior-lisp-program "sbcl")
  ;; No version-skew nag: MELPA sly + Quicklisp's slynk track closely enough.
  (sly-mrepl-history-file-name
   (expand-file-name "sly-mrepl-history" user-emacs-directory))
  (sly-net-coding-system 'utf-8-unix)
  :config
  ;; The contribs actually loaded when a connection starts.
  (setq sly-contribs '(sly-fancy sly-mrepl sly-scratch)))

(use-package sly-quicklisp :after sly)   ; M-x sly-quickload  /  (ql:quickload …)
(use-package sly-asdf      :after sly)    ; M-x sly-asdf-load-system
(use-package sly-macrostep :after sly)   ; C-c M-e steps through a macroexpansion

;;; Structural editing (puni) ----------------------------------------
;; Balanced edits without a second modal layer.  puni-mode's own defaults make
;; deletion/killing balance-aware (C-d C-k C-w DEL won't strand a lone paren)
;; and add sexp motion (C-M-f/b/a/e); all are Ctrl-chords, so they fire in every
;; meow state.  But puni leaves slurp/barf/splice/raise/wrap UNBOUND -- we place
;; them on the paredit convention below, which doubles as the wiring for meow's
;; own `meow-forward-slurp' & co. (those just replay C-) C-( C-} C-{).
;;   C-)  C-(   slurp forward / backward     C-}  C-{   barf forward / backward
;;   M-(  wrap-round   M-r raise   M-s splice (splice shadows the search-map
;;   prefix, but only inside Lisp buffers).
(use-package puni
  :hook ((emacs-lisp-mode lisp-interaction-mode lisp-data-mode
          lisp-mode sly-mrepl-mode) . puni-mode)
  :bind (:map puni-mode-map
              ("C-)" . puni-slurp-forward)
              ("C-(" . puni-slurp-backward)
              ("C-}" . puni-barf-forward)
              ("C-{" . puni-barf-backward)
              ("M-(" . puni-wrap-round)
              ("M-r" . puni-raise)
              ("M-s" . puni-splice)))

(provide 'lisp-rcp)
;;; lisp-rcp.el ends here
