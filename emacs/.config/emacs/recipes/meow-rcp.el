;;; meow-rcp.el --- meow modal editing + SPC leader (loads last) -*- lexical-binding: t; -*-
;;
;; The SPC leader is meow's KEYPAD: SPC means "hold a modifier for me".
;;   c -> C-c   x -> C-x   m -> M-   g -> C-M-   (the four reserved letters)
;; Because c/x/m/g are taken, three things sit off their Doom spot:
;;   code -> SPC k    raw C-c -> SPC c    git -> SPC v
;;

(eval-when-compile (require 'cl-lib))
(require 'cl-lib)

(defvar my/leader-map (make-sparse-keymap) "SPC leader keymap (fed to meow keypad).")

;;; Editing-command helpers ------------------------------------------

(defun my/meow-escape ()
  "Cancel a selection, else quit (vanilla `keyboard-quit')."
  (interactive)
  (if (region-active-p) (meow-cancel-selection) (keyboard-quit)))

(defun my/meow-replace-char ()
  "Vim `r': replace the char at point with the next key; ESC or \\[keyboard-quit] cancels."
  (interactive)
  (let ((char (read-char "Replace with: ")))
    (if (memq char '(?\e ?\C-g))
        (message "Replace cancelled")
      (delete-char 1) (insert char) (backward-char 1))))

(defun my/meow-toggle-char-case ()
  "Vim `~': toggle case of the char at point, then advance."
  (interactive)
  (when (< (point) (point-max))
    (let* ((c (char-after))
           (new (if (eq c (downcase c)) (upcase c) (downcase c))))
      (delete-char 1) (insert-char new))))

(defun my/meow-append-line ()
  "Vim `A': end of line, then Insert."
  (interactive) (end-of-line) (meow-insert))

(defun my/meow-insert-line ()
  "Vim `I': first non-blank, then Insert."
  (interactive) (back-to-indentation) (meow-insert))

(defun my/meow-change-to-eol ()
  "Vim `C': change to end of line."
  (interactive) (kill-line) (meow-insert))

(defun my/meow-indent-right ()
  "Indent region or current line right by `tab-width'."
  (interactive)
  (if (use-region-p)
      (indent-rigidly (region-beginning) (region-end) tab-width)
    (indent-rigidly (line-beginning-position) (line-end-position) tab-width)))

(defun my/meow-indent-left ()
  "Indent region or current line left by `tab-width'."
  (interactive)
  (if (use-region-p)
      (indent-rigidly (region-beginning) (region-end) (- tab-width))
    (indent-rigidly (line-beginning-position) (line-end-position) (- tab-width))))

(defun my/meow-paste-below ()
  "Vim `p': paste after point / below the line."
  (interactive)
  (when (null kill-ring) (user-error "Kill ring is empty"))
  (let* ((select-enable-clipboard meow-use-clipboard)
         (text (current-kill 0)))
    (cond
     ((use-region-p)
      (let ((beg (region-beginning)))
        (kill-region (region-beginning) (region-end)) (insert text) (goto-char beg)))
     ((string-suffix-p "\n" text)
      (let ((content (substring text 0 (1- (length text)))) target)
        (end-of-line) (insert "\n") (setq target (point))
        (insert content) (goto-char target) (back-to-indentation)))
     (t
      (unless (or (eobp) (eolp)) (forward-char 1))
      (insert text) (backward-char 1)))))

(defun my/meow-paste-above ()
  "Vim `P': paste before point / above the line."
  (interactive)
  (when (null kill-ring) (user-error "Kill ring is empty"))
  (let* ((select-enable-clipboard meow-use-clipboard)
         (text (current-kill 0)))
    (cond
     ((use-region-p)
      (let ((beg (region-beginning)))
        (kill-region (region-beginning) (region-end)) (insert text) (goto-char beg)))
     ((string-suffix-p "\n" text)
      (let ((content (substring text 0 (1- (length text)))) target)
        (beginning-of-line) (setq target (point))
        (insert content "\n") (goto-char target) (back-to-indentation)))
     (t (insert text) (backward-char 1)))))

(defun my/meow-save-clipboard ()
  "Vim `y': copy the selection to `kill-ring` AND system clipboard."
  (interactive)
  (let ((meow-use-clipboard t)) (call-interactively #'meow-save)))

(defun my/scroll-half-page-down ()
  "Vim `C-d' feel: scroll down half a window, recentering."
  (interactive) (forward-line (max 1 (/ (window-body-height) 2))) (recenter))

(defun my/scroll-half-page-up ()
  "Vim `C-u' feel: scroll up half a window, recentering."
  (interactive) (forward-line (- (max 1 (/ (window-body-height) 2)))) (recenter))

(defun my/meow-search-backward ()
  "Vim `N': previous search match."
  (interactive) (meow-search -1))

(defun my/meow-find-backward ()
  "Vim `F': find char backward."
  (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-find)))

(defun my/meow-till-backward ()
  "Vim `T': till char backward."
  (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-till)))

(defun my/backward-kill-word ()
  "Insert-mode `C-w': kill one adjacent chunk (whitespace/word/punct),no line cross."
  (interactive)
  (cond
   ((bolp) (unless (bobp) (delete-char -1)))
   (t
    (let ((beg (point)))
      (cond
       ((memq (char-before) '(?\s ?\t)) (skip-chars-backward " \t" (line-beginning-position)))
       ((eq (char-syntax (char-before)) ?w) (skip-syntax-backward "w" (line-beginning-position)))
       (t (skip-syntax-backward "^w " (line-beginning-position))))
      (delete-region (point) beg)))))

(defun my/meow-digit-or-expand ()
  "Digit key: expand selection to the Nth hint if live, else numeric prefix."
  (interactive)
  (if (and (region-active-p) meow--expand-nav-function (meow--selection-type))
      (meow-expand)
    (meow-digit-argument)))

(defun my/meow-mark-whitespace ()
  "Select the adjacent (or next) run of horizontal whitespace on the line."
  (interactive)
  (if (looking-at-p "[ \t]")
      (skip-chars-backward " \t")
    (skip-chars-forward "^ \t" (line-end-position)))
  (if (looking-at "[ \t]+")
      (meow--select (meow--make-selection '(select . transient)
                                          (match-beginning 0) (match-end 0)))
    (message "No whitespace to select")))

(defun my/meow-quit ()
  "Vim `:q': delete the current split; sole window -> previous buffer."
  (interactive)
  (if (> (length (window-list (selected-frame) 'no-minibuffer)) 1)
      (delete-window)
    (previous-buffer)))

(defun my/meow-surround (open close)
  "Wrap the active region with OPEN and CLOSE.
With no region, insert the pair and enter insert state between them."
  (if (region-active-p)
      (let ((beg (region-beginning)) (end (region-end)))
        (goto-char end) (insert close)
        (goto-char beg) (insert open)
        (deactivate-mark))
    (insert open close)
    (backward-char (length close))
    (meow-insert-mode 1)))

(defmacro my/meow-define-surround (name open close)
  "Define interactive command NAME that surrounds with OPEN/CLOSE."
  `(defun ,name () (interactive) (my/meow-surround ,open ,close)))

(my/meow-define-surround my/meow-surround-paren    "(" ")")
(my/meow-define-surround my/meow-surround-brace    "{" "}")
(my/meow-define-surround my/meow-surround-quote    "\"" "\"")
(my/meow-define-surround my/meow-surround-backtick "`" "`")

;;; meow keymaps ----------------------------------------------------

(defun my/meow-setup ()
  "meow QWERTY normal + motion bindings.  SPC routes to `my/leader-map'."
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("SPC" . meow-keypad)
   '("j" . meow-next)
   '("k" . meow-prev)
   '("/" . consult-line)
   '("i" . meow-temp-normal)
   '("<escape>" . keyboard-quit))
  (setq meow-selection-command-fallback
        '((meow-change . meow-change-char)
          (meow-kill . meow-delete)
          (meow-cancel-selection . ignore)
          (meow-pop-selection . meow-pop-grab)
          (meow-replace . my/meow-replace-char)
          (meow-beacon-change . meow-beacon-change-char)))
  (meow-normal-define-key
   '("SPC" . meow-keypad)
   '("9" . my/meow-digit-or-expand)
   '("8" . my/meow-digit-or-expand) '("7" . my/meow-digit-or-expand)
   '("6" . my/meow-digit-or-expand) '("5" . my/meow-digit-or-expand)
   '("4" . my/meow-digit-or-expand) '("3" . my/meow-digit-or-expand)
   '("2" . my/meow-digit-or-expand) '("1" . my/meow-digit-or-expand)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("/" . consult-line)
   '("~" . my/meow-toggle-char-case)
   '("_" . back-to-indentation)
   '("0" . beginning-of-visual-line)
   '("$" . end-of-visual-line)
   '("a" . meow-append)       '("A" . my/meow-append-line)
   '("b" . meow-back-word)    '("B" . meow-back-symbol)
   '("c" . meow-change)       '("C" . my/meow-change-to-eol)
   '("d" . meow-delete)       '("D" . meow-backward-delete)
   '("e" . meow-next-word)    '("E" . meow-next-symbol)
   '("f" . meow-find)         '("F" . my/meow-find-backward)
   '("g" . meow-cancel-selection) '("G" . meow-grab)
   '("h" . meow-left)         '("H" . meow-left-expand)
   '("i" . meow-insert)       '("I" . my/meow-insert-line)
   '("j" . meow-next)         '("J" . meow-next-expand)
   '("k" . meow-prev)         '("K" . meow-prev-expand)
   '("l" . meow-right)        '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)       '("N" . my/meow-search-backward)
   '("o" . meow-open-below)   '("O" . meow-open-above)
   '("p" . my/meow-paste-below) '("P" . my/meow-paste-above)
   '("q" . my/meow-quit)
   '("r" . meow-replace)      '("R" . meow-swap-grab)
   '("%" . evilmi-jump-items-native)
   '("s" . meow-kill)         '("S" . my/meow-mark-whitespace)
   '("t" . meow-till)         '("T" . my/meow-till-backward)
   '("u" . meow-undo)         '("U" . undo-fu-only-redo)
   '("v" . meow-visit)
   '("w" . meow-mark-word)    '("W" . meow-mark-symbol)
   '("x" . meow-line)         '("X" . meow-goto-line)
   '("y" . my/meow-save-clipboard)
   '("z" . meow-pop-selection)
   '(">" . my/meow-indent-right)
   '("<" . my/meow-indent-left)
   '("'" . repeat)
   ;; Surround the selection: select, then press the opening pair.
   '("(" . my/meow-surround-paren)
   '("{" . my/meow-surround-brace)
   '("\"" . my/meow-surround-quote)
   '("`" . my/meow-surround-backtick)
   '("<escape>" . my/meow-escape)))

(use-package meow
  :demand t
  :config
  (my/meow-setup)
  (add-to-list 'meow-mode-state-list '(messages-buffer-mode . normal))
  (meow-global-mode 1)

  (meow-thing-register 'angle        '(regexp "<" ">")   '(regexp "<" ">"))
  (meow-thing-register 'double-quote '(regexp "\"" "\"") '(regexp "\"" "\""))
  (meow-thing-register 'single-quote '(regexp "'" "'")   '(regexp "'" "'"))
  (meow-thing-register 'backtick     '(regexp "`" "`")   '(regexp "`" "`"))
  (setq meow-char-thing-table
        '((?\( . round) (?\) . round) (?\[ . square) (?\] . square)
          (?\{ . curly) (?\} . curly) (?\< . angle) (?\> . angle)
          (?\" . double-quote) (?\' . single-quote) (?\` . backtick)
          (?e . symbol) (?w . window) (?b . buffer)
          (?p . paragraph) (?l . line) (?d . defun) (?s . sentence)))

  (setq meow-cursor-type-normal 'box
        meow-cursor-type-insert '(bar . 2)
        meow-expand-hint-counts nil)

  ;; Start-keys are CHARACTERS (c->C-c, x->C-x); string keys silently no-op.
  ;; `h' is NOT a start-key (C-h is windmove-left) so SPC h reaches help.
  (setq meow-keypad-leader-dispatch my/leader-map
        meow-keypad-start-keys '((?c . ?c) (?x . ?x)))
  (meow-define-keys 'insert '("M-SPC" . meow-keypad))

  (when (fboundp 'meow--setup-which-key)
    (meow--setup-which-key t))
  (when (and (bound-and-true-p which-key-mode)
             (fboundp 'meow--which-key-describe-keymap))
    (meow--which-key-describe-keymap)))

(with-eval-after-load 'meow
  (define-key meow-normal-state-keymap (kbd "s-x") #'execute-extended-command)
  (setq meow--kbd-kill-line "C-S-k")
  (define-key global-map (kbd "C-S-k") #'kill-line)
  (dolist (km (list meow-normal-state-keymap meow-motion-state-keymap))
    (define-key km (kbd "M-K") #'my/scroll-half-page-up)
    (define-key km (kbd "M-J") #'my/scroll-half-page-down))
  (define-key meow-insert-state-keymap (kbd "C-w") #'my/backward-kill-word))

(use-package key-chord
  :after meow
  :config
  (setq key-chord-two-keys-delay 0.18)
  (key-chord-mode 1)
  (key-chord-define meow-insert-state-keymap "jk" #'meow-insert-exit))

;;; SPC leader map --------------------------------------------------

(defmacro my/leader-prefix (key name &rest bindings)
  "Define a named prefix KEY in `my/leader-map' titled NAME with BINDINGS.
BINDINGS are KEY COMMAND pairs."
  (declare (indent 2))
  (let ((map (make-symbol "map")))
    `(let ((,map (make-sparse-keymap)))
       ,@(cl-loop for (k c) on bindings by #'cddr
                  collect `(define-key ,map (kbd ,k) ,c))
       (define-key my/leader-map (kbd ,key) (cons ,name ,map)))))

(define-key my/leader-map (kbd "SPC") #'my/project-find-file)
(define-key my/leader-map (kbd ".")   #'find-file)
(define-key my/leader-map (kbd "X")   #'org-capture)
(define-key my/leader-map (kbd "P")   #'my/find-in-config)
(define-key my/leader-map (kbd "u")   #'universal-argument)
(define-key my/leader-map (kbd "h")   (cons "help" help-map))

(my/leader-prefix "f" "file"
  "f" #'find-file
  "F" #'consult-fd
  "r" #'consult-recent-file
  "b" #'consult-bookmark
  "s" #'save-buffer
  "S" #'write-file
  "R" #'rename-visited-file
  "d" #'dired)

(my/leader-prefix "b" "buffer"
  "b" #'persp-switch-to-buffer*
  "B" #'consult-buffer
  "d" #'kill-current-buffer
  "k" #'kill-current-buffer
  "n" #'next-buffer
  "p" #'previous-buffer
  "r" #'revert-buffer
  "x" #'scratch-buffer)

(my/leader-prefix "TAB" "workspace"
  "TAB" #'persp-switch
  "."   #'persp-switch
  "n"   #'persp-next
  "p"   #'persp-prev
  "d"   #'persp-kill
  "r"   #'persp-rename
  "s"   #'persp-state-save
  "l"   #'persp-state-load)

(my/leader-prefix "s" "search"
  "s" #'consult-line
  "S" #'consult-line-multi
  "p" #'consult-ripgrep
  "i" #'consult-imenu
  "m" #'consult-mark
  "d" #'consult-flycheck
  "D" #'consult-lsp-diagnostics)

(my/leader-prefix "p" "project"
  "p" #'projectile-switch-project
  "f" #'my/project-find-file
  "b" #'projectile-switch-to-buffer
  "d" #'projectile-find-dir
  "k" #'projectile-kill-buffers
  "c" #'projectile-compile-project
  "r" #'projectile-replace
  "g" #'consult-ripgrep
  "i" #'projectile-invalidate-cache)

(my/leader-prefix "v" "git"
  "v" #'magit-status
  "g" #'magit-status
  "b" #'magit-blame
  "l" #'magit-log-current
  "d" #'magit-dispatch)

(my/leader-prefix "k" "code"
  "d" #'xref-find-definitions
  "D" #'xref-find-references
  "a" #'lsp-execute-code-action
  "n" #'lsp-rename
  "i" #'lsp-find-implementation
  "s" #'consult-lsp-symbols
  "l" #'lsp
  "f" #'apheleia-format-buffer
  "e" #'quickrun
  "r" #'quickrun-region
  "E" #'quickrun-shell
  ":" #'eval-expression
  "b" #'eval-buffer)

(my/leader-prefix "w" "window"
  "\\" #'my/split-right-follow
  "-"  #'my/split-below-follow
  "c"  #'delete-window
  "o"  #'delete-other-windows
  "h"  #'windmove-left
  "j"  #'windmove-down
  "k"  #'windmove-up
  "l"  #'windmove-right
  "u"  #'winner-undo
  "r"  #'winner-redo
  "f"  #'my/focus-width-mode
  "="  #'balance-windows)

(my/leader-prefix "o" "open"
  "e" #'dirvish-side
  "o" #'my/reveal-in-finder
  "O" #'my/reveal-project-in-finder
  "m" #'notmuch
  "w" #'eww
  "d" #'dirvish
  "D" #'my/dirvish-org
  "j" #'webjump
  "-" #'dired-jump)

(my/leader-prefix "n" "notes/org"
  "c" #'org-capture
  "a" #'org-agenda
  "d" #'my/org-gtd-dashboard
  "r" #'my/org-reading-list
  "t" #'org-todo-list
  "l" #'org-store-link
  "A" #'my/org-inbox-archive-stale
  "u" #'my/org-reading-add-from-clipboard
  "e" #'my/org-read-in-eww
  "C" #'my/capture-frame
  "f" #'org-roam-node-find
  "i" #'org-roam-node-insert
  "j" #'org-roam-dailies-goto-today
  "b" #'org-roam-buffer-toggle)

(my/leader-prefix "j" "jump"
  "j" #'avy-goto-char-timer
  "c" #'avy-goto-char-2
  "w" #'avy-goto-word-1
  "l" #'avy-goto-line
  "r" #'avy-resume)

(my/leader-prefix "t" "toggle"
  "l" #'display-line-numbers-mode
  "w" #'whitespace-mode
  "t" #'load-theme
  "f" #'toggle-frame-fullscreen)

(my/leader-prefix "q" "quit"
  "q" #'save-buffers-kill-terminal
  "f" #'my/delete-frame-confirm)

(provide 'meow-rcp)

;; This file binds commands from many not-yet-loaded packages; silence the
;; resulting "not known to be defined" / free-variable lint noise.
;; Local Variables:
;; byte-compile-warnings: (not unresolved free-vars)
;; End:
;;; meow-rcp.el ends here
