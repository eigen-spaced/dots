;;; pdf-rcp.el --- pdf-tools: native PDF viewing via epdfinfo -*- lexical-binding: t; -*-
;; Replaces the built-in doc-view raster viewer.  epdfinfo is a C server compiled
;; against Homebrew poppler; after a package update run `M-x pdf-tools-install' to
;; rebuild it.  pdf-view-mode is already in meow `motion' state (meow-rcp), so the
;; h/l binds below reach the buffer instead of meow's normal-state keymap.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :mode ("\\.pdf\\'" . pdf-view-mode)
  ;; h/l scroll the page sideways.  h shadows `describe-mode', which stays on `?'.
  :bind (:map pdf-view-mode-map
         ("h" . image-backward-hscroll)
         ("l" . image-forward-hscroll))
  :config
  (pdf-tools-install :no-query)
  ;; pdf-history-minor-mode-map binds l/r and outranks pdf-view-mode-map, so
  ;; re-bind h/l here too or `l' stays `pdf-history-backward'.
  (with-eval-after-load 'pdf-history
    (define-key pdf-history-minor-mode-map (kbd "h") #'image-backward-hscroll)
    (define-key pdf-history-minor-mode-map (kbd "l") #'image-forward-hscroll)))

(provide 'pdf-rcp)
;;; pdf-rcp.el ends here
