;;; vcs-rcp.el --- magit -*- lexical-binding: t; -*-
;;; Code:
(eval-when-compile (require 'use-package))

(use-package magit
  :commands (magit-status magit-dispatch magit-blame magit-log-current))

(provide 'vcs-rcp)
;;; vcs-rcp.el ends here
