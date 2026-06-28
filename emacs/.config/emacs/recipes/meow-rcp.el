;;; meow-rcp.el --- meow modal editing + SPC leader (loads last) -*- lexical-binding: t; -*-
;;
;;   c -> C-c   x -> C-x   m -> M-   g -> C-M-   (the four reserved letters)
;; Because c/x/m/g are taken, three things sit off their Doom spot:
;;

(eval-when-compile (require 'cl-lib))
(require 'cl-lib)

(defvar my/leader-map (make-sparse-keymap) "SPC leader keymap (fed to meow keypad).")

;;; Editing-command helpers ------------------------------------------

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

(defun my/meow-substitute-line ()
  "Vim `S'/`cc': change the whole line, keeping its indentation.
With a region, change every line it spans."
  (interactive)
  (if (use-region-p)
      (let ((beg (save-excursion (goto-char (region-beginning)) (line-beginning-position)))
            (end (save-excursion (goto-char (region-end))       (line-end-position))))
        (delete-region beg end) (goto-char beg) (meow-insert))
    (back-to-indentation) (kill-line) (meow-insert)))

(defun my/meow-comment ()
  "Toggle comments on the active region, else the current line.
Built-in commenting -- no package needed; comments respect the major mode."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

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
  "Vim `p': paste after point / below the line.
Pastes the most recent copy, whether it came from an Emacs buffer (kill
ring) or the system clipboard, whichever is newer."
  (interactive)
  (let ((text (ignore-errors (current-kill 0))))
    (unless (and text (not (string-empty-p text)))
      (user-error "Nothing to paste"))
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
  "Vim `P': paste before point / above the line.
Pastes the most recent copy, whether it came from an Emacs buffer (kill
ring) or the system clipboard, whichever is newer."
  (interactive)
  (let ((text (ignore-errors (current-kill 0))))
    (unless (and text (not (string-empty-p text)))
      (user-error "Nothing to paste"))
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

(defun my/meow-save-to-eol ()
  "`Y': copy from point to end of line (kill-ring + system clipboard)."
  (interactive)
  (let ((select-enable-clipboard t))
    (kill-ring-save (point) (line-end-position))))

(defun my/scroll-half-page-down ()
  "Scroll down half a window. Cancels any active selection first."
  (interactive)
  (when (region-active-p) (deactivate-mark))
  (forward-line (max 1 (/ (window-body-height) 2)))
  (recenter))

(defun my/scroll-half-page-up ()
  "Scroll up half a window. Cancels any active selection first."
  (interactive)
  (when (region-active-p) (deactivate-mark))
  (forward-line (- (max 1 (/ (window-body-height) 2))))
  (recenter))

;; Make `consult-line' feed meow's search ring, so after `/' you can repeat the
;; same query with n/N (`meow-search') -- consult-line is otherwise a one-shot
;; picker that leaves the ring untouched.  Its typed input lands in
;; `consult--line-history'; push it (literal-quoted) as the current search.
(defun my/consult-line-to-search-ring (&rest _)
  "Push the last `consult-line' query into `regexp-search-ring' for n/N."
  (when-let* ((query (car (bound-and-true-p consult--line-history)))
              ((not (string-empty-p query))))
    (meow--push-search (regexp-quote query))))
(advice-add 'consult-line :after #'my/consult-line-to-search-ring)

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

(defvar-local my/meow-last-selection nil
  "Bounds (MARK . POINT) of the most recent region in this buffer.")

(defun my/meow-remember-selection ()
  "Record the live region for `my/meow-reselect'.
Captured while the region is active rather than on `deactivate-mark-hook':
meow shuffles the mark ring when it cancels a selection, so by deactivation
time `(mark)' no longer points at the selection's start."
  (when (and (region-active-p) (/= (mark t) (point)))
    (setq my/meow-last-selection (cons (mark t) (point)))))
(add-hook 'post-command-hook #'my/meow-remember-selection)

(defun my/meow-reselect ()
  "Vim `gv': restore the last selection in this buffer."
  (interactive)
  (if my/meow-last-selection
      (meow--select (meow--make-selection
                     '(select . char)
                     (car my/meow-last-selection)
                     (cdr my/meow-last-selection))
                    t)                     ; activate the mark (region)
    (user-error "No selection to restore")))

(defun my/clear-mark-ring ()
  "Clear this buffer's mark ring (and the global mark ring)."
  (interactive)
  (setq mark-ring nil
        global-mark-ring nil)
  (message "Mark ring cleared"))

(defun my/open-dashboard ()
  "Show the dashboard in the current window."
  (cond ((fboundp 'dashboard-open) (dashboard-open))
        ((fboundp 'dashboard-refresh-buffer)
         (dashboard-refresh-buffer) (switch-to-buffer "*dashboard*"))
        (t (switch-to-buffer (get-buffer-create "*dashboard*")))))

(defun my/meow-quit-buffer ()
  "Quit -- bound to `q' and to `:q'/`:wq'.  In a split, close the window (vim
`:q', buffer kept).  As the sole window, kill the buffer; when only the
*scratch*/*Messages* fallback is left, land on the dashboard.  Refuse on the lone
dashboard -- there is nothing to quit."
  (interactive)
  (cond
   ((> (length (window-list nil 'no-minibuffer)) 1) (delete-window))
   ((derived-mode-p 'dashboard-mode) (message "Can't quit the dashboard"))
   (t (kill-current-buffer)
      (when (member (buffer-name) '("*scratch*" "*Messages*"))
        (my/open-dashboard)))))

(with-eval-after-load 'dashboard
  (define-key dashboard-mode-map (kbd "q") #'my/meow-quit-buffer))

;;; Vim ex command line (`:') ---------------------------------------
;; `:' reads a command line (with history) and dispatches the write/quit/edit
;; family, `:N' goto-line, and `[%]s/PAT/REP/[flags]' substitute.  Patterns are
;; Emacs regexps (so REP backrefs are \1, not vim's \1 vs &); flag `c' confirms.
(defvar my/meow-ex-history nil "Minibuffer history for `my/meow-ex'.")

(defun my/meow-ex--substitute (line)
  "Run an ex substitute LINE: [%]s/PAT/REP/[flags].
`%' targets the whole buffer, else the region, else the current line.
Flag `c' turns it into an interactive `query-replace-regexp'."
  (let* ((whole (eq (aref line 0) ?%))
         (body  (if whole (substring line 1) line))    ; starts at the `s'
         (delim (char-to-string (aref body 1)))        ; char after `s' = separator
         (parts (split-string (substring body 2) (regexp-quote delim)))
         (pat (nth 0 parts)) (rep (or (nth 1 parts) "")) (flags (or (nth 2 parts) "")))
    (when (or (null pat) (string-empty-p pat)) (user-error "Empty search pattern"))
    (let ((beg (cond (whole (point-min)) ((use-region-p) (region-beginning)) (t (line-beginning-position))))
          (end (cond (whole (point-max)) ((use-region-p) (region-end))       (t (line-end-position)))))
      (if (string-search "c" flags)
          (save-excursion (goto-char beg) (query-replace-regexp pat rep nil beg end))
        (replace-regexp-in-region pat rep beg end)))))

(defun my/buffer-display-path ()
  "File path for the `:w' message: bare name when the file sits in the project
root, a project-relative path in a subdirectory, the absolute path when the file
is outside any project (or the buffer name when it visits no file)."
  (let ((file (buffer-file-name)))
    (if (null file)
        (buffer-name)
      (let ((root (and (fboundp 'projectile-project-root)
                       (projectile-project-root (file-name-directory file)))))
        (if (and root (string-prefix-p (expand-file-name root) (expand-file-name file)))
            (file-relative-name file root)
          file)))))

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

;;; vim-style ci/ca reach for ,/. ----------------------------------
;; Keep meow's `,'/`.' thing dispatch intact (s square, r round, c curly, g
;; string, e symbol, ...).  Add vim's ci"/ca( reach: for a *pair* thing, if point
;; isn't already inside such a pair, first jump into the nearest one ahead on the
;; line, then hand the same thing-char back to meow -- so `, s'/`. r' selects
;; whether or not you're inside, and meow's normal selection/expand is untouched.

(defun my/meow--match-forward (open close from)
  "From FROM, return the position of the CLOSE matching an already-open level."
  (save-excursion
    (goto-char from)
    (let ((depth 0)
          (re (regexp-opt (list (char-to-string open) (char-to-string close))))
          result)
      (while (and (not result) (re-search-forward re nil t))
        (let ((c (char-before)))
          (cond ((eq c open)  (setq depth (1+ depth)))
                ((eq c close) (if (zerop depth) (setq result (1- (point)))
                                (setq depth (1- depth)))))))
      result)))

(defun my/meow--bracket-inner (open close)
  "Inner (BEG . END) of the nearest OPEN…CLOSE pair, or nil.
Prefer the pair enclosing point (handles nesting), else the next on the line."
  (let ((pt (point)))
    (or
     (save-excursion
       (let ((depth 0)
             (re (regexp-opt (list (char-to-string open) (char-to-string close))))
             ob)
         (while (and (not ob) (re-search-backward re nil t))
           (cond ((eq (char-after) close) (setq depth (1+ depth)))
                 ((eq (char-after) open)  (if (zerop depth) (setq ob (point))
                                            (setq depth (1- depth))))))
         (when ob
           (let ((cb (my/meow--match-forward open close (1+ ob))))
             (when (and cb (< ob pt) (<= pt cb)) (cons (1+ ob) cb))))))
     (save-excursion
       (when (search-forward (char-to-string open) (line-end-position) t)
         (let ((ob (1- (point)))
               (cb (my/meow--match-forward open close (point))))
           (when cb (cons (1+ ob) cb))))))))

(defun my/meow--quote-inner (q)
  "Inner (BEG . END) of the nearest Q…Q pair on the current line, or nil."
  (let* ((pt (point)) (eol (line-end-position)) (qs (char-to-string q))
         (positions '()))
    (save-excursion
      (goto-char (line-beginning-position))
      (while (search-forward qs eol t)
        (unless (eq (char-before (1- (point))) ?\\)   ; skip \" escapes
          (push (1- (point)) positions))))
    (setq positions (nreverse positions))
    (let ((pairs '()))
      (while (and positions (cdr positions))
        (push (cons (car positions) (cadr positions)) pairs)
        (setq positions (cddr positions)))
      (setq pairs (nreverse pairs))
      (when-let* ((hit (or (seq-find (lambda (p) (and (< (car p) pt) (<= pt (cdr p)))) pairs)
                           (seq-find (lambda (p) (>= (car p) pt)) pairs))))
        (cons (1+ (car hit)) (cdr hit))))))

(defun my/meow--pair-inner (open close)
  "Inner bounds of the nearest OPEN…CLOSE pair (quotes when OPEN = CLOSE)."
  (if (eq open close) (my/meow--quote-inner open)
    (my/meow--bracket-inner open close)))

(defun my/meow--string-inner ()
  "Inner bounds of the nearest \"…\"/'…'/`…` on the line, or nil."
  (let ((pt (point)) best)
    (dolist (q '(?\" ?' ?`) best)
      (when-let* ((b (my/meow--quote-inner q)))
        (when (or (null best) (< (abs (- (car b) pt)) (abs (- (car best) pt))))
          (setq best b))))))

(defun my/meow--thing-pair (ch)
  "Inner-bounds finder for meow thing char CH when it names a pair, else nil."
  (pcase (alist-get ch meow-char-thing-table)
    ('round  (lambda () (my/meow--pair-inner ?\( ?\))))
    ('square (lambda () (my/meow--pair-inner ?\[ ?\])))
    ('curly  (lambda () (my/meow--pair-inner ?{  ?})))
    ('string #'my/meow--string-inner)))

(defun my/meow--reach (ch)
  "If thing char CH is a pair and point isn't inside one, move point into the
nearest such pair ahead on the line (so meow's own inner/bounds then selects it)."
  (when-let* ((finder (my/meow--thing-pair ch))
              (inner  (funcall finder)))
    (unless (<= (car inner) (point) (cdr inner))
      (goto-char (car inner)))))

(defun my/meow--select-pair (inner boundsp)
  "Select INNER (BEG . END); with BOUNDSP widen one delimiter char each side."
  (meow--select (meow--make-selection
                 '(select . char)
                 (if boundsp (1- (car inner)) (car inner))
                 (if boundsp (1+ (cdr inner)) (cdr inner)))
                t))

(defun my/meow--thing-nearest (thing boundsp)
  "Select inner (or BOUNDSP) of THING, reaching the nearest pair on the line.
meow's `string' thing is syntax-gated, so it can't grab quotes inside a comment;
when the matched pair lives in one, select our own character match instead."
  (if-let* ((finder (my/meow--thing-pair thing))
            (inner  (funcall finder))
            ((nth 4 (syntax-ppss (car inner)))))   ; pair lives in a comment
      (my/meow--select-pair inner boundsp)
    (my/meow--reach thing)
    (if boundsp (meow-bounds-of-thing thing) (meow-inner-of-thing thing))))

(defun my/meow-inner-nearest ()
  "`meow-inner-of-thing' (`,') that reaches the nearest pair when point is outside it."
  (interactive)
  (my/meow--thing-nearest (meow-thing-prompt "Inner of: ") nil))

(defun my/meow-bounds-nearest ()
  "`meow-bounds-of-thing' (`.') that reaches the nearest pair when point is outside it."
  (interactive)
  (my/meow--thing-nearest (meow-thing-prompt "Bounds of: ") t))

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
   '("<escape>" . ignore))
  (setq meow-selection-command-fallback
        '((meow-change . meow-change-char)
          (meow-cancel-selection . ignore)
          (meow-pop-selection . ignore)
          (meow-replace . my/meow-replace-char)
          (meow-beacon-change . meow-beacon-change-char)
          ;; digits bind straight to `meow-expand' (already selection-fallback
          ;; wrapped); with no selection it lands here -> numeric prefix arg.
          (meow-expand . meow-digit-argument)))
  (meow-normal-define-key
   '("SPC" . meow-keypad)
   '("1" . meow-expand)
   '("2" . meow-expand)
   '("3" . meow-expand)
   '("4" . meow-expand)
   '("5" . meow-expand)
   '("6" . meow-expand)
   '("7" . meow-expand)
   '("8" . meow-expand)
   '("9" . meow-expand)
   '("-" . negative-argument)
   '("!" . revert-buffer-quick)
   '(";" . meow-reverse)
   '(":" . my/meow-ex)
   '("," . my/meow-inner-nearest)
   '("." . my/meow-bounds-nearest)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("/" . consult-line)
   '("~" . my/meow-toggle-char-case)
   '("_" . back-to-indentation)
   '("Q" . kmacro-start-macro-or-insert-counter)
   '("@" . kmacro-end-or-call-macro)
   '("0" . beginning-of-visual-line)
   '("$" . end-of-visual-line)
   '("a" . meow-append)
   '("A" . (lambda () (interactive) (end-of-line) (meow-insert)))
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("C" . (lambda () (interactive) (meow-kill) (meow-insert)))
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find-expand)
   '("F" . (lambda () (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-find-expand))))
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . (lambda () (interactive) (beginning-of-line) (meow-insert)))
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-open-below)
   '("O" . meow-open-above)
   '("p" . my/meow-paste-below)
   '("P" . my/meow-paste-above)
   '("q" . my/meow-quit-buffer)
   '("r" . meow-replace)
   '("%" . evilmi-jump-items-native)
   '("s" . meow-kill)
   '("S" . my/meow-substitute-line)
   '("t" . meow-till-expand)
   '("T" . (lambda () (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-till-expand))))
   '("u" . meow-undo)
   '("U" . undo-fu-only-redo)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . my/meow-save-clipboard)
   '("Y" . my/meow-save-to-eol)
   '("z" . meow-pop-selection)
   '("Z" . meow-to-block)
   '(">" . my/meow-indent-right)
   '("<" . my/meow-indent-left)
   '("'" . repeat)
   ;; Surround the selection: select, then press the opening pair.
   '("(" . my/meow-surround-paren)
   '("{" . my/meow-surround-brace)
   '("\"" . my/meow-surround-quote)
   '("`" . my/meow-surround-backtick)
   '("<escape>" . ignore)))

(use-package meow
  :demand t
  :config
  (setq meow-replace-state-name-list
        '((org-motion . "O-M")
          (normal . "N")
          (motion . "M")
          (keypad . "K")
          (insert . "I")
          (beacon . "B")))
  (my/meow-setup)
  ;; Per-major-mode initial state.  meow resolves a buffer by exact mode, then
  ;; up the derived-mode parents, then auto-detects (a-z self-insert -> Normal,
  ;; else Motion).  So `special-mode' is a Motion catch-all (help/info/grep/occur/
  ;; compilation/magit/dashboard...); exact rows below override it (Normal) or
  ;; cover modes that don't derive from a read-only parent.  Centralised here
  ;; instead of per-recipe drop-ins.  (ghostel turns meow OFF entirely -- see
  ;; term-rcp -- which a state row can't express, so that one stays a hook.)
  (setq meow-mode-state-list
        '((conf-mode . normal)
          (fundamental-mode . normal)
          (prog-mode . normal)
          (text-mode . normal)
          (wdired-mode . normal)             ; editing dired filenames
          (special-mode . motion)            ; catch-all for read-only single-key UIs
          (dired-mode . motion)
          (dirvish-mode . motion)
          (pdf-view-mode . motion)
          (notmuch-hello-mode . motion)      ; notmuch modes derive from fundamental
          (notmuch-search-mode . motion)     ; (-> Normal), so they need explicit rows
          (notmuch-tree-mode . motion)
          (notmuch-show-mode . motion)))
  (meow-global-mode 1)

  (setq meow-cursor-type-normal 'box
        meow-cursor-type-insert '(bar . 2)
        meow-expand-hint-counts nil)

  ;; Start-keys are CHARACTERS (c->C-c, x->C-x); string keys silently no-op.
  ;; `h' is NOT a start-key (C-h is windmove-left) so SPC h reaches help.
  ;; Free `g' from the keypad C-M- prefix so `SPC g' reaches the grab leader
  ;; (C-M- commands are rare; `m' stays the Meta prefix).
  (setq meow-keypad-leader-dispatch my/leader-map
        meow-keypad-start-keys '((?c . ?c) (?x . ?x))
        meow-keypad-ctrl-meta-prefix nil)
  (meow-define-keys 'insert '("M-SPC" . meow-keypad))

  (when (fboundp 'meow--setup-which-key)
    (meow--setup-which-key t))
  (when (and (bound-and-true-p which-key-mode)
             (fboundp 'meow--which-key-describe-keymap))
    (meow--which-key-describe-keymap)))

(with-eval-after-load 'meow
  (define-key global-map (kbd "H-x") #'execute-extended-command)
  (define-key global-map (kbd "M-/") #'my/meow-comment) ; Cmd-/ toggle comment (was gc)
  (define-key global-map (kbd "C-c r") #'my/meow-reselect) ; vim `gv' reselect
  (define-key meow-normal-state-keymap (kbd "?") #'eldoc-box-help-at-point)

  (setq meow--kbd-delete-char "C-S-d")
  (define-key global-map (kbd "C-S-d") #'delete-char)
  ;; `meow-page-down' internally does (key-binding "C-v") via `meow--kbd-scoll-up';
  ;; we steal C-v for meow-to-block, so repoint that lookup at the PageDown key
  ;; (also bound to `scroll-up-command') to keep meow-page-down working.
  (setq meow--kbd-scoll-up "<next>")
  (dolist (km (list meow-normal-state-keymap meow-motion-state-keymap))
    (define-key km (kbd "C-u") #'my/scroll-half-page-up)
    (define-key km (kbd "C-d") #'my/scroll-half-page-down)
    (define-key km (kbd "C-v")   #'meow-to-block)
    (define-key km (kbd "C-S-v") #'meow-block))
  (define-key global-map (kbd "M-S-n") #'my/scroll-half-page-down)
  (define-key global-map (kbd "M-S-p") #'my/scroll-half-page-up)

  (define-key meow-insert-state-keymap (kbd "C-h") #'backward-delete-char)
  (define-key meow-insert-state-keymap (kbd "C-l") #'recenter-top-bottom)
  (define-key meow-insert-state-keymap (kbd "C-w") #'my/backward-kill-word))

;; ESC aborts any real minibuffer prompt (M-x, find-file, completing-read);
;; without this ESC is just the Meta prefix and dangles.  (The y/n and
;; read-multiple-choice confirmations are raw read-event loops, NOT minibuffers
;; -- ESC for those is handled by `my/read-event-esc-quits' in base-rcp.)
(define-key minibuffer-local-map (kbd "<escape>") #'abort-minibuffers)

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
  "c"   #'my/persp-new-workspace
  "n"   #'persp-next
  "p"   #'persp-prev
  "d"   #'persp-kill
  "r"   #'persp-rename
  "s"   #'persp-state-save
  "l"   #'persp-state-load)

;; Search is canonical under `C-c s' (completion-rcp et al.).  Point the leader at
;; that very keymap so `SPC s' and `C-c s' are one menu -- the only meow-side line;
;; drop meow and the `C-c s' bindings stay put.
(define-key my/leader-map (kbd "s")
            (cons "search" (keymap-lookup global-map "C-c s")))

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
  "d" #'magit-dispatch
  "[" #'diff-hl-previous-hunk
  "]" #'diff-hl-next-hunk
  "r" #'diff-hl-revert-hunk
  "s" #'diff-hl-show-hunk)

(my/leader-prefix "g" "grab"
  "g" #'meow-grab
  "p" #'meow-swap-grab
  "y" #'meow-sync-grab)

(my/leader-prefix "k" "code"
  "d" #'xref-find-definitions
  "D" #'xref-find-references
  "," #'xref-go-back
  "a" #'eglot-code-actions
  "n" #'eglot-rename
  "i" #'eglot-find-implementation
  "s" #'consult-imenu
  "S" #'consult-eglot-symbols
  "l" #'eglot
  "f" #'apheleia-format-buffer
  "e" #'quickrun
  "r" #'quickrun-region
  "E" #'quickrun-shell
  ":" #'eval-expression
  "b" #'eval-buffer)

(my/leader-prefix "w" "window"
  "c"  #'delete-window
  "o"  #'delete-other-windows
  "w"  #'ace-window
  "s"  #'ace-swap-window               ; swap two panes
  "m"  #'my/ace-move-window            ; move this buffer to a chosen pane
  "y"  #'my/ace-copy-window            ; mirror this buffer into a chosen pane
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
  "t" #'my/ghostel-popup
  "T" #'my/ghostel-full
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
  "f" #'my/delete-frame-confirm
  "r" #'my/reload-config)

(provide 'meow-rcp)

;; This file binds commands from many not-yet-loaded packages; silence the
;; resulting "not known to be defined" / free-variable lint noise.
;; Local Variables:
;; byte-compile-warnings: (not unresolved free-vars)
;; End:
;;; meow-rcp.el ends here
