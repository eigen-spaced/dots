;;; modeline-rcp.el --- native Emacs mode line, rearranged (no doom-modeline) -*- lexical-binding: t; -*-
;; Left:  modified flag, project-relative path + file, git branch, position.
;; Right: encoding, workspace, filetype  (Emacs 30 `mode-line-format-right-align').
;; Just the stock constructs, reordered, with a few small :eval helpers.
;; Loads after ui-rcp (nerd-icons) and project-rcp (projectile).
;;; Code:
(require 'nerd-icons)

(defvar my/mode-line-git-icon
  (if (fboundp 'nerd-icons-octicon)
      (nerd-icons-octicon "nf-oct-git_branch" :height 0.9)
    "")
  "Cached branch glyph for the mode line.")

(defvar-local my/mode-line-filetype-icon nil
  "Buffer-local cache of the filetype glyph, refreshed on mode change.")
(defun my/mode-line-refresh-filetype-icon ()
  (setq my/mode-line-filetype-icon (ignore-errors (nerd-icons-icon-for-buffer))))
(add-hook 'after-change-major-mode-hook #'my/mode-line-refresh-filetype-icon)

(defface my/mode-line-file
  '((t :inherit font-lock-string-face :weight bold))
  "Mode-line face for the file name (theme's string colour, bold).")
(defface my/mode-line-path
  '((t :inherit shadow))
  "Mode-line face for the directory portion of the path.")
(defface my/mode-line-modified
  '((t :inherit warning))
  "Mode-line face for the unsaved [+] indicator.")
(defface my/mode-line-macro
  '((t :inherit error :weight bold))
  "Mode-line face for the macro-recording indicator (red).")

(defvar my/mode-line-macro-record-icon
  (if (fboundp 'nerd-icons-mdicon)
      (nerd-icons-mdicon "nf-md-record" :face 'my/mode-line-macro)
    (propertize "●" 'face 'my/mode-line-macro))
  "Red dot shown while a kbd macro is being recorded or run.")

(defun my/mode-line-buffer ()
  "Project-relative path + file name, with a [+] flag when unsaved."
  (if buffer-file-name
      (let* ((root (and (fboundp 'projectile-project-root)
                        (ignore-errors (projectile-project-root))))
             (full (expand-file-name buffer-file-name))
             (path (if (and root (string-prefix-p (expand-file-name root) full))
                       (file-relative-name full root)
                     (abbreviate-file-name full)))
             (dir (or (file-name-directory path) "")))
        (concat (propertize dir 'face 'my/mode-line-path)
                (propertize (file-name-nondirectory path) 'face 'my/mode-line-file)
                (when (buffer-modified-p)
                  (propertize " [+]" 'face 'my/mode-line-modified))))
    (propertize (format-mode-line "%b") 'face 'my/mode-line-file)))

(defun my/mode-line-macro ()
  "A red dot while recording/running a kbd macro.
Plain kmacro has no register name during recording, so the dot is all we show."
  (when (or defining-kbd-macro executing-kbd-macro)
    (concat my/mode-line-macro-record-icon " ")))

(defun my/mode-line-vc ()
  "Current Git branch with an icon, or nil outside version control."
  (when (and vc-mode buffer-file-name)
    (concat "  " my/mode-line-git-icon " "
            (string-trim (replace-regexp-in-string "\\` *Git[:-]" "" vc-mode)))))

(defun my/mode-line-encoding ()
  "EOL style + coding system, e.g. \"LF  UTF-8\"."
  (let* ((cs (or buffer-file-coding-system 'utf-8))
         (name (symbol-name (or (coding-system-get cs :mime-charset)
                                (coding-system-get cs :name)
                                'utf-8))))
    (concat (pcase (coding-system-eol-type cs)
              (0 "LF") (1 "CRLF") (2 "CR") (_ ""))
            "  "
            (upcase (replace-regexp-in-string "\\`prefer-" "" name)))))

(defun my/mode-line-filetype ()
  "Filetype: cached nerd icon for the buffer + the major mode name."
  (concat (when (and (stringp my/mode-line-filetype-icon)
                     (not (string-empty-p my/mode-line-filetype-icon)))
            (concat my/mode-line-filetype-icon " "))
          (format-mode-line mode-name)))

(setq-default mode-line-format
              '("%e" mode-line-front-space
                (:eval (my/mode-line-macro))
                mode-line-modified " "
                (:eval (my/mode-line-buffer))
                (:eval (my/mode-line-vc))
                "  " mode-line-position
                mode-line-format-right-align
                (:eval (my/mode-line-encoding))
                "   " mode-line-misc-info "  "
                (:eval (my/mode-line-filetype))
                ;; Trailing slack: `mode-line-format-right-align' mismeasures the
                ;; filetype's nerd glyph, so without padding the tail spills past
                ;; the window edge and clips.  These spaces absorb the overflow.
                "   "))

;; Slightly taller mode line: pad vertically with a box coloured like the mode
;; line's own background (invisible padding, not a visible border).  The colour
;; is only resolvable once a real GUI frame exists, so skip unresolved values
;; and (re)apply on theme switches + deferred after frame creation.
(defun my/mode-line-pad-height (&rest _)
  ;; Read the colour from an actual graphical frame -- the colour is unresolved
  ;; on the daemon's terminal frame, and timers fire without the GUI frame
  ;; necessarily selected.
  (when-let* ((frame (seq-find #'display-graphic-p (frame-list))))
    (dolist (face '(mode-line mode-line-inactive))
      (let ((bg (face-attribute face :background frame 'default)))
        (when (and (stringp bg) (not (string= bg "unspecified-bg")))
          (set-face-attribute face nil :box `(:line-width (1 . 4) :color ,bg)))))))
(add-hook 'enable-theme-functions #'my/mode-line-pad-height)
(add-hook 'server-after-make-frame-hook
          (lambda () (run-with-timer 0.2 nil #'my/mode-line-pad-height)))
(my/mode-line-pad-height)

(provide 'modeline-rcp)
;;; modeline-rcp.el ends here
