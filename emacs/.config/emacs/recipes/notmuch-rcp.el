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

(defun my/mail-shr-no-colors (orig &rest args)
  "Render HTML mail without the message's own colours (use theme faces)."
  (let ((shr-use-colors nil))
    (apply orig args)))

;;; Reversible trash + read/unread toggles --------------------------

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
  "Toggle the unread tag on the thread at point."
  (interactive)
  (if (member "unread" (notmuch-search-get-tags))
      (notmuch-search-tag '("-unread"))
    (notmuch-search-tag '("+unread")))
  (when-let* ((result (notmuch-search-get-result)))
    (notmuch-search-update-result
     (plist-put result :orig-tags (plist-get result :tags)))))

(defun my/notmuch-tree-toggle-unread ()
  "Toggle the unread tag on the message at point (tree view)."
  (interactive)
  (if (member "unread" (notmuch-tree-get-tags))
      (notmuch-tree-tag '("-unread"))
    (notmuch-tree-tag '("+unread")))
  (notmuch-tree-set-prop :orig-tags (notmuch-tree-get-prop :tags))
  (notmuch-tree-refresh-result))

(defun my/notmuch-refresh-parent-search ()
  "Refresh the search buffer a thread was opened from, when the thread is killed."
  (when (and (buffer-live-p notmuch-show-parent-buffer)
             (not (get-buffer-process notmuch-show-parent-buffer)))
    (with-current-buffer notmuch-show-parent-buffer
      (notmuch-refresh-this-buffer))))

;;; Background auto-sync every 5 min ---------------------------------

(defvar my/notmuch-sync-timer nil)

(defun my/notmuch-auto-sync ()
  "Run the notmuch sync quietly, then refresh unfocused notmuch buffers."
  (unless (process-live-p (get-process "notmuch-autosync"))
    (let ((default-directory "~/"))
      (set-process-sentinel
       (start-process-shell-command "notmuch-autosync" nil my/notmuch-sync-command)
       (lambda (_proc event)
         (when (string-prefix-p "finished" event)
           (dolist (buf (buffer-list))
             (with-current-buffer buf
               (when (and (memq major-mode '(notmuch-hello-mode notmuch-search-mode notmuch-tree-mode))
                          (not (eq buf (window-buffer (selected-window)))))
                 (notmuch-refresh-this-buffer))))))))))

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

  ;; notmuch buffers run in meow Motion (set in `meow-mode-state-list', meow-rcp)
  ;; so the mode's own single-key bindings (d, U, J, !) pass through.
  (define-key notmuch-search-mode-map (kbd "d") #'my/notmuch-search-toggle-trash)
  (define-key notmuch-search-mode-map (kbd "!") #'my/notmuch-search-toggle-unread)
  (define-key notmuch-search-mode-map (kbd "U") #'my/notmuch-update)
  (define-key notmuch-search-mode-map (kbd "J") #'notmuch-jump-search)
  (define-key notmuch-tree-mode-map   (kbd "d") #'my/notmuch-tree-toggle-trash)
  (define-key notmuch-tree-mode-map   (kbd "!") #'my/notmuch-tree-toggle-unread)
  (define-key notmuch-tree-mode-map   (kbd "U") #'my/notmuch-update)
  (define-key notmuch-tree-mode-map   (kbd "J") #'notmuch-jump-search)
  (define-key notmuch-show-mode-map   (kbd "d") #'my/notmuch-show-toggle-trash)
  (define-key notmuch-show-mode-map   (kbd "U") #'my/notmuch-update)
  (define-key notmuch-show-mode-map   (kbd "J") #'notmuch-jump-search)
  (define-key notmuch-hello-mode-map  (kbd "U") #'my/notmuch-update)
  (define-key notmuch-hello-mode-map  (kbd "J") #'notmuch-jump-search)

  (add-hook 'notmuch-show-mode-hook
            (lambda () (add-hook 'kill-buffer-hook #'my/notmuch-refresh-parent-search nil t)))

  (when (timerp my/notmuch-sync-timer) (cancel-timer my/notmuch-sync-timer))
  (setq my/notmuch-sync-timer (run-with-timer 300 300 #'my/notmuch-auto-sync)))

(provide 'notmuch-rcp)
;;; notmuch-rcp.el ends here
