;;; org-rcp.el --- org: GTD capture/agenda/refile, roam, reading list -*- lexical-binding: t; -*-
;; Files in ~/org (roam in ~/org/roam); leader keys live in meow-rcp (SPC n).
;;; Code:
(eval-when-compile (require 'use-package))

(setq org-directory "~/org/")

;; Lean org link backends.  The default pulls ol-gnus -- which drags in the whole
;; Gnus reader (~400ms at the first org load, i.e. the dashboard agenda) -- plus
;; rmail/mhe/bbdb/irc/w3m/bibtex/docview we never use (we're on notmuch).  Re-add
;; any `ol-*' here if you start using its link type.
(setq org-modules '(ol-info ol-eww ol-doi))

(defun my/org-file (name)
  "Absolute path of NAME under `org-directory'."
  (expand-file-name name org-directory))

;;; Serif prose ------------------------------------------------------
(defvar my/org-keep-mono-faces
  '(org-block org-block-begin-line org-block-end-line org-code org-verbatim
              org-table org-formula org-meta-line org-document-info-keyword
              org-special-keyword org-property-value org-drawer
              org-modern-todo org-modern-done org-modern-tag org-modern-priority
              font-lock-comment-face font-lock-comment-delimiter-face
              line-number line-number-current-line)
  "Org faces pinned to `fixed-pitch' (monospace) under `my/org-prose-serif'.")

(defun my/org-prose-serif ()
  "Render org prose in Merriweather (serif); keep code/tables/metadata mono."
  (my/reading-serif)
  (dolist (f my/org-keep-mono-faces)
    (face-remap-add-relative f 'fixed-pitch))
  (variable-pitch-mode 1))

;;; Agenda + reading-list commands -----------------------------------

(defun my/org-gtd-dashboard ()
  "Open the GTD dashboard custom agenda view."
  (interactive) (org-agenda nil "g"))

(defun my/org-reading-list ()
  "Open the reading-list custom agenda view."
  (interactive) (org-agenda nil "r"))

(defvar my/org-inbox-stale-days 14
  "Archive inbox entries older than this many days (`my/org-inbox-archive-stale').")

(defun my/org-inbox-archive-stale ()
  "Archive top-level inbox.org entries older than `my/org-inbox-stale-days'."
  (interactive)
  (let ((cutoff (- (float-time) (* my/org-inbox-stale-days 86400)))
        (markers '()) (n 0))
    (with-current-buffer (find-file-noselect (my/org-file "inbox.org"))
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
       (dolist (m (sort markers (lambda (a b) (> (marker-position a) (marker-position b)))))
         (goto-char m)
         (org-archive-subtree)
         (setq n (1+ n))))
      (save-buffer))
    (message "Archived %d stale inbox entr%s (older than %d days)."
             n (if (= n 1) "y" "ies") my/org-inbox-stale-days)))

(defun my/url-title (url)
  "Fetch URL and return its <title> (whitespace-collapsed), or nil."
  (ignore-errors
    (with-current-buffer (url-retrieve-synchronously url t t 5)
      (prog1
          (progn
            (goto-char (point-min))
            (when (re-search-forward "<title[^>]*>\\(\\(?:.\\|\n\\)*?\\)</title>" nil t)
              (string-trim (replace-regexp-in-string "[ \t\n\r]+" " " (match-string 1)))))
        (kill-buffer)))))

(defun my/org-reading-add-from-clipboard ()
  "Add the URL in the clipboard to the reading list, fetching its title.
No capture buffer — copy a link anywhere, switch to Emacs, run this."
  (interactive)
  (let ((url (string-trim (or (ignore-errors (gui-get-selection 'CLIPBOARD))
                              (current-kill 0) ""))))
    (unless (string-match-p "\\`https?://" url)
      (user-error "Clipboard isn't a URL: %S" url))
    (let ((title (replace-regexp-in-string "[][]" "" (or (my/url-title url) url))))
      (with-current-buffer (find-file-noselect (my/org-file "reading.org"))
        (goto-char (point-max))
        (unless (bolp) (insert "\n"))
        (insert (format "* TODO [[%s][%s]]\n%s\n" url title
                        (format-time-string "[%Y-%m-%d %a %H:%M]")))
        (save-buffer))
      (message "Reading list ← %s" title))))

(defun my/org-entry-url ()
  "Return the first http(s) URL in the current org entry, or nil."
  (save-excursion
    (org-back-to-heading t)
    (let ((end (save-excursion (org-end-of-subtree t t) (point))))
      (when (re-search-forward "https?://[^][ \t\n\"<>]+" end t)
        (match-string-no-properties 0)))))

(defun my/org-read-in-eww ()
  "Open the first link in the current org entry in eww, in a readable view."
  (interactive)
  (require 'eww)
  (let ((url (my/org-entry-url)))
    (unless url (user-error "No URL in this entry"))
    (letrec ((hook (lambda ()
                     (remove-hook 'eww-after-render-hook hook)
                     (ignore-errors (eww-readable))
                     (when-let* ((win (get-buffer-window (current-buffer))))
                       (delete-other-windows win)))))
      (add-hook 'eww-after-render-hook hook))
    (eww url)))

(defun my/org-insert-src-block (lang)
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
  (when (fboundp 'meow-insert-mode) (meow-insert-mode 1)))

;;; Inline images, on demand -----------------------------------------

;; Images stay hidden until asked for (org 9.8's link-preview machinery; the
;; stock C-c C-x C-v is still there with its finer prefix-arg variants):
;; C-c v shows/hides every image in the buffer, and my/org-image-peek-mode
;; previews just the link under the cursor, hiding it again on the way out.

(defun my/org-toggle-images ()
  "Show every inline image in the buffer; hide them all if any are shown."
  (interactive)
  (if (seq-some (lambda (ov) (overlay-get ov 'org-image-overlay))
                (overlays-in (point-min) (point-max)))
      (org-link-preview-clear (point-min) (point-max))
    (org-link-preview-region t nil (point-min) (point-max))))

(defvar-local my/org--image-peek-bounds nil
  "Bounds (BEG . END) of the link auto-previewed by `my/org-image-peek-mode'.")

(defun my/org--image-peek ()
  "Preview the image link at point; hide it again once point moves off."
  ;; Skip while typing: each keystroke inside a link would clear and re-render
  ;; the preview (the overlay's modification hook removes it on edit).
  (unless (memq this-command '(self-insert-command org-self-insert-command
                                                   org-delete-backward-char delete-backward-char))
    (let* ((link (org-element-lineage (org-element-context) 'link t))
           (bounds (and link (cons (org-element-begin link)
                                   (org-element-end link)))))
      (unless (equal bounds my/org--image-peek-bounds)
        (when my/org--image-peek-bounds
          (org-link-preview-clear (car my/org--image-peek-bounds)
                                  (cdr my/org--image-peek-bounds))
          (setq my/org--image-peek-bounds nil))
        ;; Only peek links nothing else is previewing, so images shown by the
        ;; buffer-wide toggle don't get cleared when the cursor passes through.
        (when (and bounds
                   (not (seq-some (lambda (ov) (overlay-get ov 'org-image-overlay))
                                  (overlays-in (car bounds) (cdr bounds)))))
          (org-link-preview-region t nil (car bounds) (cdr bounds))
          (setq my/org--image-peek-bounds bounds))))))

(define-minor-mode my/org-image-peek-mode
  "Show the image for the link at point, hiding it when the cursor leaves."
  :lighter nil
  (if my/org-image-peek-mode
      (add-hook 'post-command-hook #'my/org--image-peek nil t)
    (remove-hook 'post-command-hook #'my/org--image-peek t)
    (when my/org--image-peek-bounds
      (org-link-preview-clear (car my/org--image-peek-bounds)
                              (cdr my/org--image-peek-bounds))
      (setq my/org--image-peek-bounds nil))))

;;; Global floating-frame capture (for a window-manager hotkey) ------

(defun my/center-frame (frame)
  "Center FRAME on its monitor's workarea."
  (let* ((wa (frame-monitor-workarea frame))
         (mx (nth 0 wa)) (my (nth 1 wa)) (mw (nth 2 wa)) (mh (nth 3 wa)))
    (set-frame-position frame
                        (+ mx (/ (- mw (frame-pixel-width frame)) 2))
                        (+ my (/ (- mh (frame-pixel-height frame)) 2)))))

(defun my/capture-frame ()
  "Pop a centered floating frame and capture one entry straight into inbox.org."
  (interactive)
  ;; Load org-capture first so `org-capture-templates' is declared special
  ;; before we let-bind it -- otherwise (under lexical-binding) the let binds it
  ;; lexically and loading org-capture errors ("already lexical var").
  (require 'org-capture)
  (let ((frame (make-frame '((name . "org-capture")
                             (window-system . ns)
                             (fullscreen . nil)
                             (width . 100) (height . 30)))))
    (select-frame-set-input-focus frame)
    (my/center-frame frame)
    (let ((org-capture-templates
           `(("i" "Inbox (fast)" entry (file ,(my/org-file "inbox.org"))
              "* %?\n%U\n" :prepend t :empty-lines 0))))
      (condition-case nil
          (progn (org-capture nil "i")
                 (delete-other-windows))
        (error (delete-frame frame))))))

(defun my/capture-frame-cleanup ()
  "Delete the capture frame on finalize/abort (only the named one)."
  (when (equal (frame-parameter nil 'name) "org-capture")
    (delete-frame)))

;;; org ---------------------------------------------------------------

;; Pop the agenda dispatcher (` *Agenda Commands*') at the bottom, full-width,
;; instead of splitting the current window sideways (Doom-like).
(add-to-list 'display-buffer-alist
             '("\\*Agenda Commands\\*"
               (display-buffer-at-bottom)
               (window-height . fit-window-to-buffer)))

(use-package org
  :ensure nil
  :commands (org-capture org-agenda org-store-link org-todo-list)
  :hook ((org-mode . visual-line-mode)
         (org-mode . my/org-image-peek-mode))
  :custom
  (org-agenda-files (mapcar #'my/org-file
                            '("inbox.org" "projects.org" "calendar.org" "reading.org")))
  (org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)"
                                 "|" "DONE(d!)" "CANCELLED(c@)")))
  (org-log-done 'time)
  (org-log-into-drawer t)
  ;; Virtual indentation: body text lines up under its heading (org-indent-mode;
  ;; buffer text stays flush-left on disk).  Also hides the leading stars.
  (org-startup-indented t)
  ;; Inline images render at 60% of the window width, unless an
  ;; #+ATTR_ORG: :width overrides it per image.
  (org-image-actual-width '(0.6))
  (org-refile-targets (list (cons (mapcar #'my/org-file
                                          '("projects.org" "someday.org"
                                            "calendar.org" "reading.org"))
                                  '(:maxlevel . 3))))
  (org-refile-use-outline-path 'file)
  (org-outline-path-complete-in-steps nil)
  (org-refile-allow-creating-parent-nodes 'confirm)
  (org-capture-templates
   `(("t" "Task"           entry (file ,(my/org-file "inbox.org"))
      "* TODO %?\n%U" :empty-lines 1)
     ("n" "Note"           entry (file ,(my/org-file "inbox.org"))
      "* %?\n%U" :empty-lines 1)
     ("l" "Task from here" entry (file ,(my/org-file "inbox.org"))
      "* TODO %?\n%U\n%a" :empty-lines 1)
     ("r" "Reading item"   entry (file ,(my/org-file "reading.org"))
      "* TODO %?\n%U" :empty-lines 1)
     ("w" "Web → reading list" entry (file ,(my/org-file "reading.org"))
      "* TODO %:annotation\n%U\n%:initial" :immediate-finish t :empty-lines 1)))
  (org-clock-into-drawer t)
  (org-clock-out-remove-zero-time-clocks t)
  (org-clock-persist 'history)
  (org-agenda-custom-commands
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
  :config
  (org-clock-persistence-insinuate)
  (add-hook 'org-capture-after-finalize-hook #'my/capture-frame-cleanup)
  (define-key org-mode-map (kbd "C-c i") #'my/org-insert-src-block)
  (define-key org-mode-map (kbd "C-c e") #'my/org-read-in-eww)
  (define-key org-mode-map (kbd "C-c v") #'my/org-toggle-images))

;; org-modern, a subset: static bullet stars (✿ ◉ ○ ◈ ✸), #+begin_src labels,
;; and TODO/tag/priority badges (faces pinned mono in `my/org-keep-mono-faces').
;; Everything else (tables, timestamps, lists, checkboxes, keywords, ...)
;; stays stock org.
(use-package org-modern
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-star 'replace)
  (org-modern-replace-stars "✿◉○◈✸")
  (org-modern-timestamp nil)
  (org-modern-table nil)
  (org-modern-list nil)
  (org-modern-checkbox nil)
  (org-modern-horizontal-rule nil)
  (org-modern-keyword nil)
  (org-modern-footnote nil)
  (org-modern-internal-target nil)
  (org-modern-radio-target nil)
  (org-modern-progress nil))

;; org-modern's block bracket is drawn in the fringe, which org-indent's line
;; prefixes defeat (org-modern auto-disables it); this draws the bracket in the
;; indent prefix instead.  GitHub-only package, hence :vc.  Hook depth 90: must
;; run after org-indent and org-modern have set up.
(use-package org-modern-indent
  :vc (:url "https://github.com/jdtsmith/org-modern-indent" :rev :newest)
  :defer t
  :init
  (add-hook 'org-mode-hook #'org-modern-indent-mode 90))

;;; org-roam: linked notes + daily journal ---------------------------

(use-package org-roam
  :commands (org-roam-node-find org-roam-node-insert org-roam-buffer-toggle
                                org-roam-dailies-goto-today)
  :custom
  (org-roam-directory (my/org-file "roam"))
  (org-roam-dailies-directory "daily/")
  (org-roam-dailies-capture-templates
   '(("d" "default" entry "* %<%H:%M>  %?"
      :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))))
  :config
  (require 'org-id)
  (org-roam-db-autosync-mode)
  ;; Build org-id's machine-local location cache (~/.config/emacs/.org-id-locations,
  ;; gitignored) from the roam files once.  The daemon rarely exits, so org-id
  ;; never auto-saves it otherwise and warns it's missing on every id: resolve.
  (unless (file-exists-p org-id-locations-file)
    (run-with-idle-timer 2 nil #'org-roam-update-org-id-locations)))

;; Browser captures (org-protocol) should work before any org file is opened.
(run-with-idle-timer 2 nil (lambda () (require 'org-protocol nil t)))

(provide 'org-rcp)
;;; org-rcp.el ends here
