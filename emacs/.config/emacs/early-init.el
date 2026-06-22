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
                            (font . "Cascadia Code NF-17")
                            (vertical-scroll-bars . nil)
                            (internal-border-width . 8)
                            (left-fringe . 8)
                            (right-fringe . 8)))

;; Right-Cmd = Hyper (left-Cmd stays super); frees H-1..H-9 for javelin.
(when (eq system-type 'darwin)
  (setq ns-right-command-modifier 'hyper))

(setq package-enable-at-startup t
      package-native-compile t)

;;; early-init.el ends here
