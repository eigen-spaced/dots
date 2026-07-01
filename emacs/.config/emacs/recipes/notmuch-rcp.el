;;; notmuch-rcp.el --- notmuch mail: sync, tags, SMTP, serif -*- lexical-binding: t; -*-
;; External: mbsync + afew + notmuch; secrets in Keychain, identity in private.el.
;;; Code:
(eval-when-compile (require 'use-package))

;; afew's notmuch binding dlopen's libnotmuch by bare name from /opt/homebrew/lib
;; (off the default search path), and macOS SIP strips DYLD_* across the shell
;; exec — so the `export' must live inside the command, before the python child.
(defvar my/notmuch-sync-command
  (concat "export DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib "
          "PYTHONWARNINGS=ignore::UserWarning; "
          "afew --move-mails && mbsync -a && notmuch new && afew --tag --new")
  "Shell command that moves tagged mail, syncs, indexes, and tags new mail.")

(defun my/notmuch-update ()
  "Sync mail with `my/notmuch-sync-command', then refresh this notmuch buffer."
  (interactive)
  (message "notmuch: syncing…")
  (let ((buf (current-buffer))
        (default-directory "~/"))
    (set-process-sentinel
     (start-process-shell-command "notmuch-update" "*notmuch-update*" my/notmuch-sync-command)
     (lambda (_proc event)
       (when (string-prefix-p "finished" event)
         (when (buffer-live-p buf)
           (with-current-buffer buf
             (when (derived-mode-p 'notmuch-hello-mode 'notmuch-search-mode 'notmuch-tree-mode)
               (notmuch-refresh-this-buffer))))
         (message "notmuch: sync complete"))))))

(defun my/notmuch-prose-serif ()
  "Render the notmuch message view in Merriweather (serif)."
  (my/reading-serif)
  (variable-pitch-mode 1))

;;; Address completion ----------------------------------------------
;; notmuch completes contacts via a `completing-read' on TAB, which corfu can't
;; drive -- the minibuffer pops up modally and eats keystrokes.  A real capf
;; lists contacts inline instead (type freely, C-n/C-p to move, RET to insert).
(defun my/notmuch-address-capf ()
  "`completion-at-point' for notmuch contacts on header lines."
  (when (and (derived-mode-p 'message-mode)
             (save-excursion (beginning-of-line)
                             (looking-at-p notmuch-address-completion-headers-regexp)))
    (let* ((end (point))
           (beg (save-excursion
                  (re-search-backward "\\(\\`\\|[\n:,]\\)[ \t]*")
                  (goto-char (match-end 0))
                  (point))))
      ;; Exclusive (no `:exclusive no') so notmuch's own completing-read never runs.
      (list beg end (completion-table-dynamic #'notmuch-address-options)))))

(defun my/notmuch-address-setup-capf ()
  "Use `my/notmuch-address-capf' for address completion in compose buffers."
  (require 'notmuch-address)
  (add-hook 'completion-at-point-functions #'my/notmuch-address-capf -50 t))

(defun my/mail-shr-no-colors (orig &rest args)
  "Render HTML mail without the message's own colours (use theme faces)."
  (let ((shr-use-colors nil))
    (apply orig args)))

(defun my/notmuch-hide-image-parts (args)
  "Advice (`:filter-args') to start image body parts collapsed to a button.
notmuch has no built-in knob for this, so force HIDE=t for `image/*' parts in
`notmuch-show-insert-bodypart'.  RET on the button toggles each image in/out --
keeps image-heavy mail scrollable and avoids paying image redisplay until asked."
  (let ((part (nth 1 args)))
    (if (and part (string-prefix-p "image/" (or (notmuch-show-mime-type part) "")))
        (list (nth 0 args) part (nth 2 args) t)
      args)))

;;; Reading pane: focus follows into the message --------------------
;; Both views should behave like a 3-pane mail client: open a message in a
;; ~70% pane and move the cursor into it so you can scroll/read at once.

(defun my/notmuch-tree-follow (&rest _)
  "Move focus into the tree's message pane after `RET' opens it.
Only `notmuch-tree-show-message' (RET) is advised -- `n'/`p' navigation calls
`notmuch-show-message-in' directly, so browsing keeps focus in the list."
  (when (window-live-p notmuch-tree-message-window)
    (select-window notmuch-tree-message-window)))

;; Search view has no preview pane of its own, so replicate notmuch-tree's:
;; split ~30/70, show the thread in the bottom pane via a direct `notmuch-show'
;; (wrapping `notmuch-search-show-thread' instead makes notmuch-show open a
;; stray third window), and hang a kill-buffer-hook that deletes the pane when
;; the message dies -- so `q' tears the pane down cleanly instead of surfacing
;; buried buffers.  The pane window is remembered for reuse on repeated RET.
(defvar-local my/notmuch-search-pane-window nil
  "Reading-pane window opened from this search buffer.")

(defun my/notmuch-search-pane-kill-hook ()
  "Delete the search reading pane when its message buffer is killed."
  (when (and (window-live-p my/notmuch-search-pane-window)
             (eq (window-buffer my/notmuch-search-pane-window) (current-buffer)))
    (ignore-errors (delete-window my/notmuch-search-pane-window))))

(defun my/notmuch-search-show-in-split (&optional elide-toggle)
  "Show the selected thread in a ~70% bottom pane, cursor following into it.
Reuse the pane if already open; `q' in the message deletes the pane and
returns to the list (see `my/notmuch-search-pane-kill-hook')."
  (interactive "P")
  (let ((thread-id (notmuch-search-find-thread-id))
        (subject (notmuch-search-find-subject))
        (query notmuch-search-query-string)
        (search-buf (current-buffer)))
    (if (not thread-id)
        (progn (message "End of search results.") nil)
      ;; Immediate "marked read" feedback like notmuch-tree: strike `unread'
      ;; through on the search line (display only; the pane marks the db read).
      (let ((new-tags (notmuch-update-tags (notmuch-search-get-tags)
                                           notmuch-show-mark-read-tags)))
        (unless (equal new-tags (notmuch-search-get-tags))
          (notmuch-search-set-tags new-tags)))
      (let ((win (if (window-live-p my/notmuch-search-pane-window)
                     my/notmuch-search-pane-window
                   (split-window-vertically (max 1 (round (* 0.3 (window-height))))))))
        (with-selected-window win
          (let ((display-buffer-overriding-action
                 '((display-buffer-same-window) (inhibit-same-window . nil))))
            (notmuch-show thread-id elide-toggle search-buf query
                          (format "*%s*" (truncate-string-to-width subject 30 nil nil t))))
          (setq-local my/notmuch-search-pane-window win)
          (add-hook 'kill-buffer-hook #'my/notmuch-search-pane-kill-hook nil t))
        (with-current-buffer search-buf
          (setq my/notmuch-search-pane-window win))
        (select-window win)
        t))))

;;; Sign-off picker -------------------------------------------------
;; A few sign-offs keyed by a short label; pick one by completion and drop it
;; at point.  Override `my/message-signoffs' in private.el with your real
;; sign-offs (those carry your name, so they stay out of the tracked repo).
(defvar my/message-signoffs
  '(("Formal" . "Kind regards,\n")
    ("Warm"   . "Cheers,\n")
    ("Brief"  . "Thanks,\n"))
  "Alist of (LABEL . TEXT) sign-offs for `my/message-insert-signoff'.")

(defun my/message-insert-signoff ()
  "Pick a sign-off by label and insert it at point."
  (interactive)
  (let ((text (cdr (assoc (completing-read "Sign-off: " my/message-signoffs nil t)
                          my/message-signoffs))))
    (when text (insert text))))

;;; Reversible trash + unread toggles -------------------------------
;; All call notmuch's own tag functions, which redraw the line themselves:
;; `!' toggles +unread/-unread; `d' toggles trash (a compound +trash -inbox
;; -unread that the single-tag +/- keys can't do in one stroke).  Plain +/- and
;; `*' stay available for arbitrary or region tagging.

(defun my/notmuch-search-toggle-trash ()
  "Toggle the trash mark on the thread at point; advance when trashing."
  (interactive)
  (if (member "trash" (notmuch-search-get-tags))
      (notmuch-search-tag '("-trash" "+inbox"))
    (notmuch-search-tag '("+trash" "-inbox" "-unread"))
    (notmuch-search-next-thread)))

(defun my/notmuch-tree-toggle-trash ()
  "Toggle the trash mark on the message at point (tree view)."
  (interactive)
  (if (member "trash" (notmuch-tree-get-tags))
      (notmuch-tree-tag '("-trash" "+inbox"))
    (notmuch-tree-tag '("+trash" "-inbox" "-unread"))
    (notmuch-tree-next-message)))

(defun my/notmuch-show-toggle-trash ()
  "Toggle the trash mark on the current message."
  (interactive)
  (if (member "trash" (notmuch-show-get-tags))
      (notmuch-show-tag '("-trash" "+inbox"))
    (notmuch-show-tag '("+trash" "-inbox" "-unread"))))

(defun my/notmuch-search-toggle-unread ()
  "Toggle the unread tag on the thread at point via notmuch's own tagging."
  (interactive)
  (notmuch-search-tag
   (if (member "unread" (notmuch-search-get-tags)) '("-unread") '("+unread"))))

(defun my/notmuch-tree-toggle-unread ()
  "Toggle the unread tag on the message at point via notmuch's own tagging."
  (interactive)
  (notmuch-tree-tag
   (if (member "unread" (notmuch-tree-get-tags)) '("-unread") '("+unread"))))

;;; Background auto-sync every 5 min ---------------------------------

(defvar my/notmuch-sync-timer nil)

(defun my/notmuch-auto-sync ()
  "Sync mail quietly in the background; refresh manually with `g'."
  (unless (process-live-p (get-process "notmuch-autosync"))
    (let ((default-directory "~/"))
      (start-process-shell-command "notmuch-autosync" nil my/notmuch-sync-command))))

;;; notmuch ----------------------------------------------------------

(use-package notmuch
  :commands (notmuch notmuch-search notmuch-tree)
  :hook (notmuch-show-mode . my/notmuch-prose-serif)
  :custom
  (notmuch-fcc-dirs nil)                 ; Gmail keeps its own Sent copy
  (notmuch-draft-folder "gmail/[Gmail]/Drafts") ; C-x C-s saves drafts here (synced to Gmail)
  (notmuch-search-oldest-first nil)      ; newest mail first
  ;; Pad AND truncate each field to a fixed width (the `.N' precision caps the
  ;; length) so the tags land in their own right-hand column (Doom's layout)
  ;; instead of a long subject/author trailing past them.
  (notmuch-search-result-format
   '(("date"    . "%12s ")
     ("count"   . "%-7s ")
     ("authors" . "%-30.30s ")
     ("subject" . "%-67.67s ")
     ("tags"    . "(%s)")))
  ;; Same fix for tree view, which uses its own format var: the default pads
  ;; but never truncates (`%-20s'/`%-54s'), so long authors/subjects shove the
  ;; tags column away.  Add the `.N' cap.  Subject shares its field with the
  ;; thread-tree drawing, so deep threads eat into subject width (expected).
  (notmuch-tree-result-format
   '(("date"    . "%12s  ")
     ("authors" . "%-30.30s")
     ((("tree" . "%s") ("subject" . "%s")) . " %-64.64s ")
     ("tags"    . "(%s)")))
  (notmuch-saved-searches
   '((:name "inbox"   :query "tag:inbox"                :key "i")
     (:name "unread"  :query "tag:unread and tag:inbox" :key "u")
     (:name "flagged" :query "tag:flagged"              :key "f")
     (:name "today"   :query "date:today and tag:inbox" :key "t")
     (:name "sent"    :query "tag:sent"                 :key "s")
     (:name "drafts"  :query "tag:draft"                :key "d")
     (:name "all"     :query "*"                        :key "a")))
  :config
  ;; afew lives in ~/.local/bin — put it on PATH for Emacs subprocesses.
  (let ((bin (expand-file-name "~/.local/bin")))
    (add-to-list 'exec-path bin)
    (unless (string-match-p (regexp-quote bin) (or (getenv "PATH") ""))
      (setenv "PATH" (concat bin ":" (getenv "PATH")))))

  ;; HTML mail via shr; send via Gmail SMTP.  setq (not :custom) because these
  ;; libraries load with notmuch, not at startup.  Identity from private.el.
  (require 'smtpmail)
  (setq mail-user-agent 'notmuch-user-agent ; compose-mail composes with notmuch, not Gnus
        mm-text-html-renderer 'shr
        message-send-mail-function #'smtpmail-send-it
        send-mail-function #'smtpmail-send-it
        smtpmail-smtp-user user-mail-address
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        smtpmail-stream-type 'starttls)
  ;; The Gmail app-password lives in the macOS Keychain; the default `auth-sources'
  ;; only checks ~/.authinfo*, so add the Keychain (mbsync reads the same entry).
  (add-to-list 'auth-sources 'macos-keychain-internet)

  (add-to-list 'notmuch-search-line-faces '("trash" . dired-flagged) t)
  (advice-add 'mm-shr :around #'my/mail-shr-no-colors)
  (advice-add 'notmuch-show-insert-bodypart :filter-args #'my/notmuch-hide-image-parts)
  ;; Reading pane + focus follow (see functions above).  Tree: advise RET only
  ;; (n/p keep focus in the list).  Search: rebind RET to our pane command,
  ;; leaving `notmuch-search-show-thread' intact for programmatic callers.
  (advice-add 'notmuch-tree-show-message :after #'my/notmuch-tree-follow)
  (define-key notmuch-search-mode-map (kbd "RET") #'my/notmuch-search-show-in-split)

  ;; A notmuch-show buffer with an inline image pegged the daemon at 100%% CPU
  ;; when point reached the image's line near the window edge.  notmuch's
  ;; post-command `(redisplay)' (notmuch-show-command-hook) re-runs the "make
  ;; the cursor line fully visible" scroll logic, which can't settle on a line
  ;; holding a tall-ish image at a window boundary -- redisplay_window/try_window
  ;; spins forever (bidi in the trace is just the incidental per-iteration cost).
  ;; Root-caused via `sample': it was never long lines or image *size* (the
  ;; image was 372x477).  Letting the cursor line be partially visible and
  ;; disabling auto-vscroll in mail buffers stops the loop.
  (add-hook 'notmuch-show-mode-hook
            (lambda ()
              (setq-local make-cursor-line-fully-visible nil
                          auto-window-vscroll nil)))

  (dolist (map (list notmuch-search-mode-map notmuch-tree-mode-map
                     notmuch-show-mode-map notmuch-hello-mode-map))
    (define-key map (kbd "U") #'my/notmuch-update)
    (define-key map (kbd "J") #'notmuch-jump-search))
  (define-key notmuch-search-mode-map (kbd "d") #'my/notmuch-search-toggle-trash)
  (define-key notmuch-search-mode-map (kbd "!") #'my/notmuch-search-toggle-unread)
  (define-key notmuch-tree-mode-map   (kbd "d") #'my/notmuch-tree-toggle-trash)
  (define-key notmuch-tree-mode-map   (kbd "!") #'my/notmuch-tree-toggle-unread)
  (define-key notmuch-show-mode-map   (kbd "d") #'my/notmuch-show-toggle-trash)

  (add-hook 'message-mode-hook #'my/notmuch-address-setup-capf)

  (when (timerp my/notmuch-sync-timer) (cancel-timer my/notmuch-sync-timer))
  (setq my/notmuch-sync-timer (run-with-timer 300 300 #'my/notmuch-auto-sync)))

;; `mml-preview' (C-c C-m P) renders the outgoing MIME in a popup, but binds `q'
;; to a bare `kill-buffer' -- which kills the preview buffer yet leaves its window
;; behind, now showing the compose buffer.  Rebind `q' to `quit-window' so it
;; kills the preview AND restores the pre-preview window layout.
(defun my/mml-preview-quit ()
  "Kill the MIME preview and restore the pre-preview window layout."
  (interactive)
  (quit-window t))

(with-eval-after-load 'message
  (define-key message-mode-map (kbd "C-c C-z") #'my/message-insert-signoff))

;; Attaching dired's marked files with `gnus-dired-attach' and declining "attach
;; to existing buffer?" makes it compose a NEW message via `gnus-dired-mail-mode'
;; -- which defaults to `gnus-user-agent' and boots full Gnus (the *Group* buffer
;; + an nntp news-server error).  Point it at notmuch so "no" composes here.
(with-eval-after-load 'gnus-dired
  (setq gnus-dired-mail-mode 'notmuch-user-agent))

(with-eval-after-load 'mml
  (defun my/mml-preview-quit-restores-window (&rest _)
    (when (and (boundp 'mml-preview-buffer) (buffer-live-p mml-preview-buffer))
      (with-current-buffer mml-preview-buffer
        (local-set-key "q" #'my/mml-preview-quit))))
  (advice-add 'mml-preview :after #'my/mml-preview-quit-restores-window))

(provide 'notmuch-rcp)
;;; notmuch-rcp.el ends here
