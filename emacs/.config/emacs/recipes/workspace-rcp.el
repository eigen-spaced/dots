;;; workspace-rcp.el --- perspective.el workspaces (Doom-style) -*- lexical-binding: t; -*-
;; Project-agnostic, buffer-isolated workspaces; s-1..s-9 switch by position.
;;; Code:
(eval-when-compile (require 'use-package))

(defun my/persp-switch-by-index (index)
  "Switch to the INDEX-th EXISTING workspace (1-based) in creation order.
Never creates one — if there is no workspace at INDEX, just say so.
`persp-sort' is \\='created (newest first), so reverse for a stable
oldest-first ordering: s-1 is the first workspace, new ones append."
  (let ((name (nth (1- index) (reverse (persp-names)))))
    (if name (persp-switch name)
      (message "No workspace %d" index))))

(defun my/persp--project-name ()
  "Basename of the current project root (fallback: current directory)."
  (file-name-nondirectory
   (directory-file-name
    (or (when-let ((p (project-current))) (project-root p))
        default-directory))))

(defun my/persp--unique-name (base)
  "BASE, or BASE with the lowest integer suffix not yet a perspective name."
  (if (not (member base (persp-names)))
      base
    (let ((n 2))
      (while (member (format "%s%d" base n) (persp-names))
        (setq n (1+ n)))
      (format "%s%d" base n))))

(defun my/persp-new-workspace ()
  "Create a new workspace named <project>-workspace, auto-numbered on
collision (…workspace2, …3), and MOVE the current buffer into it so you
land on your file instead of a fresh *scratch* — no prompt.
The buffer is removed from the origin perspective (so opening a file then
creating its workspace doesn't leave it lingering in `main').
Use `persp-switch' (SPC TAB TAB) when you want to type a custom name."
  (interactive)
  (let* ((buf  (current-buffer))
         (name (my/persp--unique-name
                (format "%s-workspace" (my/persp--project-name)))))
    (persp-forget-buffer buf)    ; disassociate from origin WITHOUT killing it
    (persp-switch name)          ; create + activate (lands on *scratch*)
    (persp-add-buffer buf)       ; make the file a member of this workspace…
    (switch-to-buffer buf)))     ; …and show it instead of scratch

(defun my/persp-current-modeline ()
  "Mode-line string showing only the CURRENT workspace name.
perspective.el's own modestring lists every workspace; we replace it with
just the active one (see :config)."
  (when (bound-and-true-p persp-mode)
    (propertize (format " %s " (persp-current-name)) 'face 'persp-selected-face)))

(use-package perspective
  :custom
  (persp-mode-prefix-key (kbd "C-c M-p"))
  (persp-state-default-file (expand-file-name "persp-state" user-emacs-directory))
  (persp-suppress-no-prefix-key-warning t)
  (persp-sort 'created)                  ; H-N -> Nth workspace by creation order
  :init
  (persp-mode)
  :config
  (add-hook 'kill-emacs-hook #'persp-state-save)
  ;; Show only the current workspace in the mode line, not the full [a|b|c]
  ;; list: drop perspective.el's own modestring and inject our current-only one.
  (setq persp-show-modestring nil)
  (setq global-mode-string (delete '(:eval (persp-mode-line)) global-mode-string))
  (add-to-list 'global-mode-string '(:eval (my/persp-current-modeline)) t)
  ;; H-1..H-9 (right-Cmd) switch to an EXISTING workspace by position; they never
  ;; create.  Workspace creation is explicit: SPC TAB c (or M-x my/persp-new-workspace).
  (dotimes (i 9)
    (define-key global-map (kbd (format "H-%d" (1+ i)))
                (let ((n (1+ i))) (lambda () (interactive) (my/persp-switch-by-index n))))))

(provide 'workspace-rcp)
;;; workspace-rcp.el ends here
