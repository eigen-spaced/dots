;;; dashboard-rcp.el --- startup dashboard: today's agenda + recent projects -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

;; `initial-buffer-choice' is consulted for every `emacsclient -c' frame, so an
;; emacs-everywhere popup would get the dashboard pasted over its editing buffer.
;; Keep that frame's own buffer (it carries the `emacs-everywhere-app' param).
(defun my/dashboard-initial-buffer ()
  "Return the dashboard buffer, except in an emacs-everywhere frame."
  (if (frame-parameter nil 'emacs-everywhere-app)
      (current-buffer)
    (get-buffer-create "*dashboard*")))

(use-package dashboard
  :init (dashboard-setup-startup-hook)
  :custom
  (dashboard-banner-logo-title "")
  (dashboard-startup-banner 'logo)
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  (dashboard-items '((agenda . 10) (projects . 5) (recents . 5)))
  (dashboard-projects-backend 'projectile)
  (dashboard-week-agenda nil)            ; today only
  (dashboard-icon-type 'nerd-icons)
  (dashboard-display-icons-p t)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (initial-buffer-choice #'my/dashboard-initial-buffer)
  :config
  ;; On the daemon the dashboard first renders frameless, where
  ;; (face-attribute 'default :height) is a bogus 1; dashboard-agenda--set-face
  ;; bakes that tiny height into the agenda items.  Re-render once a real GUI
  ;; frame exists (default height is correct there), then drop the hook.  The
  ;; 0.1s timer lets the new frame's faces fully realize first (Doom does the
  ;; same in +doom-dashboard-reload-frame-h — synchronous reload is unreliable).
  (when (daemonp)
    (defun my/dashboard-refresh-on-frame ()
      (remove-hook 'server-after-make-frame-hook #'my/dashboard-refresh-on-frame)
      (run-with-timer
       0.1 nil
       (lambda ()
         (when (get-buffer "*dashboard*")
           (with-current-buffer "*dashboard*" (dashboard-refresh-buffer))))))
    (add-hook 'server-after-make-frame-hook #'my/dashboard-refresh-on-frame)))

(provide 'dashboard-rcp)
;;; dashboard-rcp.el ends here
