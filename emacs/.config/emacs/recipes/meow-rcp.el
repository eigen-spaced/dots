;;; meow-rcp.el --- meow modal editing + SPC leader (loads last) -*- lexical-binding: t; -*-
;;
;;   c -> C-c   x -> C-x   m -> M-   g -> C-M-   (the four reserved letters)
;; Because c/x/m/g are taken, three things sit off their Doom spot:
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

(defun my/meow-append ()
  "Vim `a': append after the selection; with none, insert *after* the char at
point (not at point, which is what bare `meow-append' does)."
  (interactive)
  (if (region-active-p)
      (call-interactively #'meow-append)
    (unless (eolp) (forward-char 1))
    (meow-insert)))

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

(defun my/meow-save-to-eol ()
  "`Y': copy from point to end of line (kill-ring + system clipboard)."
  (interactive)
  (let ((select-enable-clipboard t))
    (kill-ring-save (point) (line-end-position))))

(defun my/scroll-half-page-down ()
  "Vim `C-f' feel: scroll down half a window, recentering."
  (interactive) (forward-line (max 1 (/ (window-body-height) 2))) (recenter))

(defun my/scroll-half-page-up ()
  "Vim `C-b' feel: scroll up half a window, recentering."
  (interactive) (forward-line (- (max 1 (/ (window-body-height) 2)))) (recenter))

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

(defun my/meow-find-backward ()
  "Vim `F': find char backward; extend the active selection."
  (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-find-expand)))

(defun my/meow-till-backward ()
  "Vim `T': till char backward; extend the active selection."
  (interactive) (let ((current-prefix-arg -1)) (call-interactively #'meow-till-expand)))

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

;; Vim `gv': remember each region as it is deactivated, so it can be restored
;; after an accidental exit.  Direction is preserved (mark/point), and it comes
;; back as an expandable selection so c/d/y and H/L/e work on it straight away.
(defvar-local my/meow-last-selection nil
  "Bounds (MARK . POINT) of the most recent region in this buffer.")

(defun my/meow-remember-selection ()
  "Record the region being deactivated for `my/meow-reselect'."
  (when (and (mark t) (/= (mark t) (point)))
    (setq my/meow-last-selection (cons (mark t) (point)))))
(add-hook 'deactivate-mark-hook #'my/meow-remember-selection)

(defun my/meow-reselect ()
  "Vim `gv': restore the last selection in this buffer."
  (interactive)
  (if my/meow-last-selection
      (meow--select (meow--make-selection
                     '(expand . char)
                     (car my/meow-last-selection)
                     (cdr my/meow-last-selection))
                    t)                     ; activate the mark (region)
    (user-error "No selection to restore")))

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

;;; vim-style ci/ca: nearest-pair inner/bounds ----------------------
;; meow's `,'/`.' (inner/bounds-of-thing) only fire when point is already inside
;; the thing.  These wrappers add vim's ci"/ca( reach: for a pair delimiter (or
;; `e' = symbol) select the pair enclosing point, else the next one on the line;
;; every other thing falls through to meow unchanged.  A real meow selection is
;; left, so follow with c/d/y.

(defconst my/meow-pair-chars
  '((?\( ?\( . ?\)) (?\) ?\( . ?\))
    (?\[ ?\[ . ?\]) (?\] ?\[ . ?\])
    (?{  ?{  . ?})  (?}  ?{  . ?})
    (?<  ?<  . ?>)  (?>  ?<  . ?>)
    (?\" ?\" . ?\") (?'  ?'  . ?') (?`  ?`  . ?`))
  "Delimiter char -> (OPEN . CLOSE) for the nearest-pair selectors.")

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
      (when-let ((hit (or (seq-find (lambda (p) (and (< (car p) pt) (<= pt (cdr p)))) pairs)
                          (seq-find (lambda (p) (>= (car p) pt)) pairs))))
        (cons (1+ (car hit)) (cdr hit))))))

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

(defun my/meow--pair-inner (open close)
  (if (eq open close) (my/meow--quote-inner open)
    (my/meow--bracket-inner open close)))

