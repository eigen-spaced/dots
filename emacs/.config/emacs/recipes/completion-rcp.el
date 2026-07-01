;;; completion-rcp.el --- vertico, orderless, marginalia, consult, embark -*- lexical-binding: t; -*-

;;; Code:
(eval-when-compile (require 'use-package))

(use-package vertico
  :init (vertico-mode)
  :bind (:map vertico-map
              ("C-." . embark-act)))      ; act on the current candidate; C-n/C-p navigate

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
  ;; `C-c s' is the canonical search umbrella; `SPC s' points at this same keymap
  ;; (see meow-rcp), so the two menus are identical and survive a meow removal.
  :bind (("C-c s g" . consult-ripgrep)
         ("C-c s s" . consult-line)
         ("C-c s S" . consult-line-multi)
         ("C-c s i" . my/consult-imenu)
         ("C-c s o" . my/consult-imenu-scoped)
         ("C-c s O" . my/consult-imenu-scoped-at-point)
         ("C-c s m" . consult-mark)
         ("C-c s M" . my/clear-mark-ring)
         ("C-c s f" . isearch-forward)
         ("C-c s b" . isearch-backward))
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

;; C-c s i: by-kind view; C-u C-c s i: raw view with function-locals nested under
;; their scope (toggles the regrouping in eglot-rcp).
(defun my/consult-imenu (&optional full)
  "Jump to a buffer symbol via `consult-imenu'.
With prefix arg FULL, include function-local symbols."
  (interactive "P")
  (let ((my/eglot-imenu-no-regroup full))
    (consult-imenu)))

;; Scoped navigation: read eglot's raw (unregrouped) index so the locals filtered
;; out of the default view are reachable.  `C-c s o' picks from the by-kind view
;; then drills into that symbol's scope; `C-c s O' drills into the scope at point.
(defun my/imenu--raw-index ()
  "eglot's imenu index with its scope hierarchy intact (no by-kind regrouping)."
  (let ((my/eglot-imenu-no-regroup t))
    (funcall imenu-create-index-function)))

(defun my/imenu--node-at (items pos)
  "Find the node in raw imenu ITEMS whose region starts at POS."
  (catch 'hit
    (dolist (item items)
      (let ((reg (get-text-property 0 'imenu-region (car item))))
        (when (and reg (eql (car reg) pos)) (throw 'hit item)))
      (when (imenu--subalist-p item)
        (when-let* ((deeper (my/imenu--node-at (cdr item) pos)))
          (throw 'hit deeper))))
    nil))

(defun my/imenu--enclosing-scope (items pos)
  "Deepest Function/Method/Constructor node in ITEMS whose region holds POS."
  (let (best best-size)
    (cl-labels
        ((walk (items)
           (dolist (item items)
             (when (imenu--subalist-p item)
               (let* ((head (car item))
                      (kind (get-text-property 0 'imenu-kind head))
                      (reg (get-text-property 0 'imenu-region head)))
                 (when (and reg (member kind '("Function" "Method" "Constructor"))
                            (<= (car reg) pos) (<= pos (cdr reg)))
                   (let ((size (- (cdr reg) (car reg))))
                     (when (or (null best) (< size best-size))
                       (setq best item best-size size))))
                 (walk (cdr item)))))))
      (walk items))
    best))

(defun my/imenu--drill (node)
  "Pick and jump within NODE's children, grouped by kind like the top-level view."
  (require 'consult-imenu)
  (let* ((config (cdr (seq-find (lambda (x) (derived-mode-p (car x)))
                                consult-imenu-config)))
         (types (mapcar (pcase-lambda (`(,x ,y ,z)) (list y x z))
                        (plist-get config :types))))
    (consult-imenu--select
     (format "%s ▸ " (substring-no-properties (car node)))
     (consult-imenu--flatten nil nil
                             (my/eglot-imenu-by-kind (cdr node))
                             types))))

(defun my/consult-imenu-scoped ()
  "Pick a symbol from the by-kind view, then drill into its local scope.
Picking a childless symbol just jumps to it."
  (interactive)
  (require 'consult-imenu)
  (let (chosen)
    (cl-letf (((symbol-function 'consult-imenu--jump)
               (lambda (item) (setq chosen item))))
      (consult-imenu))
    (when chosen
      (let* ((pos (cdr chosen))
             (pos (and (markerp pos) (marker-position pos)))
             (node (and pos (my/imenu--node-at (my/imenu--raw-index) pos))))
        (if (and node (imenu--subalist-p node))
            (my/imenu--drill node)
          (consult-imenu--jump chosen))))))

(defun my/consult-imenu-scoped-at-point ()
  "Jump within the local scope of the function/method enclosing point."
  (interactive)
  (let ((node (my/imenu--enclosing-scope (my/imenu--raw-index) (point))))
    (if node
        (my/imenu--drill node)
      (user-error "Point is not inside a function or method"))))

;; consult-imenu narrow-key + face per LSP kind (pairs with the by-kind index in
;; eglot-rcp).  Deferred: `consult-imenu-config' is defined when consult-imenu loads.
(with-eval-after-load 'consult-imenu
  (let ((types '((?f "Function"      font-lock-function-name-face)
                 (?m "Method"        font-lock-function-name-face)
                 (?o "Constructor"   font-lock-function-name-face)
                 (?v "Variable"      font-lock-variable-name-face)
                 (?F "Field"         font-lock-variable-name-face)
                 (?p "Property"      font-lock-variable-name-face)
                 (?C "Constant"      font-lock-constant-face)
                 (?E "EnumMember"    font-lock-constant-face)
                 (?c "Class"         font-lock-type-face)
                 (?s "Struct"        font-lock-type-face)
                 (?i "Interface"     font-lock-type-face)
                 (?n "Namespace"     font-lock-type-face)
                 (?M "Module"        font-lock-type-face)
                 (?e "Enum"          font-lock-type-face)
                 (?t "TypeParameter" font-lock-type-face))))
    (dolist (mode '(c-ts-mode c++-ts-mode rust-ts-mode go-ts-mode
                              python-ts-mode python-mode js-ts-mode
                              typescript-ts-mode tsx-ts-mode))
      (add-to-list 'consult-imenu-config
                   `(,mode :toplevel "Function" :types ,types)))))

(use-package consult-dir
  :ensure t
  :commands (consult-dir consult-dir-jump-file)
  ;; C-j is vertico-next, so jump-file goes on C-M-d (bound in vertico-map).
  :bind (("C-c s d" . consult-dir)
         :map vertico-map
         ("C-d"   . consult-dir)
         ("C-M-d" . consult-dir-jump-file)))

;; Open an embark candidate in any window -- or a split you make on the spot via
;; ace-window's dispatch menu.  `C-.' (embark-act) then `o' hands the candidate to
;; ace-window.
(defvar aw-dispatch-always)
(defvar aw-dispatch-alist)
(defvar my/focus-width-inhibit)          ; defined in base-rcp

(defun my/aw-dispatch-hint ()
  "Echo ace-window's dispatch actions, stacked one per line, as a visible cue.
ace-window shows nothing on a single window, so this is the only prompt then."
  (message "%s"
           (mapconcat
            (lambda (a)
              (format " %s  %s"
                      (propertize (char-to-string (car a)) 'face 'aw-key-face)
                      (or (nth 2 a) (symbol-name (nth 1 a)))))
            aw-dispatch-alist "\n")))

(defun my/aw-split-dispatch ()
  "`aw-dispatch-alist' filtered to just the split actions.
For the embark open-in-window flow: window letters still pick an existing
window, but swap/move/copy/... don't apply when placing a fresh candidate."
  (seq-filter (lambda (a)
                (memq (nth 1 a)
                      '(aw-split-window-vert aw-split-window-horz aw-split-window-fair)))
              aw-dispatch-alist))

(eval-when-compile
  (defmacro my/embark-ace-action (fn)
    `(defun ,(intern (concat "my/embark-ace-" (symbol-name fn))) ()
       (interactive)
       (with-demoted-errors "%s"
         (require 'ace-window)
         (let ((aw-dispatch-always t)
               (aw-dispatch-alist (my/aw-split-dispatch)))   ; splits only in this flow
           (my/aw-dispatch-hint)         ; ace is silent on one window; show the menu
           (aw-switch-to-window (aw-select nil))
           (call-interactively (symbol-function ',fn)))))))

;; Show the embark action menu as a compact which-key popup instead of the
;; full-height *Embark Actions* buffer.  `?' (embark-help-key) still opens the
;; searchable, described action list on demand.  Adapted from embark's wiki.
(defun my/embark-which-key-indicator ()
  "An embark indicator that displays keymaps using which-key.
Shows the target's type and value, plus an ellipsis when more targets follow."
  (lambda (&optional keymap targets prefix)
    (if (null keymap)
        (which-key--hide-popup-ignore-command)
      (which-key--show-keymap
       (if (eq (plist-get (car targets) :type) 'embark-become)
           "Become"
         (format "Act on %s '%s'%s"
                 (plist-get (car targets) :type)
                 (embark--truncate-target (plist-get (car targets) :target))
                 (if (cdr targets) "…" "")))
       (if prefix
           (pcase (lookup-key keymap prefix 'accept-default)
             ((and (pred keymapp) km) km)
             (_ (key-binding prefix 'accept-default)))
         keymap)
       nil nil t
       (lambda (binding) (not (string-suffix-p "-argument" (cdr binding))))))))

(defun my/embark-hide-which-key-indicator (fn &rest args)
  "Hide the which-key popup while the `?' completing-read prompter runs."
  (which-key--hide-popup-ignore-command)
  (let ((embark-indicators (remq #'my/embark-which-key-indicator embark-indicators)))
    (apply fn args)))

(use-package embark
  :custom
  (embark-help-key "?")                  ; `?' opens the searchable, described list
  (embark-indicators '(my/embark-which-key-indicator
                       embark-highlight-indicator
                       embark-isearch-highlight-indicator))
  :config
  (advice-add #'embark-completing-read-prompter :around #'my/embark-hide-which-key-indicator)
  (keymap-set embark-file-map     "o" (my/embark-ace-action find-file))
  (keymap-set embark-buffer-map   "o" (my/embark-ace-action switch-to-buffer))
  (keymap-set embark-bookmark-map "o" (my/embark-ace-action bookmark-jump)))

(use-package embark-consult
  :after (embark consult))

(defun my/embark-split-opener (opener splitter)
  "Return a command that runs SPLITTER, selects the new window, then OPENER."
  (lambda ()
    (interactive)
    (select-window (funcall splitter))
    (call-interactively opener)))

(defun my/split-direction-action (direction)
  "PRE-FUNCTION for `display-buffer-override-next-command' that splits in DIRECTION."
  (lambda (buffer alist)
    (let ((alist (append `((direction . ,direction)
                           (inhibit-same-window . t))
                         alist)))
      (cons (display-buffer-in-direction buffer alist) 'window))))

(defun my/minibuffer-category ()
  (completion-metadata-get
   (completion-metadata (buffer-substring-no-properties
                         (minibuffer-prompt-end) (point))
                        minibuffer-completion-table
                        minibuffer-completion-predicate)
   'category))

(defun my/vertico-exit-in-direction (direction)
  (unless (eq (my/minibuffer-category) 'consult-location)
    ;; Hold off `my/focus-width-mode' until after the split+redisplay settle, else
    ;; it widens the new window off 50/50.  Balance the pair once they're displayed.
    (setq my/focus-width-inhibit t)
    (run-with-timer 0 nil (lambda () (setq my/focus-width-inhibit nil)))
    (display-buffer-override-next-command
     (my/split-direction-action direction)
     (lambda (_old new)
       (when (window-live-p new) (balance-windows (window-parent new))))
     "[split]"))
  (vertico-exit))

(defun my/vertico-exit-right () (interactive) (my/vertico-exit-in-direction 'right))
(defun my/vertico-exit-below () (interactive) (my/vertico-exit-in-direction 'below))

(with-eval-after-load 'vertico
  (keymap-set vertico-map "C-v" #'my/vertico-exit-right)
  (keymap-set vertico-map "C-s" #'my/vertico-exit-below))

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
