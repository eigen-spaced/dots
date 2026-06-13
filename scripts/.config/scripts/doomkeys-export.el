;;; doomkeys-export.el --- dump active keybindings to TSV -*- lexical-binding: t; -*-

;; Meant to be loaded inside the *running Doom daemon* so the dump reflects the
;; actual, fully-loaded config (personal binds included), e.g.:
;;
;;   emacsclient -e '(progn (load "~/.config/scripts/doomkeys-export.el")
;;                          (doomkeys-export "~/.cache/doomkeys/keys.tsv"))'
;;
;; Output is a TSV with one binding per line:
;;   group <TAB> state <TAB> keys <TAB> command <TAB> summary
;;
;;   group    keymap category, e.g. "dired", "magit-status", "leader", "global"
;;   state    evil state ("normal"/"visual"/...), "leader", or "-" (state-agnostic)
;;   keys     human-readable key sequence, e.g. "R" or "SPC p a"
;;   command  the bound command symbol
;;   summary  first line of the command's docstring

(require 'cl-lib)
(require 'evil nil t)

(defvar doomkeys--seen nil)       ; id -> row
(defvar doomkeys--keyprefix "")   ; prepended to every key-description (for leader)

;; general stores evil-state-conditional binds under pseudo-events that render
;; like "<normal-state> SPC p a" — never a real key sequence, so drop them.
(defconst doomkeys--pseudo-state-re
  "<\\(normal\\|insert\\|visual\\|motion\\|operator\\|emacs\\|replace\\)-state>")

(defun doomkeys--state-prio (state)
  "Lower = preferred when the same key+command appears in several states."
  (or (cdr (assoc state '(("leader" . 0) ("normal" . 1) ("visual" . 2)
                          ("motion" . 3) ("operator" . 4) ("insert" . 5)
                          ("emacs" . 6) ("-" . 7))))
      8))

(defun doomkeys--summary (cmd)
  "First docstring line of CMD, flattened for TSV."
  (let ((doc (ignore-errors (documentation cmd))))
    (if (and (stringp doc) (> (length doc) 0))
        (replace-regexp-in-string
         "[ \t]+" " "
         (replace-regexp-in-string "[\t\r\n]" " " (car (split-string doc "\n"))))
      "")))

(defun doomkeys--emit (group state keys cmd)
  (when (and (symbolp cmd) cmd (commandp cmd)
             (not (memq cmd '(self-insert-command digit-argument
                              negative-argument undefined ignore
                              evil-digit-argument-or-evil-motion))))
    (let ((kd (concat doomkeys--keyprefix (key-description keys))))
      (unless (or (string-match-p doomkeys--pseudo-state-re kd)
                  (string-match-p "<remap>" kd)) ; command remaps, not real keys
        (let* ((id (mapconcat #'identity (list group kd (symbol-name cmd)) "\0"))
               (row (list group state kd (symbol-name cmd) (doomkeys--summary cmd)))
               (old (gethash id doomkeys--seen)))
          (when (or (null old)
                    (< (doomkeys--state-prio state) (doomkeys--state-prio (nth 1 old))))
            (puthash id row doomkeys--seen)))))))

(defun doomkeys--walk (keymap group state &optional prefix)
  "Walk KEYMAP's own bindings (parent detached) into rows."
  (when (keymapp keymap)
    (map-keymap
     (lambda (event def)
       (when (or (integerp event) (symbolp event)) ; skip char-ranges / meta
         (let ((keys (vconcat prefix (vector event))))
           (cond
            ((keymapp def) (doomkeys--walk def group state keys))
            ((and (symbolp def) (fboundp def) (keymapp (symbol-function def)))
             (doomkeys--walk (symbol-function def) group state keys))
            (t (doomkeys--emit group state keys def))))))
     keymap)))

(defun doomkeys--walk-top (keymap group state)
  "Walk KEYMAP excluding inherited (parent) bindings."
  (when (keymapp keymap)
    (let ((m (copy-keymap keymap)))
      (set-keymap-parent m nil)
      (doomkeys--walk m group state))))

(defun doomkeys--group-name (sym)
  (let ((n (symbol-name sym)))
    (setq n (replace-regexp-in-string "-map\\'" "" n))
    (replace-regexp-in-string "-mode\\'" "" n)))

(defun doomkeys-export (outfile)
  "Collect all active bindings and write them as TSV to OUTFILE."
  (setq doomkeys--seen (make-hash-table :test 'equal))
  (let ((evil-states '(normal visual motion insert operator emacs)))
    ;; 1. Leader tree (SPC ...)
    (when (boundp 'doom-leader-map)
      (let ((doomkeys--keyprefix (concat (or (bound-and-true-p doom-leader-key) "SPC") " ")))
        (doomkeys--walk-top doom-leader-map "leader" "leader")))
    ;; 2. Global evil state maps
    (when (featurep 'evil)
      (dolist (st evil-states)
        (let ((m (symbol-value (intern (format "evil-%s-state-map" st)))))
          (doomkeys--walk-top m "global" (symbol-name st)))))
    ;; 3. Every bound *-mode-map, plus its evil auxiliary keymaps
    (mapatoms
     (lambda (sym)
       (when (and (boundp sym)
                  (string-suffix-p "-mode-map" (symbol-name sym))
                  ;; leader/localleader live in general-override-* but are
                  ;; captured cleanly via the leader walk above.
                  (not (string-prefix-p "general-override" (symbol-name sym)))
                  (keymapp (symbol-value sym)))
         (let ((group (doomkeys--group-name sym))
               (map (symbol-value sym)))
           (doomkeys--walk-top map group "-")
           (when (fboundp 'evil-get-auxiliary-keymap)
             (dolist (st evil-states)
               (let ((aux (evil-get-auxiliary-keymap map st)))
                 (when (keymapp aux)
                   (doomkeys--walk-top aux group (symbol-name st))))))))))
    ;; Write sorted TSV
    (let ((rows (sort (hash-table-values doomkeys--seen)
                      (lambda (a b)
                        (or (string< (car a) (car b))
                            (and (string= (car a) (car b))
                                 (string< (nth 2 a) (nth 2 b))))))))
      (with-temp-file outfile
        (dolist (r rows)
          (insert (mapconcat #'identity r "\t") "\n")))
      (length rows))))

(provide 'doomkeys-export)
;;; doomkeys-export.el ends here
