;;; init.el --- vanilla Emacs, meow-driven -*- lexical-binding: t; -*-
;;
;; Test without disturbing Doom:  emacs --init-directory=~/.config/emacs
;; Config lives in recipes/*-rcp.el; meow-rcp loads last (keybinding collector).
;;
;;; Code:

(require 'package)
(setq package-archives '(("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(require 'cl-lib)
(setq use-package-always-ensure t)

;; Opt-in startup profiler: launch with `EMACS_BENCH=1 emacs ...' to instrument
;; package loads with benchmark-init and write a sorted report to
;; benchmark-init.txt at after-init (also live via M-x
;; benchmark-init/show-durations-tree).  Note: it times *file loads* only, not
;; function calls like `exec-path-from-shell-initialize'.
(when (getenv "EMACS_BENCH")
  (require 'benchmark-init)
  (benchmark-init/activate)
  (add-hook 'after-init-hook
            (lambda ()
              (benchmark-init/deactivate)
              (ignore-errors
                (with-temp-file (expand-file-name "benchmark-init.txt" user-emacs-directory)
                  (insert (format "emacs-init-time: %s\n\n%-34s %9s %9s\n" (emacs-init-time)
                                  "file/package" "self-ms" "total-ms"))
                  (let ((rows (delq nil
                               (mapcar
                                (lambda (e)
                                  (let ((name (alist-get :name e)) (self (alist-get :duration-adj e)))
                                    (when (and name (not (eq name 'benchmark-init/root)) (numberp self))
                                      (list name self (alist-get :duration e)))))
                                (benchmark-init/flatten benchmark-init/durations-tree)))))
                    (dolist (r (sort rows (lambda (a b) (> (nth 1 a) (nth 1 b)))))
                      (insert (format "%-34s %9.1f %9.1f\n" (nth 0 r) (nth 1 r) (nth 2 r))))))))
            t))

(add-to-list 'load-path (expand-file-name "recipes" user-emacs-directory))

;; Machine-local, git-ignored identity (user-full-name / user-mail-address).
;; See private.el.example; create ~/.config/emacs/private.el.
(load (expand-file-name "private.el" user-emacs-directory) t t)

(require 'base-rcp)
(require 'ui-rcp)
(require 'completion-rcp)
(require 'project-rcp)
(require 'javelin-rcp)
(require 'modeline-rcp)
(require 'workspace-rcp)
(require 'ace-window-rcp)
(require 'dimmer-rcp)
(require 'vcs-rcp)
(require 'code-rcp)
(require 'eglot-rcp)
(require 'python-rcp)
(require 'tree-sitter-rcp)
(require 'editing-rcp)
(require 'eww-rcp)
(require 'org-rcp)
(require 'markdown-rcp)
(require 'notmuch-rcp)
(require 'dired-rcp)
(require 'term-rcp)
(require 'agent-shell-rcp)
(require 'dashboard-rcp)
(require 'meow-rcp)

;; GC is managed by gcmh (base-rcp), which restores a sane threshold and defers
;; collection to idle.  early-init keeps it maxed during startup.

;;; init.el ends here
