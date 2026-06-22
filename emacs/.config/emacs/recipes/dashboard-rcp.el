;;; dashboard-rcp.el --- startup dashboard: today's agenda + recent projects -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

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
  (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*"))))

(with-eval-after-load 'meow
  (add-to-list 'meow-mode-state-list '(dashboard-mode . motion)))

(provide 'dashboard-rcp)
;;; dashboard-rcp.el ends here
