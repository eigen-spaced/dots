;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Saneyar"
      user-mail-address "saneyar.k@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))
(setq doom-font (font-spec :family "JetBrains Mono" :size 16)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 18))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-moonlight)
;; (setq doom-theme 'doom-outrun-electric)

;; Maximize window on startup
(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;;; :lang org
;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/"
      org-agenda-files '("~/org/todos.org"))

(after! org
  (setq org-agenda-start-with-log-mode t
        org-log-done 'time
        org-log-into-drawer 't
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d!)" "CANCELLED(c@)"))))

(after! org
  (setq org-startup-folded 'overview
        org-ellipsis " [...] " ))

;; Keybindings for commonly-accessed files
;; Helper function
;; Could help with some clean-up??
(defun mc/add-file-keybinding (key file &optional desc)
  (let ((key key)
        (file file)
        (desc desc))
    (map! :desc (or desc file)
          key
          (lambda () (interactive) (find-file file)))))

(mc/add-file-keybinding "C-c f t" "~/org/todos.org" "todos.org")

;; Setup refile targets
;; targets include the current file and all agenda files
(setq org-refile-allow-creating-parent-nodes 'confirm)
(setq org-refile-targets '((nil :maxlevel . 9)
                           (org-agenda-files :maxlevel . 9)))
;; Save org files after refiling
(advice-add 'org-refile :after 'org-save-all-org-buffers)

(after! evil-surround
  ;; Add evil-surround support for common markup symbols
  (dolist (pair '((?$ . ("$" . "$")) (?= . ("=" . "=")) (?~ . ("~" . "~"))
                  (?/ . ("/" . "/")) (?* . ("*" . "*")) (?* . (":" . ":"))))
    (push pair evil-surround-pairs-alist)))


;; Add padding to org buffer
(defun mc/org-mode-visual-fill ()
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t
        display-fill-column-indicator nil
        display-line-numbers nil)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . mc/org-mode-visual-fill))

(use-package mixed-pitch
  :custom (mixed-pitch-set-height t)
  :hook (text-mode . mixed-pitch-mode))

;; company unfortunately does not work for el files :(
(after! company
  (setq company-idle-delay 0.5
        company-minimum-prefix-length 3)
  (add-hook 'evil-normal-state-entry-hook #'company-abort)) ;; make aborting less annoying.

;; Increase the size of various headings
(after! org
  (custom-set-faces!
    '(org-document-title :height 1.3)
    '(org-level-1 :inherit outline-1 :weight bold :height 1.4)
    '(org-level-2 :inherit outline-2 :weight bold :height 1.15)
    '(org-level-3 :inherit outline-3 :weight bold :height 1.12)
    '(org-level-4 :inherit outline-4 :weight bold :height 1.09)
    '(org-level-5 :inherit outline-5 :weight semi-bold :height 1.06)
    '(org-level-6 :inherit outline-6 :weight semi-bold :height 1.03)
    '(org-level-7 :inherit outline-7 :weight semi-bold)
    '(org-level-8 :inherit outline-8 :weight semi-bold)
    ;; Ensure that anything that should be fixed-pitch in org buffers appears that
    ;; way
    '(org-block nil :foreground nil :inherit 'fixed-pitch)
    '(org-code nil   :inherit '(shadow fixed-pitch))
    '(org-table nil   :inherit '(shadow fixed-pitch))
    '(org-verbatim nil :inherit '(shadow fixed-pitch))
    '(org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
    '(org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
    '(org-checkbox nil :inherit 'fixed-pitch)))

(use-package! org-superstar
  :config
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
  (setq org-superstar-headline-bullets-list '("◉" "⁑" "⁂" "❖" "✿" "✱" "✸")))

(after! ispell
  (setq ispell-dictionary "en_AU"))

(setq haskell-process-path-ghci "stack"
      haskell-process-type 'stack-ghci)

;; Custom keybindings
(map! "C-h" #'evil-window-left
      "C-j" #'evil-window-down
      "C-k" #'evil-window-up
      "C-l" #'evil-window-right)


;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; Meaner banner for the startpage
(setq +doom-dashboard-banner-file (expand-file-name "banner.png" doom-private-dir))

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
      evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
      auto-save-default t                         ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space

(display-time-mode 1)                             ; Enable time in the mode-line

(if (equal "Battery status not available"
           (battery))
    (display-battery-mode 1)                        ; On laptops it's nice to know how much power you have
  (setq password-cache-expiry nil))               ; I can trust my desktops ... can't I? (no battery = desktop)

(global-subword-mode 1)                           ; Iterate through CamelCase words

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
