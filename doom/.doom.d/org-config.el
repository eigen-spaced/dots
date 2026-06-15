;;; org-config.el -*- lexical-binding: t; -*-
;; GTD-lite org setup, loaded from config.el. Pieces:
;;   - capture (SPC X) -> inbox.org; refile (C-c C-w) into project/someday/
;;     calendar/reading files
;;   - an agenda "dashboard" (SPC o a g) and a reading-list view (SPC o a r)
;;   - a reading list, capturable from the browser via org-protocol
;;   - org-roam: linked notes + a daily journal
;;   - time clocking
;; Task/agenda files live in ~/org; roam notes in ~/org/roam.

(defun cust/org-file (name)
  "Absolute path of NAME under `org-directory'."
  (expand-file-name name org-directory))

(after! org
  (require 'org-protocol)               ; allow capture from the browser

  (setq
   ;; Files the agenda scans. someday.org is a refile target only (kept out of
   ;; the agenda on purpose).
   org-agenda-files (mapcar #'cust/org-file
                            '("inbox.org" "projects.org" "calendar.org" "reading.org"))

   ;; Workflow states. NEXT = the single next actionable step; WAITING =
   ;; blocked/delegated (logs a note + timestamp).
   org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)"
                        "|" "DONE(d!)" "CANCELLED(c@)"))
   org-log-done 'time
   org-log-into-drawer t

   ;; Refile inbox items into these (C-c C-w).
   org-refile-targets (list (cons (mapcar #'cust/org-file
                                          '("projects.org" "someday.org"
                                            "calendar.org" "reading.org"))
                                  '(:maxlevel . 3)))
   org-refile-use-outline-path 'file
   org-outline-path-complete-in-steps nil
   org-refile-allow-creating-parent-nodes 'confirm

   ;; Capture templates (SPC X). Journaling is org-roam-dailies (below).
   org-capture-templates
   `(("t" "Task"           entry (file ,(cust/org-file "inbox.org"))
      "* TODO %?\n%U" :empty-lines 1)
     ("n" "Note"           entry (file ,(cust/org-file "inbox.org"))
      "* %?\n%U" :empty-lines 1)
     ("l" "Task from here" entry (file ,(cust/org-file "inbox.org"))
      "* TODO %?\n%U\n%a" :empty-lines 1)
     ("r" "Reading item"   entry (file ,(cust/org-file "reading.org"))
      "* TODO %?\n%U" :empty-lines 1)
     ;; Used by the browser bookmarklet via org-protocol. Saves the page's
     ;; title+URL (and any selection) to the reading list instantly — no popup.
     ("w" "Web → reading list" entry (file ,(cust/org-file "reading.org"))
      "* TODO %:annotation\n%U\n%:initial" :immediate-finish t :empty-lines 1))

   ;; Clocking: keep clocks in a drawer, drop zero-time ones, persist history.
   org-clock-into-drawer t
   org-clock-out-remove-zero-time-clocks t
   org-clock-persist 'history

   ;; Agenda views — open the dispatcher with SPC o A, or jump straight in with
   ;; SPC o a g (dashboard) / SPC o a r (reading).
   org-agenda-custom-commands
   '(("g" "GTD dashboard"
      ((agenda "" ((org-agenda-span 'day) (org-deadline-warning-days 7)))
       (todo "NEXT"    ((org-agenda-overriding-header "Next actions")))
       (todo "WAITING" ((org-agenda-overriding-header "Waiting for")))
       (todo "TODO"    ((org-agenda-overriding-header "Inbox — process me")
                        (org-agenda-files
                         (list (expand-file-name "inbox.org" org-directory)))))))
     ("r" "Reading list"
      ((todo "TODO|NEXT" ((org-agenda-overriding-header "To read")
                          (org-agenda-files
                           (list (expand-file-name "reading.org" org-directory)))))))))

  (org-clock-persistence-insinuate))

;; --- Zero-decision global capture (⌘⌥C via Hammerspoon) ---------------------
;; Dedicated inbox template, let-bound to stay out of the SPC X menu; cleanup is
;; frame-name-gated so normal captures aren't deleted.
(defun my/capture-frame ()
  "Pop a centered floating frame and capture one entry straight into inbox.org."
  (interactive)
  ;; `(fullscreen . nil)' overrides the maximized default-frame-alist; ns = GUI
  ;; frame even from a cold daemon.
  (let ((frame (make-frame '((name . "org-capture")
                             (window-system . ns)
                             (fullscreen . nil)
                             (width . 100) (height . 30)))))
    (select-frame-set-input-focus frame)
    (cust/center-frame frame)
    (let ((org-capture-templates
           `(("i" "Inbox (fast)" entry (file ,(cust/org-file "inbox.org"))
              "* %?\n%U\n" :prepend t :empty-lines 0))))
      (condition-case nil
          (progn (org-capture nil "i")
                 (delete-other-windows))   ; only the capture buffer
        (error (delete-frame frame))))))

(defun my/capture-frame-cleanup ()
  "Delete the capture frame on finalize/abort (only the named one)."
  (when (equal (frame-parameter nil 'name) "org-capture")
    (delete-frame)))
(add-hook 'org-capture-after-finalize-hook #'my/capture-frame-cleanup)

;; --- Inbox decay ------------------------------------------------------------
;; Archive (not delete) top-level inbox entries older than the threshold, by
;; their %U timestamp. Age-based ≈ "survived two reviews unacted" — simpler than
;; tracking real reviews (the tradeoff). Manual; untimestamped entries skipped.
(defvar my/org-inbox-stale-days 14
  "Archive inbox entries older than this many days (`my/org-inbox-archive-stale').")

(defun my/org-inbox-archive-stale ()
  "Archive top-level inbox.org entries older than `my/org-inbox-stale-days'."
  (interactive)
  (let ((cutoff (- (float-time) (* my/org-inbox-stale-days 86400)))
        (markers '()) (n 0))
    (with-current-buffer (find-file-noselect (cust/org-file "inbox.org"))
      (org-with-wide-buffer
       (goto-char (point-min))
       (while (re-search-forward "^\\* " nil t)
         (let* ((beg (line-beginning-position))
                (end (save-excursion (org-end-of-subtree t t) (point)))
                (ts  (save-excursion
                       (goto-char beg)
                       (when (re-search-forward
                              "[[<]\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}[^]>]*\\)[]>]" end t)
                         (ignore-errors
                           (float-time (org-time-string-to-time (match-string 1))))))))
           (when (and ts (< ts cutoff)) (push (copy-marker beg) markers))
           (goto-char end)))
       ;; bottom-up so earlier markers stay valid
       (dolist (m (sort markers (lambda (a b) (> (marker-position a) (marker-position b)))))
         (goto-char m)
         (org-archive-subtree)
         (setq n (1+ n))))
      (save-buffer))
    (message "Archived %d stale inbox entr%s (older than %d days)."
             n (if (= n 1) "y" "ies") my/org-inbox-stale-days)))

(map! :leader :desc "Archive stale inbox" "o a x" #'my/org-inbox-archive-stale)

;; --- org-roam: linked notes + daily journal --------------------------------
;; `org-roam-directory' must be set before org-roam loads.
(setq org-roam-directory (cust/org-file "roam")
      org-roam-dailies-directory "daily/")
(after! org-roam
  (setq org-roam-dailies-capture-templates
        '(("d" "default" entry "* %<%H:%M>  %?"
           :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n")))))

;; Leader conveniences. (Doom already gives SPC X = capture, SPC n r = roam,
;; SPC n j = today's daily/journal note.)
(map! :leader
      :desc "GTD dashboard" "o a g" (cmd! (org-agenda nil "g"))
      :desc "Reading list"  "o a r" (cmd! (org-agenda nil "r")))

;; Make browser captures (org-protocol) work even before any org file has been
;; opened this session: load org-protocol shortly after the daemon settles.
;; (It's required in the `after! org' block too, for the in-Emacs path.)
(run-with-idle-timer 2 nil (lambda () (require 'org-protocol nil t)))

;; Insert a source block, choosing the language via completion (vertico).
;; SPC m B in an org buffer.
(defun cust/org-insert-src-block (lang)
  "Insert an Org #+begin_src block for LANG and place point inside it."
  (interactive
   (list (completing-read
          "Source block language: "
          '("emacs-lisp" "shell" "bash" "python" "js" "typescript" "tsx" "json"
            "yaml" "toml" "c" "cpp" "rust" "go" "clojure" "java" "ruby" "lua"
            "sql" "html" "css" "scss" "graphql" "dockerfile" "makefile" "nix"
            "markdown" "org" "text" "conf"))))
  (insert (format "#+begin_src %s\n\n#+end_src\n" lang))
  (forward-line -2)
  (when (fboundp 'evil-insert-state) (evil-insert-state)))

(map! :after org :map org-mode-map :localleader
      :desc "Source block" "B" #'cust/org-insert-src-block)

;; --- reading list: quick add from clipboard + read in Emacs -----------------
(defun cust/url-title (url)
  "Fetch URL and return its <title> (whitespace-collapsed), or nil."
  (ignore-errors
    (with-current-buffer (url-retrieve-synchronously url t t 5)
      (prog1
          (progn
            (goto-char (point-min))
            (when (re-search-forward "<title[^>]*>\\(\\(?:.\\|\n\\)*?\\)</title>" nil t)
              (string-trim (replace-regexp-in-string "[ \t\n\r]+" " " (match-string 1)))))
        (kill-buffer)))))

(defun cust/org-reading-add-from-clipboard ()
  "Add the URL in the clipboard to the reading list, fetching its title.
No capture buffer — copy a link anywhere, switch to Emacs, run this."
  (interactive)
  (let ((url (string-trim (or (ignore-errors (gui-get-selection 'CLIPBOARD))
                              (current-kill 0) ""))))
    (unless (string-match-p "\\`https?://" url)
      (user-error "Clipboard isn't a URL: %S" url))
    (let ((title (replace-regexp-in-string "[][]" "" (or (cust/url-title url) url))))
      (with-current-buffer (find-file-noselect (cust/org-file "reading.org"))
        (goto-char (point-max))
        (unless (bolp) (insert "\n"))
        (insert (format "* TODO [[%s][%s]]\n%s\n" url title
                        (format-time-string "[%Y-%m-%d %a %H:%M]")))
        (save-buffer))
      (message "Reading list ← %s" title))))

(defun cust/org-entry-url ()
  "Return the first http(s) URL in the current org entry, or nil.
Matches both bracket links ([[url][desc]]) and bare URLs, in the heading or
body (the regex stops at \"]\", so it returns a bracket link's target cleanly)."
  (save-excursion
    (org-back-to-heading t)
    (let ((end (save-excursion (org-end-of-subtree t t) (point))))
      (when (re-search-forward "https?://[^][ \t\n\"<>]+" end t)
        (match-string-no-properties 0)))))

(defun cust/org-read-in-eww ()
  "Open the first link in the current org entry in eww, in a clean readable view."
  (interactive)
  (require 'eww)
  (let ((url (cust/org-entry-url)))
    (unless url (user-error "No URL in this entry"))
    ;; Once the page first renders: switch to eww's readable (article) view and
    ;; maximize its window so the article opens full-frame instead of in a split.
    ;; (winner-mode is on, so `SPC w u' brings the previous layout back.)
    (letrec ((hook (lambda ()
                     (remove-hook 'eww-after-render-hook hook)
                     (ignore-errors (eww-readable))
                     (when-let ((win (get-buffer-window (current-buffer))))
                       (delete-other-windows win)))))
      (add-hook 'eww-after-render-hook hook))
    (eww url)))

(map! :leader :desc "Add clipboard URL → reading" "o a R" #'cust/org-reading-add-from-clipboard)
(map! :after org :map org-mode-map :localleader
      :desc "Read entry in eww" "R" #'cust/org-read-in-eww)
;; Note: deliberately NOT binding this under the agenda's localleader — SPC m R
;; there is org-agenda-refile, which is worth keeping. From the reading-list
;; agenda (SPC o a r), press TAB/RET to jump to the entry, then SPC m R.
