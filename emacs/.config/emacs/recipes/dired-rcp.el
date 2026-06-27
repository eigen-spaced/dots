;;; dired-rcp.el --- dired + subtree tree-expansion + dirvish -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))
(require 'cl-lib)

;; GNU ls (coreutils) — macOS BSD ls rejects our --group-directories-first /
;; --time-style flags, which makes every listing + preview retry (the scroll lag).
;; Absolute path so dirvish's preview subprocess finds it regardless of PATH.
(when-let* ((gls (executable-find "gls")))
  (setq insert-directory-program gls))

(defvar my/bat-program (executable-find "bat")
  "Path to bat, for colored dirvish previews without Emacs fontification.")

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom
  (dired-dwim-target t)
  (dired-auto-revert-buffer t)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'top)
  (dired-listing-switches "-AhlF --time-style=long-iso --group-directories-first")
  :bind (:map dired-mode-map
              ("C-c w" . dired-toggle-read-only)   ; wdired
              ("h" . dired-up-directory)
              ("-" . dired-up-directory)
              ("l" . dired-find-file)))

(use-package dired-subtree
  :after dired
  :custom (dired-subtree-use-backgrounds nil)
  :bind (:map dired-mode-map
              ("<tab>"     . dired-subtree-toggle)
              ("<backtab>" . dired-subtree-cycle)))

(defun my/dirvish-org ()
  "Open `org-directory' in Dirvish."
  (interactive) (dirvish org-directory))

(use-package dirvish
  :init (dirvish-override-dired-mode)
  :commands (dirvish dirvish-dwim my/dirvish-org)
  :custom
  ;; Doom/minibuffer look: nerd icon on the left, perms + size + mtime columns on
  ;; the right.  `nerd-icons' auto-loads dirvish-icons.
  (dirvish-attributes '(nerd-icons file-modes file-size file-time))
  (dirvish-reuse-session 'open)
  (dirvish-default-layout '(1 0.16 0.5))
  (dirvish-quick-access-entries
   '(("h" "~/"          "Home")
     ("o" "~/org/"      "Org")
     ("d" "~/dotfiles/" "Dotfiles")))
  :bind (:map dirvish-mode-map
              ("h" . dired-up-directory)
              ("-" . dired-up-directory)
              ("l" . dired-find-file))
  :config
  (setq dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))
  ;; `dirvish-pre-redisplay-h' fires for every window; with a daemon + multiple
  ;; frames that's a redisplay feedback loop (the scroll lag).  Limit it to the
  ;; selected window (from Doom).
  (defun my/dirvish-redisplay-selected-only (fn window)
    (when (eq (frame-selected-window) window)
      (funcall fn window)))
  (advice-add 'dirvish-pre-redisplay-h :around #'my/dirvish-redisplay-selected-only)

  ;; Fallback file previews as plain text — fontifying every file on each move
  ;; is the lag (used when bat is unavailable).
  (defun my/dirvish-preview-no-fontify (fn &rest args)
    (cl-letf (((symbol-function 'set-auto-mode) #'ignore)
              ((symbol-function 'font-lock-mode) #'ignore))
      (apply fn args)))
  (advice-add 'dirvish--preview-file-maybe-truncate
              :around #'my/dirvish-preview-no-fontify)

  ;; Colored file previews via bat: a fast subprocess emitting ANSI (dirvish
  ;; renders it), so no Emacs-side fontification blocks scrolling.
  (when my/bat-program
    (dirvish-define-preview my-bat (file ext)
      "Preview regular files with bat."
      (when (and (file-regular-p file)
                 (not (member ext dirvish-binary-exts)))
        `(shell . (,my/bat-program "--color=always" "--style=plain"
                   "--theme=pixel-miri16" "--paging=never" "--line-range" ":500" ,file))))
    (add-to-list 'dirvish-preview-dispatchers 'my-bat t)))

;; Colored dired listings + colored directory previews (the "highlighting").
(use-package diredfl
  :hook ((dired-mode . diredfl-mode)
         (dirvish-directory-view-mode . diredfl-mode)))

;; Project tree on the left.  dirvish's own side panel (not dired-sidebar) —
;; dired-sidebar's plain dired buffer gets hijacked by dirvish-override-dired-mode
;; into a session with no hash table, erroring its revert sentinel + follow timer.
(use-package dirvish-side
  :ensure nil
  :after dirvish
  :commands (dirvish-side)
  :custom
  (dirvish-side-width 35)
  (dirvish-side-attributes '(collapse))
  (dirvish-side-display-alist '((side . left) (slot . -1))))

;; meow state for dired/dirvish/wdired lives in `meow-mode-state-list' (meow-rcp).

(provide 'dired-rcp)
;;; dired-rcp.el ends here
