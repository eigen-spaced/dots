;;; python-rcp.el --- Python: per-project virtualenv activation -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;;; Virtualenv ------------------------------------------------------
;; Emacs has no shell to `source activate' into; instead we expose the venv's
;; bin/ to the subprocesses Emacs spawns (LSP server, formatters) by setting
;; PATH/VIRTUAL_ENV/exec-path *buffer-locally* — the daemon is one long-lived
;; process, so a global activation would leak one project's venv everywhere.
;; On first open of a Python buffer we offer (y/n) to activate a project venv;
;; the choice is remembered per project root for the session.

(defvar my/python-venv-decisions nil
  "Alist of project root -> venv path (activated) or the symbol `declined'.")

(defun my/python--project-root ()
  (or (when-let ((p (project-current))) (project-root p))
      default-directory))

(defun my/python--find-venv (root)
  "Return a venv directory under ROOT, or nil.
Detected by `pyvenv.cfg' — the canonical marker every venv tool writes (uv,
python -m venv, virtualenv, …) — so this is independent of which tool, if
any, manages the interpreter."
  (seq-find (lambda (dir)
              (file-exists-p (expand-file-name "pyvenv.cfg" dir)))
            (mapcar (lambda (name) (expand-file-name name root))
                    '(".venv" "venv" "env" ".env"))))

(defun my/python--venv-usable-p (venv)
  "Non-nil if VENV's bin/python resolves to a real executable.
A venv built against a manager's interpreter (mise/pyenv) goes dangling when
that version is removed; `file-executable-p' follows the symlink and fails."
  (file-executable-p (expand-file-name "bin/python" venv)))

(defun my/python-activate-venv (venv)
  "Activate VENV buffer-locally so this buffer's LSP/formatters use it."
  (let* ((venv (directory-file-name (expand-file-name venv)))
         (bin  (expand-file-name "bin" venv)))
    (setq-local process-environment (copy-sequence process-environment))
    (setenv "VIRTUAL_ENV" venv)
    (setenv "PATH" (concat bin path-separator (getenv "PATH")))
    (setq-local exec-path (cons bin exec-path))
    (setq-local python-shell-virtualenv-root venv)))

(defun my/python-maybe-activate-venv ()
  "Offer to activate a project venv on first open; reuse the decision after.
Runs on `python-base-mode-hook', before `eglot-ensure', so the server starts
with the venv on PATH."
  (unless (or (getenv "VIRTUAL_ENV") python-shell-virtualenv-root)
    (let* ((root    (my/python--project-root))
           (decided (assoc root my/python-venv-decisions)))
      (cond
       ((and decided (stringp (cdr decided)))   ; activated before — reuse silently
        (my/python-activate-venv (cdr decided)))
       (decided nil)                            ; declined before — stay quiet
       (t
        (when-let ((venv (my/python--find-venv root)))
          (cond
           ;; Healthy venv — offer to activate.
           ((my/python--venv-usable-p venv)
            (if (y-or-n-p (format "Activate venv %s? " (file-relative-name venv root)))
                (progn
                  (push (cons root venv) my/python-venv-decisions)
                  (my/python-activate-venv venv)
                  (message "Activated venv %s" (abbreviate-file-name venv)))
              (push (cons root 'declined) my/python-venv-decisions)))
           ;; Dangling interpreter — warn once instead of skipping silently.
           (t
            (push (cons root 'declined) my/python-venv-decisions)
            (message "venv %s has a dangling interpreter — recreate it: rm -rf %s && python -m venv --copies %s"
                     (file-relative-name venv root)
                     (file-relative-name venv root)
                     (file-relative-name venv root))))))))))

(add-hook 'python-base-mode-hook #'my/python-maybe-activate-venv)

(provide 'python-rcp)
;;; python-rcp.el ends here
