;;; hel-rcp.el --- hel modal editing + SPC leader (loads last) -*- lexical-binding: t; -*-
;;
;; TRIAL: helix-style layer (https://github.com/anuvyklack/hel), swapped in for
;; meow-rcp.el on this branch.  Deliberately thin -- hel ships natively most of
;; what meow-rcp hand-rolled: vim-ish inner/around objects (`mi w', `ma (' -- and
;; `mw' shorthand), surround, gv reselect, f/F/t/T with hints repeatable by n/N,
;; PCRE search, multiple cursors.  Per-mode initial state is auto-detected
;; (letters self-insert -> Normal, else Emacs), so there is no mode-state-list to
;; maintain either.
;;
;; What stays ours: the SPC leader map, M-/ comment, ESC in the minibuffer, jk,
;; and the scroll keys -- hel animates those through ultra-scroll, we don't.
;;
;;; Code:

(eval-when-compile (require 'cl-lib))
(require 'cl-lib)

(defvar my/leader-map (make-sparse-keymap) "SPC leader keymap.")

;;; Editing-command helpers ------------------------------------------

(defun my/comment-dwim ()
  "Toggle comments on the active region, else the current line."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-line 1)))

;; Scroll: the meow versions, instant.  hel's C-d/C-u animate the jump through
;; ultra-scroll (`hel-scroll-half-page-duration'), which reads as distracting;
;; these just move point half a window and recenter.
(defun my/scroll-half-page-down ()
  "Scroll down half a window.  Cancels any active selection first."
  (interactive)
  (when (region-active-p) (deactivate-mark))
  (forward-line (max 1 (/ (window-body-height) 2)))
  (recenter))

(defun my/scroll-half-page-up ()
  "Scroll up half a window.  Cancels any active selection first."
  (interactive)
  (when (region-active-p) (deactivate-mark))
  (forward-line (- (max 1 (/ (window-body-height) 2))))
  (recenter))

(defun my/copy-buffer-to-kill-ring ()
  "Copy the entire current buffer to the kill ring."
  (interactive)
  (kill-ring-save (point-min) (point-max))
  (message "Buffer copied"))

(defun my/open-dashboard ()
  "Show the dashboard in the current window."
  (cond ((fboundp 'dashboard-open) (dashboard-open))
        ((fboundp 'dashboard-refresh-buffer)
         (dashboard-refresh-buffer) (switch-to-buffer "*dashboard*"))
        (t (switch-to-buffer (get-buffer-create "*dashboard*")))))

(defun my/quit-buffer ()
  "Quit: close the window in a split, else bury the buffer (dashboard as floor)."
  (interactive)
  (cond
   ((> (length (window-list nil 'no-minibuffer)) 1) (delete-window))
   ((derived-mode-p 'dashboard-mode) (message "Can't quit the dashboard"))
   (t (previous-buffer)
      (when (member (buffer-name) '("*scratch*" "*Messages*"))
        (my/open-dashboard)))))

(with-eval-after-load 'dashboard
  (define-key dashboard-mode-map (kbd "q") #'my/quit-buffer))

;;; hel -------------------------------------------------------------

(use-package dash)
(use-package pcre2el)
(use-package ultra-scroll)

(use-package hel
  :vc (:url "https://github.com/anuvyklack/hel.git" :rev "main")
  :demand t
  :custom
  ;; Inert in 0.12.0 (defined, never read), set defensively: if upstream wires it
  ;; up it would put AST crawling on C-h/C-j/C-k/C-l over our global windmove.
  (hel-want-C-hjkl-keys nil)
  ;; hel ships vim's cursors inverted (bar normal, box insert) on purpose; keep
  ;; the vim/meow shapes we're used to instead.
  (hel-normal-state-cursor-type 'box)
  (hel-insert-state-cursor-type '(bar . 2))
  ;; No modal editing in the minibuffer: otherwise ESC at an M-x prompt switches
  ;; hel to Normal state instead of aborting.  Off, the prompt is plain Emacs and
  ;; ESC hits `abort-minibuffers' (bound below), as it did under meow.
  (hel-want-minibuffer nil)
  :config
  (hel-mode)
  (hel-keymap-global-set :state 'normal
    "q"   #'my/quit-buffer
    "/"   #'consult-line
    ;; hel's `:' is M-x; jump-to-char is the more useful home for it (M-x/H-x remain).
    ":"   #'avy-goto-char-2
    ;; Swap helix's replace pair: `r' pastes the yank over the selection,
    ;; `R' types a char over each selected char.
    "r"   #'hel-replace-with-kill-ring
    "R"   #'hel-replace-char
    "g v" #'my/hel-restore-selection
    "m s" #'my/hel-mark-symbol
    ;; free while there's a single cursor (hel only claims it for multiple ones)
    "K"   #'eldoc-box-help-at-point)

  ;; hel puts vim's scroll keys on C-f/C-b (page) and C-e/C-y (line), shadowing
  ;; the stock motions and yank in Normal and Emacs state.  Drop them -- C-d/C-u
  ;; already cover scrolling -- so the global bindings show through again.
  ;; C-d/C-u we keep, but swapped for instant equivalents of hel's animated
  ;; (ultra-scroll) versions.  Zeroing `hel-scroll-*-duration' would be the
  ;; tidier knob but the easing loop divides by it, so rebind instead.
  (dolist (map (list hel-normal-state-map hel-emacs-state-map))
    (keymap-unset map "C-f" t)
    (keymap-unset map "C-b" t)
    (keymap-unset map "C-e" t)
    (keymap-unset map "C-y" t)
    (keymap-set map "C-d" #'my/scroll-half-page-down)
    (keymap-set map "C-u" #'my/scroll-half-page-up)
    (keymap-set map "z z" (cons "center line"    (lambda () (interactive) (recenter))))
    (keymap-set map "z t" (cons "line to top"    (lambda () (interactive) (recenter 0))))
    (keymap-set map "z b" (cons "line to bottom" (lambda () (interactive) (recenter -1))))))

;; Modifier-free access to C-c/C-x/M-/C-M- chords, god-mode style.  hel-leader
;; claims SPC outright, so we take it back for the Doom leader and reach the
;; translator through the four keys meow's keypad used as start-keys (below).
(use-package s)
(use-package hel-leader
  :vc (:url "https://github.com/anuvyklack/hel-leader.git" :rev "main")
  :after hel
  :config
  (hel-keymap-global-set :state '(normal emacs)
    "SPC" my/leader-map))

;; hel's mark menu has word (`m w') and WORD (`m W') but no *symbol*, so on
;; `hel-insert-state-cursor-type' `m w' stops at `cursor' and `m W' drags in the
;; surrounding parens.  Add meow's `W' as `m s'.  Not via `hel-mark-inner-thing':
;; its count walk uses `forward-symbol', which skips over non-symbol chars and
;; overshoots into the whitespace before the symbol.  `bounds-of-thing-at-point'
;; is exact.  The `put's are what `hel-define-command' would have set: run for
;; every cursor, merge selections that end up overlapping.
(declare-function hel-set-region "hel-lib")
(defun my/hel-mark-symbol ()
  "Select the symbol at point, whatever part of it point sits on."
  (interactive)
  (if-let* ((bounds (bounds-of-thing-at-point 'symbol)))
      (hel-set-region (car bounds) (cdr bounds) 1)
    (user-error "No symbol at point")))
(put 'my/hel-mark-symbol 'multiple-cursors t)
(put 'my/hel-mark-symbol 'merge-selections t)

;; hel flashes every copy with `pulse-highlight-start-face' -- a stock yellow
;; that reads as olive against the theme.  Drop the flash: back to plain emacs,
;; where `indicate-copied-region' blinks the cursor at the far end of the region.
;; (This is what meow did -- it had no pulse at all.)
(with-eval-after-load 'hel
  (advice-add 'hel-pulse-main-region :override #'ignore))

;; `r'/`R' (hel-replace-*) read the replacement through `read-char', which hands
;; back ESC as the literal char 27 -- so ESC lands a `^[' in the buffer instead
;; of bailing.  Rebind `read-char' for the command's extent so ESC (or C-g)
;; quits the replace, the way it would in vim/meow.
(defun my/hel-replace-cancel-on-esc (orig &rest args)
  "Run a hel replace command with ESC/C-g cancelling the char read."
  (cl-letf* ((real (symbol-function 'read-char))
             ((symbol-function 'read-char)
              (lambda (&rest a)
                (let ((c (apply real a)))
                  (if (memq c '(?\e ?\C-g)) (keyboard-quit) c)))))
    (apply orig args)))
(with-eval-after-load 'hel
  (advice-add 'hel-replace-char :around #'my/hel-replace-cancel-on-esc)
  (advice-add 'hel-replace-with-kill-ring :around #'my/hel-replace-cancel-on-esc))

;; `g v' (`hel-restore-cursors') only restores *multiple cursor* positions -- with
;; a single selection its history is empty and it does nothing.  Track the last
;; region ourselves (meow's `gv') and fall back to it, so `g v' reselects in both
;; cases.  Recorded while the region is live: by `deactivate-mark-hook' time the
;; mark no longer points at the selection's start.
(defvar-local my/hel-last-selection nil
  "Bounds (MARK . POINT) of the most recent region in this buffer.")

(defun my/hel-remember-selection ()
  "Record the live region for `my/hel-restore-selection'."
  (when (and (region-active-p) (/= (mark t) (point)))
    (setq my/hel-last-selection (cons (mark t) (point)))))
(add-hook 'post-command-hook #'my/hel-remember-selection)

(declare-function hel-restore-cursors "hel-commands")
(defun my/hel-restore-selection ()
  "Restore the last multiple cursors, else the last single selection."
  (interactive)
  (cond
   ((bound-and-true-p hel--cursors-positions-history)
    (call-interactively #'hel-restore-cursors))
   (my/hel-last-selection
    (hel-set-region (car my/hel-last-selection) (cdr my/hel-last-selection)))
   (t (user-error "No selection to restore"))))

;; `/' is consult-line (above), but hel's n/N read their pattern from the `/'
;; register, which only `hel-search-forward' fills -- so a consult search would
;; not repeat.  Push the query there ourselves, PCRE-quoted since hel searches in
;; PCRE.  (`hel-add-to-regex-history' announces the register; keep it quiet.)
(declare-function hel-add-to-regex-history "hel-search")
(declare-function rxt-quote-pcre "pcre2el")
(defun my/consult-line-to-hel-register (&rest _)
  "Push the last `consult-line' query into hel's `/' register, for n/N."
  (when-let* ((query (car (bound-and-true-p consult--line-history)))
              ((not (string-empty-p query))))
    (let ((inhibit-message t))
      (hel-add-to-regex-history (rxt-quote-pcre query)))))
(with-eval-after-load 'hel
  (advice-add 'consult-line :after #'my/consult-line-to-hel-register))

(defun my/hel-leader-key (key)
  "Run `hel-leader' as though KEY were the first key typed after it."
  (setq unread-command-events (listify-key-sequence (kbd key)))
  (hel-leader))

;; Keep the four keypad keys out of the `SPC' which-key popup -- they are
;; modifier prefixes, not commands, and reading as `c C-c' next to `f +file' is
;; just noise.  A replacement that is neither nil nor a cons means "hide".
(with-eval-after-load 'which-key
  (push (cons (cons nil (rx bos (or "C-c" "C-x" "M-" "C-M-") eos)) t)
        which-key-replacement-alist))

(defmacro my/leader-keypad (key name)
  "Bind KEY in `my/leader-map' to `hel-leader' entered on KEY, titled NAME."
  `(define-key my/leader-map (kbd ,key)
               (cons ,name (lambda () (interactive) (my/hel-leader-key ,key)))))

(use-package hel-ghostel
  :vc (:url "https://github.com/anuvyklack/hel-ghostel.git" :rev "main")
  :after (hel ghostel))

(use-package hel-org
  :vc (:url "https://github.com/anuvyklack/hel-org.git" :rev "main")
  :after (hel org))

(use-package key-chord
  :after hel
  :config
  (setq key-chord-two-keys-delay 0.18)
  (key-chord-mode 1)
  (key-chord-define hel-insert-state-map "jk" #'hel-normal-state))

(with-eval-after-load 'hel
  (define-key global-map (kbd "H-x") #'execute-extended-command)
  (define-key global-map (kbd "M-/") #'my/comment-dwim)
  ;; Major modes' C-c C-<letter> bindings shadow the global map, so re-bind in
  ;; org explicitly (over org-evaluate-time-range, which we never use).
  (define-key global-map (kbd "C-c C-y") #'my/copy-buffer-to-kill-ring)
  (with-eval-after-load 'org
    (define-key org-mode-map (kbd "C-c C-y") #'my/copy-buffer-to-kill-ring)))

;; ESC aborts any real minibuffer prompt (M-x, find-file, completing-read);
;; without this ESC is just the Meta prefix and dangles.
(define-key minibuffer-local-map (kbd "<escape>") #'abort-minibuffers)

;; ...but `hel-want-minibuffer' nil alone does NOT keep hel out.  ` *Minibuf-N*'
;; buffers already exist in `fundamental-mode' before their first use, and at
;; that point `minibufferp' still returns nil for them -- so hel's own
;; `hel--fundamental-mode-hack' (window-buffer-change-functions, meant for stray
;; empty buffers) turns `hel-local-mode' on there, past every minibufferp guard.
;; `hel-local-mode' is permanent-local, so it then survives into the live prompt
;; and ESC hits hel's insert-state binding (-> Normal) instead of aborting.
;; Switch it off at prompt setup, where the buffer IS a minibuffer.
(defun my/hel-disable-in-minibuffer ()
  "Keep hel out of minibuffer prompts, so ESC aborts instead of switching state."
  (when (bound-and-true-p hel-local-mode) (hel-local-mode -1)))
(add-hook 'minibuffer-setup-hook #'my/hel-disable-in-minibuffer)

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

;; The old meow keypad start-keys, now routed through `hel-leader':
;;   SPC c -> C-c C-   SPC x -> C-x   SPC m -> M-   SPC g -> C-M-
(my/leader-keypad "c" "C-c")
(my/leader-keypad "x" "C-x")
(my/leader-keypad "m" "M-")
(my/leader-keypad "g" "C-M-")

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
  "y" #'my/copy-buffer-to-kill-ring
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
  "s"  #'ace-swap-window
  "m"  #'my/ace-move-window
  "y"  #'my/ace-copy-window
  "h"  #'windmove-left
  "j"  #'windmove-down
  "k"  #'windmove-up
  "l"  #'windmove-right
  "u"  #'winner-undo
  "r"  #'winner-redo
  "f"  #'my/focus-width-mode
  "="  #'balance-windows
  "t"  #'transpose-frame
  ">"  (lambda () (interactive) (my/snap-resize 'x t))
  "<"  (lambda () (interactive) (my/snap-resize 'x nil))
  "+"  (lambda () (interactive) (my/snap-resize 'y t))
  "-"  (lambda () (interactive) (my/snap-resize 'y nil)))

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

(my/leader-prefix "a" "audio"
  "a"   #'mpdel-core-open-artists
  "b"   #'mpdel-browser-open
  "l"   #'mpdel-playlist-open
  "L"   #'mpdel-core-open-stored-playlists
  "v"   #'mpdel-song-open
  "SPC" #'libmpdel-playback-play-pause
  "n"   #'libmpdel-playback-next
  "p"   #'libmpdel-playback-previous
  "s"   #'libmpdel-stop
  "+"   #'mpdel-core-volume-increase
  "-"   #'mpdel-core-volume-decrease)

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
  "t" #'consult-theme
  "f" #'toggle-frame-fullscreen)

(my/leader-prefix "q" "quit"
  "q" #'save-buffers-kill-terminal
  "f" #'my/delete-frame-confirm
  "r" #'my/reload-config)

(provide 'hel-rcp)

;; This file binds commands from many not-yet-loaded packages; silence the
;; resulting "not known to be defined" / free-variable lint noise.
;; Local Variables:
;; byte-compile-warnings: (not unresolved free-vars)
;; End:
;;; hel-rcp.el ends here
