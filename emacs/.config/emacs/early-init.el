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
      frame-inhibit-implied-resize t   ; skip the font-driven frame resize (~0.4-1s, every frame)
      default-frame-alist '((fullscreen . maximized)
                            (font . "Cascadia Code NF-18")
                            (vertical-scroll-bars . nil)
                            (internal-border-width . 8)
                            (left-fringe . 8)
                            (right-fringe . 8)))

;; Right-side modifiers, two-handed by design (left hand on the number/letter,
;; right hand on the modifier):
;;   right-Cmd    = Hyper -> H-<n> workspaces, H-x M-x
;;   right-Option = Alt   -> A-<n> javelin   (was a redundant Meta; left-Option
;;                                            stays Meta, left-Cmd stays super)
(when (eq system-type 'darwin)
  (setq ns-right-command-modifier 'hyper
        ns-right-option-modifier 'alt))

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
