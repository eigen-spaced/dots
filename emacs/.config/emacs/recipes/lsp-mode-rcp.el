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
  (advice-add 'lsp--error :around #'my/lsp-ignore-rust-analyzer-content-modified)

  ;; Cap clangd indexing at half the cores so big C++ projects don't peg the CPU.
  (with-eval-after-load 'lsp-clangd
    (add-to-list 'lsp-clients-clangd-args
                 (format "-j=%d" (max 1 (/ (num-processors) 2))))))

(use-package lsp-ui
  :commands (lsp-ui-mode)
  :custom
  (lsp-ui-sideline-enable nil)
  (lsp-ui-doc-enable nil)
  (lsp-ui-peek-enable t))

(defun my/consult-lsp-symbols-project-transformer (workspace symbol-info)
  "Transform SYMBOL-INFO like the default, but drop symbols outside WORKSPACE root.
Filters out indexed std-library / SDK headers (e.g. CommandLineTools)."
  (let ((file (ignore-errors
                (lsp--uri-to-path
                 (lsp:location-uri (lsp:symbol-information-location symbol-info)))))
        (root (lsp--workspace-root workspace)))
    (when (and file root
               (string-prefix-p (file-name-as-directory (expand-file-name root))
                                (expand-file-name file)))
      (consult-lsp--symbols--transformer workspace symbol-info))))

(defun my/consult-lsp--drop-nil-candidates (cands)
  "Drop nil entries the project filter leaves in CANDS."
  (delq nil cands))

(use-package consult-lsp
  :after (consult lsp-mode)
  :bind (("C-c s ," . consult-lsp-file-symbols)
         ("C-c s ." . consult-lsp-symbols)
         ("C-c s D" . consult-lsp-diagnostics))
  :config
  (setq consult-lsp-symbols-transformer-function
        #'my/consult-lsp-symbols-project-transformer)
  (advice-add 'consult-lsp--symbols--make-transformer :filter-return
              #'my/consult-lsp--drop-nil-candidates))

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
