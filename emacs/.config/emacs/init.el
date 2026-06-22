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

(add-to-list 'load-path (expand-file-name "recipes" user-emacs-directory))

;; Machine-local, git-ignored identity (user-full-name / user-mail-address).
;; See private.el.example; create ~/.config/emacs/private.el.
(load (expand-file-name "private.el" user-emacs-directory) t t)

(require 'base-rcp)
(require 'ui-rcp)
(require 'completion-rcp)
(require 'project-rcp)
(require 'workspace-rcp)
(require 'vcs-rcp)
(require 'code-rcp)
(require 'lsp-mode-rcp)
(require 'tree-sitter-rcp)
(require 'editing-rcp)
(require 'eww-rcp)
(require 'org-rcp)
(require 'markdown-rcp)
(require 'notmuch-rcp)
(require 'dired-rcp)
(require 'dashboard-rcp)
(require 'meow-rcp)

;; GC is managed by gcmh (base-rcp), which restores a sane threshold and defers
;; collection to idle.  early-init keeps it maxed during startup.

;;; init.el ends here
