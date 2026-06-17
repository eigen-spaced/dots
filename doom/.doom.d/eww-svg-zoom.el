;;; eww-svg-zoom.el --- Zoom SVGs in EWW via a rasterised image buffer -*- lexical-binding: t; -*-

;; `image-increase-size'/`image-decrease-size' (the i+/i- keys, from the image's
;; own `keymap' text property) zoom raster images fine but are no-ops on SVGs:
;; an SVG that declares its own size renders at that size, so librsvg ignores
;; the image spec's `:scale'/`:width' hints, and editing the source inline is
;; fragile. So instead of fighting it, on an SVG i+/i- automatically rasterise
;; it to a PNG (via rsvg-convert/imagemagick) and pop it open in a real
;; `image-mode' buffer, where +/- zoom works on the raster copy. Raster images
;; keep zooming inline as before.
;;
;; We hook via :before-until ADVICE rather than a key binding, because the
;; image's text-property keymap is consulted before Evil's state maps, so a
;; binding in `eww-mode-map' never fires while point is on an image. The advice
;; acts only in EWW on an SVG; otherwise it returns nil and the stock command
;; runs untouched.

(defun my/eww--display-image (disp)
  "Extract the image object from a `display' spec DISP (bare or sliced), else nil.
Sliced images carry specs like ((slice ...) (image ...)); bare ones are the
image list itself."
  (cond ((eq (car-safe disp) 'image) disp)
        ((consp disp) (seq-find (lambda (x) (eq (car-safe x) 'image)) disp))))

(defun my/eww--image-at-point ()
  "Return the image object under point, else nil.
Uses `get-char-property' (overlays *and* text properties) — eww/shr may attach
the image to an overlay, which `get-text-property' would miss — and checks just
after point too, for the cursor sitting at the image's trailing edge."
  (let ((disp (or (get-char-property (point) 'display)
                  (and (> (point) (point-min))
                       (get-char-property (1- (point)) 'display)))))
    (my/eww--display-image disp)))

(defun my/eww--image-url ()
  "Source URL of the image at point, from the `image-url' char/text property."
  (or (get-char-property (point) 'image-url)
      (and (> (point) (point-min))
           (get-char-property (1- (point)) 'image-url))))

(defun my/eww--svg-data (image)
  "Raw SVG source for IMAGE: its `:data', else fetched from its URL."
  (or (image-property image :data)
      (when-let* ((url (my/eww--image-url)))
        (ignore-errors
          (with-temp-buffer
            (url-insert-file-contents url)
            (buffer-string))))))

(defun my/eww--svg-has-size-p (svg)
  "Non-nil if SVG's root element declares both `width' and `height'.
Such an SVG has an intrinsic size and zooms fine inline via the stock command;
a viewBox-only SVG has no base size, renders to fill the window, and can't be
scaled — that is the only case we need to handle specially."
  (when (and svg (string-match "<svg\\b[^>]*>" svg))
    (let ((tag (match-string 0 svg)))
      (and (string-match-p "\\bwidth=" tag)
           (string-match-p "\\bheight=" tag)))))

(defvar my/eww-svg-rasterizer
  (cond ((executable-find "rsvg-convert") 'rsvg)
        ((executable-find "magick")       'magick)
        ((executable-find "convert")      'convert))
  "External tool used to rasterise SVGs, or nil if none is installed.")

(defvar my/eww-svg-zoom-resolution 3
  "Rasterise SVGs at this multiple of their on-screen width.
Higher is crisper but produces a larger, slower PNG.  The target width is also
floored at 1600px and capped at 6000px.")

(defun my/eww--rasterize-svg (svg width)
  "Rasterise SVG string to a temp PNG file at WIDTH px (aspect preserved).
Returns the file path, or nil. rsvg-convert is preferred (sharpest for SVG).
Lets rsvg work out the size from the SVG's viewBox — no source parsing here."
  (when my/eww-svg-rasterizer
    (let ((svg-file (make-temp-file "eww-svg-" nil ".svg" svg))
          (png-file (make-temp-file "eww-svg-zoom-" nil ".png"))
          (w (number-to-string width)))
      (unwind-protect
          (let* ((args (pcase my/eww-svg-rasterizer
                         ('rsvg    (list "rsvg-convert" "-w" w "-o" png-file svg-file))
                         ('magick  (list "magick" "-background" "none" svg-file
                                         "-resize" (concat w "x") png-file))
                         ('convert (list "convert" "-background" "none" svg-file
                                         "-resize" (concat w "x") png-file))))
                 (ok (eq 0 (apply #'call-process (car args) nil nil nil (cdr args)))))
            (when (and ok (file-exists-p png-file)
                       (> (file-attribute-size (file-attributes png-file)) 0))
              png-file))
        (ignore-errors (delete-file svg-file))))))

(defun my/eww-svg-open-zoomable (image svg)
  "Rasterise SVG (source string for IMAGE) to a hi-res PNG and pop it open in an
`image-mode' buffer.  Used for viewBox-only SVGs, which have no intrinsic size
and so can't be scaled inline; the raster copy zooms with +/- in image-mode."
  (cond
   ((not my/eww-svg-rasterizer)
    (message "EWW SVG zoom: no rasteriser — `brew install librsvg' (or imagemagick)"))
   (t
      (let* ((cur (or (ignore-errors (round (car (image-size image t)))) 600))
             ;; Render well above on-screen size so zooming in stays crisp.
             (width (min 6000 (max 1600 (round (* my/eww-svg-zoom-resolution cur)))))
             (png (my/eww--rasterize-svg svg width)))
        (if (not png)
            (message "EWW SVG zoom: rasterise failed")
          (pop-to-buffer (find-file-noselect png))
          ;; The PNG is hi-res; fit it to the window for the initial view (so the
          ;; whole figure shows). Must run after the window exists — +/- then
          ;; zoom crisply from the full-res source. `find-file-noselect' builds
          ;; the buffer before it has a window, so it would otherwise show 1:1.
          (when (and (derived-mode-p 'image-mode)
                     (fboundp 'image-transform-fit-to-window))
            (image-transform-fit-to-window))
          (message "Zoomable PNG copy — +/- to zoom, 0 to reset, q to quit"))))))

(defun my/eww-svg-zoom-a (&rest _)
  "Advice on image +/- in EWW.  Only a viewBox-only SVG (no intrinsic size)
can't zoom inline; hand it to a rasterised image buffer.  Sized SVGs and raster
images return nil so the stock command zooms them inline as usual."
  (when (derived-mode-p 'eww-mode)
    (when-let* ((image (my/eww--image-at-point))
                ((eq (image-property image :type) 'svg))
                (svg (my/eww--svg-data image))
                ((not (my/eww--svg-has-size-p svg))))
      (my/eww-svg-open-zoomable image svg)
      t)))

;; Reload-safe: drop any prior versions of this advice (including names used by
;; earlier iterations) before re-adding, so `doom/reload' never stacks them.
(dolist (fn '(my/eww-svg-zoom-a my/eww-svg-zoom-prompt-a
              my/eww-svg-zoom-in-a my/eww-svg-zoom-out-a))
  (advice-remove 'image-increase-size fn)
  (advice-remove 'image-decrease-size fn))
(advice-add 'image-increase-size :before-until #'my/eww-svg-zoom-a)
(advice-add 'image-decrease-size :before-until #'my/eww-svg-zoom-a)

(provide 'eww-svg-zoom)
;;; eww-svg-zoom.el ends here
