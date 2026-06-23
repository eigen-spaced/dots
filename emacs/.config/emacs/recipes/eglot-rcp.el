;;; eglot-rcp.el --- eglot LSP client + flymake + eldoc -*- lexical-binding: t; -*-
;; Completion (corfu/cape), diagnostics (flymake), definition/references (xref),
;; rename (eglot-rename), hover (eldoc + eldoc-box).  Replaced lsp-mode.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package eglot
  :ensure nil                           ; built-in (Emacs 29+)
  :commands (eglot eglot-ensure)
  :hook ((c-ts-mode c++-ts-mode go-ts-mode
                    python-ts-mode python-mode
                    js-ts-mode typescript-ts-mode tsx-ts-mode
                    css-ts-mode bash-ts-mode sh-mode rust-ts-mode) . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format-buffer))
  :custom
  (eglot-autoshutdown t)                ; stop the server when its last buffer dies
  (eglot-extend-to-xref t)              ; xref into out-of-project files the server knows
  (eglot-events-buffer-config '(:size 0 :format full)) ; no events log buffer
  :config
  ;; pyrefly is the Python server — `uv tool install pyrefly'.
  (add-to-list 'eglot-server-programs
               '((python-ts-mode python-mode) . ("pyrefly" "lsp")))
  ;; clangd: --completion-style=detailed lists each overload separately (like
  ;; Neovim) instead of bundling them as "name(…) [N overloads]".
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode c-mode c++-mode)
                 . ("clangd" "--completion-style=detailed")))
  ;; Let orderless drive eglot completion (eglot otherwise forces `flex').
  (add-to-list 'completion-category-overrides '(eglot (styles orderless)))
  (add-to-list 'completion-category-overrides '(eglot-capf (styles orderless))))

;; Dim the completion annotation (return type / kind, e.g. "reference").  eglot
;; hard-codes it to the bright `font-lock-function-name-face'; re-face it to
;; `completions-annotations' (a secondary/shadow face) so the candidate name
;; reads more prominently.  Done at the capf since corfu leaves already-faced
;; suffixes untouched.
(defun my/eglot-dim-completion-annotations (capf)
  (when (consp capf)
    (when-let* ((tail (nthcdr 3 capf))
                (orig (plist-get tail :annotation-function)))
      (plist-put tail :annotation-function
                 (lambda (proxy)
                   (when-let* ((s (funcall orig proxy)))
                     (propertize (substring-no-properties s)
                                 'face 'completions-annotations))))))
  capf)
(advice-add 'eglot-completion-at-point :filter-return
            #'my/eglot-dim-completion-annotations)

;; Docs-at-point on demand: `?' ("what is this?") pops an eldoc-box childframe
;; with the eglot hover (or eldoc for any mode) that vanishes on the next
;; command — the lsp-ui-doc-glance replacement.  Bound to `?' in meow-rcp.el.
(use-package eldoc-box
  :commands (eldoc-box-help-at-point))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  (eldoc-echo-area-use-multiline-p t))

;; Diagnostics via flymake; `flymake-eldoc-function' (Emacs 30) streams the
;; error at point into the echo area, composed with eglot's hover via eldoc.
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind ("C-c s e" . consult-flymake)
  :custom
  (flymake-fringe-indicator-position 'left-fringe)
  (flymake-no-changes-timeout 0.5))

;; Workspace symbol search (replaces consult-lsp); file symbols stay on
;; consult-imenu (C-c s i, completion-rcp).
(use-package consult-eglot
  :after (consult eglot)
  :bind ("C-c s ." . consult-eglot-symbols))

;; Eglot's stderr buffer is space-prefixed (already hidden); the events buffer
;; is disabled above.  Hide any stray *EGLOT …* buffer from the switchers too.
;; Reach them on demand with M-x eglot-events-buffer / eglot-stderr-buffer.
(defvar my/eglot-hidden-buffer-rx "\\`\\*EGLOT "
  "Regexp for eglot helper buffers to keep out of buffer switchers.")
(with-eval-after-load 'consult
  (add-to-list 'consult-buffer-filter my/eglot-hidden-buffer-rx))
(with-eval-after-load 'perspective
  (require 'ido)                        ; ido-ignore-buffers lives in ido.el
  (add-to-list 'ido-ignore-buffers my/eglot-hidden-buffer-rx))

(provide 'eglot-rcp)
;;; eglot-rcp.el ends here
