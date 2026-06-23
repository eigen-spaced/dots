;;; completion-rcp.el --- vertico, orderless, marginalia, consult, embark -*- lexical-binding: t; -*-

;;; Code:
(eval-when-compile (require 'use-package))

(use-package vertico
  :init (vertico-mode)
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)))

;; `~/' or `//' resets the path instead of appending (vertico-directory-tidy).
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map
              ("RET"   . vertico-directory-enter)
              ("DEL"   . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult
  ;; C-c binds so these annotate in M-x; the SPC leader isn't where-is-discoverable.
  :bind (("C-c s g" . consult-ripgrep)
         ("C-c s s" . consult-line)
         ("C-c s i" . consult-imenu))
  :custom
  (consult-ripgrep-args
   (concat "rg --null --line-buffered --color=never --max-columns=1000 "
           "--path-separator / --smart-case --no-heading --with-filename "
           "--line-number --search-zip "
           "--glob=!{.git,node_modules,elpa,eln-cache,build,dist,target,.cache,.venv,__pycache__,vendor}"))
  (consult-project-function
   (lambda (_)
     (or (and (fboundp 'projectile-project-root) (projectile-project-root))
         (when-let* ((p (project-current))) (project-root p)))))
  :config
  (consult-customize
   consult-ripgrep consult-grep consult-git-grep
   consult-eglot-symbols
   :preview-key nil)
  (consult-customize
   consult-fd consult-find consult-recent-file
   :preview-key '(:debounce 0.4 any)))

(use-package consult-dir
  :ensure t
  :commands (consult-dir consult-dir-jump-file)
  ;; C-j is vertico-next, so jump-file goes on C-M-d (bound in vertico-map).
  :bind (("C-c s d" . consult-dir)
         :map vertico-map
         ("C-d"   . consult-dir)
         ("C-M-d" . consult-dir-jump-file)))

(use-package embark)

(use-package embark-consult
  :after (embark consult))

(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.15)
  (corfu-cycle t)
  (corfu-preselect 'prompt)              ; no candidate selected until you navigate
  (corfu-quit-no-match 'separator)
  :bind (:map corfu-map
              ("TAB"     . corfu-next)
              ([tab]     . corfu-next)
              ("S-TAB"   . corfu-previous)
              ([backtab] . corfu-previous)
              ("C-j"     . corfu-next)
              ("C-k"     . corfu-previous)))

(use-package nerd-icons-corfu
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Dimming the eglot annotation lives in eglot-rcp.el — eglot hard-codes it to
;; font-lock-function-name-face, so it must be re-faced at the capf, not here.

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(provide 'completion-rcp)
;;; completion-rcp.el ends here
