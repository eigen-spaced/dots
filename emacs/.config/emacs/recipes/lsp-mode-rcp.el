;;; lsp-mode-rcp.el --- LSP client (lsp-mode + lsp-ui) -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(defun my/lsp-rust-setup ()
  "rust-analyzer with inlay hints, no semantic tokens, then start LSP."
  (setq-local lsp-rust-analyzer-server-display-inlay-hints t
              lsp-semantic-tokens-enable nil)
  (lsp-deferred))

(use-package lsp-mode
  :defer t
  :commands (lsp lsp-deferred)
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-completion-provider :none)
  (lsp-diagnostics-provider :flycheck)
  (lsp-idle-delay 1.0)
  (lsp-log-io nil)
  (lsp-enable-file-watchers nil)
  (lsp-file-watch-threshold 1000)
  (lsp-lens-enable nil)
  (lsp-rust-analyzer-lens-enable nil)
  (lsp-inlay-hint-enable nil)
  (lsp-enable-symbol-highlighting nil)
  (lsp-enable-on-type-formatting nil)
  (lsp-enable-snippet nil)
  (lsp-enable-folding nil)
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-modeline-code-actions-enable nil)
  (lsp-semantic-tokens-enable t)
  (read-process-output-max (* 1024 1024))
  :bind (:map lsp-mode-map
         ([remap xref-find-definitions] . lsp-find-definition)
         ([remap xref-find-references]  . lsp-find-references))
  :hook ((c-ts-mode          . lsp-deferred)
         (c++-ts-mode        . lsp-deferred)
         (go-ts-mode         . lsp-deferred)
         (python-ts-mode     . lsp-deferred)
         (python-mode        . lsp-deferred)
         (js-ts-mode         . lsp-deferred)
         (typescript-ts-mode . lsp-deferred)
         (tsx-ts-mode        . lsp-deferred)
         (css-ts-mode        . lsp-deferred)
         (bash-ts-mode       . lsp-deferred)
         (sh-mode            . lsp-deferred)
         (rust-ts-mode       . my/lsp-rust-setup)
         (lsp-mode           . lsp-enable-which-key-integration))
  :config
  (fset #'jsonrpc--log-event #'ignore)

  ;; pyrefly: `uv tool install pyrefly' — no built-in client, register one.
  (dolist (client '(pyright pyls mspyls ty-ls))
    (add-to-list 'lsp-disabled-clients client))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("pyrefly" "lsp"))
    :activation-fn (lsp-activate-on "python")
    :priority 2
    :server-id 'pyrefly))

  ;; rust-analyzer spams harmless "content modified" errors.
  (defun my/lsp-ignore-rust-analyzer-content-modified (orig-fn &rest args)
    (let ((msg (format "%S" args)))
      (unless (string-match-p "content modified" msg)
        (apply orig-fn args))))
  (advice-add 'lsp--error :around #'my/lsp-ignore-rust-analyzer-content-modified))

(use-package lsp-ui
  :commands (lsp-ui-mode)
  :custom
  (lsp-ui-sideline-enable nil)
  (lsp-ui-doc-enable nil)
  (lsp-ui-peek-enable t))

(use-package consult-lsp
  :after (consult lsp-mode)
  :bind (("C-c s ," . consult-lsp-file-symbols)
         ("C-c s ." . consult-lsp-symbols)
         ("C-c s D" . consult-lsp-diagnostics)))

(defun my/flycheck-eldoc (callback &rest _)
  "Feed flycheck errors at point to eldoc so they compose with LSP hover."
  (when-let ((errors (flycheck-overlay-errors-at (point))))
    (funcall callback
             (mapconcat
              (lambda (err)
                (propertize (flycheck-error-format-message-and-id err)
                            'face (flycheck-error-level-error-list-face
                                   (flycheck-error-level err))))
              errors "\n"))
    t))

(defun my/flycheck-setup-eldoc ()
  (add-hook 'eldoc-documentation-functions #'my/flycheck-eldoc nil t))

;; load-path 'inherit + initialize-packages stop false "<fn> not known to be
;; defined" warnings when linting our symlinked elisp config.
(use-package flycheck
  :hook ((prog-mode . flycheck-mode)
         (flycheck-mode . my/flycheck-setup-eldoc))
  :custom
  (flycheck-emacs-lisp-load-path 'inherit)
  (flycheck-emacs-lisp-initialize-packages t)
  (flycheck-indication-mode 'left-fringe)
  (flycheck-display-errors-function #'ignore)
  (flycheck-check-syntax-automatically '(save idle-change mode-enabled)))

(use-package eldoc
  :ensure nil
  :custom
  (eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  (eldoc-echo-area-use-multiline-p t))

(use-package consult-flycheck
  :after (consult flycheck)
  :bind ("C-c s e" . consult-flycheck))

(provide 'lsp-mode-rcp)
;;; lsp-mode-rcp.el ends here
