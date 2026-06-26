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
  ;; Pad each field to a fixed width so the tags land in their own right-hand
  ;; column (Doom's layout) instead of trailing each subject.
  (notmuch-search-result-format
   '(("date"    . "%12s ")
     ("count"   . "%-7s ")
     ("authors" . "%-30s ")
     ("subject" . "%-72s ")
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
  (setq mm-text-html-renderer 'shr
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

(with-eval-after-load 'mml
  (defun my/mml-preview-quit-restores-window (&rest _)
    (when (and (boundp 'mml-preview-buffer) (buffer-live-p mml-preview-buffer))
      (with-current-buffer mml-preview-buffer
        (local-set-key "q" #'my/mml-preview-quit))))
  (advice-add 'mml-preview :after #'my/mml-preview-quit-restores-window))

(provide 'notmuch-rcp)
;;; notmuch-rcp.el ends here