(defun my/meow--symbol-inner ()
  "Bounds of the symbol at point, else the next symbol on the line, or nil."
  (or (bounds-of-thing-at-point 'symbol)
      (save-excursion
        (when (re-search-forward "\\(?:\\sw\\|\\s_\\)" (line-end-position) t)
          (goto-char (match-beginning 0))
          (bounds-of-thing-at-point 'symbol)))))

(defun my/meow--select-bounds (bounds outer)
  "Make a meow selection over BOUNDS; OUTER widens by one each side (delimiters)."
  (let ((beg (if outer (1- (car bounds)) (car bounds)))
        (end (if outer (1+ (cdr bounds)) (cdr bounds))))
    (meow--select (meow--make-selection '(select . inner) beg end) t)))

(defun my/meow--inner-or-bounds (outer fallback)
  "Read a char and select the nearest pair (OUTER includes delimiters) or
symbol; fall through to FALLBACK for any other meow thing."
  (let* ((ch (read-char (if outer "bounds: " "inner: ")))
         (pair (alist-get ch my/meow-pair-chars)))
    (cond
     (pair (if-let ((b (my/meow--pair-inner (car pair) (cdr pair))))
               (my/meow--select-bounds b outer)
             (user-error "No %c…%c on this line" (car pair) (cdr pair))))
     ((eq ch ?e) (if-let ((b (my/meow--symbol-inner)))
                     (my/meow--select-bounds b nil)
                   (user-error "No symbol")))
     (t (setq unread-command-events (list ch))
        (call-interactively fallback)))))

(defun my/meow-inner-nearest ()
  "`meow-inner-of-thing' that reaches the nearest pair/symbol (vim ci\")."
  (interactive)
  (my/meow--inner-or-bounds nil #'meow-inner-of-thing))

(defun my/meow-bounds-nearest ()
  "`meow-bounds-of-thing' that reaches the nearest pair/symbol (vim ca\")."
  (interactive)
  (my/meow--inner-or-bounds t #'meow-bounds-of-thing))

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
          (meow-beacon-change . meow-beacon-change-char)
          ;; digits bind straight to `meow-expand' (already selection-fallback
          ;; wrapped); with no selection it lands here -> numeric prefix arg.
          (meow-expand . meow-digit-argument)))
  (meow-normal-define-key
   '("SPC" . meow-keypad)
   '("9" . meow-expand)
   '("8" . meow-expand) '("7" . meow-expand)
   '("6" . meow-expand) '("5" . meow-expand)
   '("4" . meow-expand) '("3" . meow-expand)
   '("2" . meow-expand) '("1" . meow-expand)
   '("-" . negative-argument)
   '("!" . revert-buffer-quick)
   '(";" . meow-reverse)
   '("," . my/meow-inner-nearest)
   '("." . my/meow-bounds-nearest)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("/" . consult-line)
   '("~" . my/meow-toggle-char-case)
   '("_" . back-to-indentation)
   '("0" . beginning-of-visual-line)
   '("$" . end-of-visual-line)
   '("a" . my/meow-append)        '("A" . my/meow-append-line)    
   '("b" . meow-back-word)        '("B" . meow-back-symbol)    
   '("c" . meow-change)           '("C" . my/meow-change-to-eol)    
   '("d" . meow-delete)           '("D" . meow-backward-delete)    
   '("e" . meow-next-word)        '("E" . meow-next-symbol)    
   '("f" . meow-find-expand)      '("F" . my/meow-find-backward)    
   '("g" . meow-cancel-selection) '("G" . meow-grab)
   '("h" . meow-left)             '("H" . meow-left-expand)
   '("i" . meow-insert)           '("I" . my/meow-insert-line)
   '("j" . meow-next)             '("J" . meow-next-expand)
   '("k" . meow-prev)             '("K" . meow-prev-expand)
   '("l" . meow-right)            '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-open-below)       '("O" . meow-open-above)
   '("p" . my/meow-paste-below)   '("P" . my/meow-paste-above)
   '("q" . my/meow-quit)
   '("r" . meow-replace)          '("R" . meow-swap-grab)
   '("%" . evilmi-jump-items-native)
   '("s" . meow-kill)
   '("t" . meow-till-expand)      '("T" . my/meow-till-backward)
   '("u" . meow-undo)             '("U" . undo-fu-only-redo)
   '("C-r" . undo-fu-only-redo)
   '("v" . meow-visit)            '("V" . my/meow-reselect)
   '("w" . meow-mark-word)        '("W" . meow-mark-symbol)
   '("x" . meow-line)             '("X" . meow-goto-line)
   '("y" . my/meow-save-clipboard) '("Y" . my/meow-save-to-eol)
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
  ;; Super-key twins for M-x / M-! bound in the GLOBAL map, not a meow state
  ;; map, so they fire in every state — including motion-state buffers like the
  ;; dashboard, and insert state.
  (define-key global-map (kbd "s-x") #'execute-extended-command)
  (define-key global-map (kbd "s-!") #'shell-command)
  (define-key meow-normal-state-keymap (kbd "?") #'eldoc-box-help-at-point)
  ;; C-s saves only in normal state -- not globally -- so when meow is off (pure
  ;; Emacs keys) C-s falls back to its vanilla `isearch-forward'.
  (define-key meow-normal-state-keymap (kbd "C-s") #'save-buffer)
  (setq meow--kbd-kill-line "C-S-k")
  (define-key global-map (kbd "C-S-k") #'kill-line)
  ;; Scroll lives on C-u/C-d (vim half-page) below.  C-u has no meow internal
  ;; use, but meow-delete acts by *executing* `meow--kbd-delete-char' (default
  ;; C-d), so redirect that macro to C-S-d -- else C-d scrolls instead of
  ;; deleting.  (C-f/C-b stay meow's default forward/backward-char, driving h/l.)
  ;; Same key-hijack pattern as meow--kbd-kill-line above.
  (setq meow--kbd-delete-char "C-S-d")
  (define-key global-map (kbd "C-S-d") #'delete-char)
  (dolist (km (list meow-normal-state-keymap meow-motion-state-keymap))
    (define-key km (kbd "C-u") #'my/scroll-half-page-up)
    (define-key km (kbd "C-d") #'my/scroll-half-page-down))
  ;; Insert state is for editing, not window nav: shadow the global C-h/j/k/l
  ;; windmove with insert-mode editing.  C-h/C-w/C-k = delete char/word/to-eol
  ;; (vim insert trio); C-j newline, C-l recenter.  Nav stays on normal/motion.
  (define-key meow-insert-state-keymap (kbd "C-h") #'backward-delete-char)
  (define-key meow-insert-state-keymap (kbd "C-j") #'electric-newline-and-maybe-indent)
  (define-key meow-insert-state-keymap (kbd "C-k") #'kill-line)
  (define-key meow-insert-state-keymap (kbd "C-l") #'recenter-top-bottom)
  (define-key meow-insert-state-keymap (kbd "C-w") #'my/backward-kill-word))

;; Corfu's auto-popup can outlive a *beacon* edit: meow replays the change via a
;; kbd macro and returns to beacon state without corfu's own quit hook firing,
;; leaving a stray completion frame up.  Dismiss it specifically on beacon-insert
;; exit -- normal insert already tears corfu down on its own.
(with-eval-after-load 'meow
  (advice-add 'meow-beacon-insert-exit :after
              (lambda (&rest _)
                (when (and (fboundp 'corfu-quit)
                           (bound-and-true-p completion-in-region-mode))
                  (corfu-quit)))))

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

(my/leader-prefix "s" "search"
  "s" #'consult-line
  "S" #'consult-line-multi
  "p" #'consult-ripgrep
  "m" #'consult-mark
  "d" #'consult-flymake
  "f" #'isearch-forward
  "b" #'isearch-backward)

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

(my/leader-prefix "k" "code"
  "d" #'xref-find-definitions
  "D" #'xref-find-references
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
  "f" #'my/delete-frame-confirm)

(provide 'meow-rcp)

;; This file binds commands from many not-yet-loaded packages; silence the
;; resulting "not known to be defined" / free-variable lint noise.
;; Local Variables:
;; byte-compile-warnings: (not unresolved free-vars)
;; End:
;;; meow-rcp.el ends here
