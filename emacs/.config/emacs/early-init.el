;;; early-init.el --- loaded before package system + first frame -*- lexical-binding: t; -*-
;;; Code:

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(setq native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings '(not docstrings obsolete))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      frame-resize-pixelwise t
      default-frame-alist '((fullscreen . maximized)
                            (font . "Cascadia Code NF-18")
                            (vertical-scroll-bars . nil)
                            (internal-border-width . 8)
                            (left-fringe . 8)
                            (right-fringe . 8)))

;; Right-Cmd = Hyper (left-Cmd stays super); frees H-1..H-9 for javelin.
(when (eq system-type 'darwin)
  (setq ns-right-command-modifier 'hyper))

;; lsp-mode uses plists (not hash tables) for server messages = less GC.  Read
;; at lsp's compile + load time, so it must be set before lsp is ever compiled.
(setenv "LSP_USE_PLISTS" "1")

(setq package-enable-at-startup t
      package-native-compile t)

;; Precompute every package's autoloads into one concatenated file so
;; `package-initialize' doesn't walk all of elpa/ at startup.  Regenerate with
;; `M-x package-quickstart-refresh' after installing/removing packages.
(setq package-quickstart t)

;;; early-init.el ends here
