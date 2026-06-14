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
