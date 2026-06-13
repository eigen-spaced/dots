;;; smudge-2026.el -*- lexical-binding: t; -*-
;;
;; Local compatibility shims for the Spotify Web API breaking changes of
;; February 2026, which the (currently unmaintained) `smudge' package predates:
;;   https://developer.spotify.com/documentation/web-api/references/changes/february-2026
;;
;; Each shim below is the *fixed version of the named upstream function* in
;; smudge-api.el, installed via `:override' advice so it survives package
;; rebuilds. The logic is otherwise identical to upstream — only the changed
;; endpoint/field is touched.
;;
;; MIGRATING TO A FORK LATER: for each shim, paste its body into the matching
;; `defun' in your fork's smudge-api.el and delete the `advice-add' line. That's
;; the whole migration — no reverse-engineering needed.
;;
;; Covered (the read paths used by search / my-playlists / playlist tracks):
;;   - smudge-api-search (+ -search-limit): /search `limit' max is now 10 (was 50)
;;   - smudge-api-get-playlist-track-count: playlist field `tracks' -> `items'
;;   - smudge-api-user-playlists          : GET /users/{id}/playlists removed -> /me/playlists
;;   - smudge-api-playlist-tracks         : GET /playlists/{id}/tracks -> /playlists/{id}/items
;;   - smudge-api-get-playlist-tracks     : per-entry track field `track' -> `item'
;;   - smudge-api-popularity-bar          : Track `popularity' removed -> nil-safe
;;
;; NOT yet shimmed (write/less-used paths — do these when forking): POST/PUT/
;; DELETE /playlists/{id}/tracks -> /items, POST /users/{id}/playlists ->
;; POST /me/playlists, the /me/{tracks,albums,...} -> /me/library consolidation,
;; and removed user-profile fields (country/product/email/...).

(require 'smudge-api)

;; --- changed request parameter: /search `limit' max is now 10 (was 50) --------
;; smudge reuses ONE var (`smudge-api-search-limit') for search AND playlist/track
;; pagination. Keep it at 50 so playlist/track pages stay large (all your
;; playlists fit one page), and cap ONLY the /search call to the new max of 10.
(setq smudge-api-search-limit 50)

(defun smudge-2026--search (type query page callback)
  "Replacement for `smudge-api-search' (caps `limit' at the new max of 10)."
  (let* ((limit (min smudge-api-search-limit 10))
         (offset (* limit (1- page))))
    (smudge-api-call-async
     "GET"
     (concat "/search?"
             (url-build-query-string `((q      ,query)
                                       (type   ,type)
                                       (limit  ,limit)
                                       (offset ,offset)
                                       (market from_token))
                                     nil t))
     nil
     callback)))
(advice-add 'smudge-api-search :override #'smudge-2026--search)

;; --- field rename: playlist `tracks' -> `items' ------------------------------
;; Also: non-owned playlists now return metadata only (no items object), so guard.
(defun smudge-2026--playlist-track-count (json)
  "Replacement for `smudge-api-get-playlist-track-count' (tracks -> items)."
  (let ((items (gethash "items" json)))
    (if (hash-table-p items) (or (gethash "total" items) 0) 0)))
(advice-add 'smudge-api-get-playlist-track-count
            :override #'smudge-2026--playlist-track-count)

;; --- removed endpoint: GET /users/{id}/playlists -> GET /me/playlists ---------
(defun smudge-2026--user-playlists (_user-id page callback)
  "Replacement for `smudge-api-user-playlists' (uses /me/playlists)."
  (let ((offset (* smudge-api-search-limit (1- page))))
    (smudge-api-call-async
     "GET"
     (concat "/me/playlists?"
             (url-build-query-string `((limit  ,smudge-api-search-limit)
                                       (offset ,offset))
                                     nil t))
     nil
     callback)))
(advice-add 'smudge-api-user-playlists :override #'smudge-2026--user-playlists)

;; --- renamed endpoint: GET /playlists/{id}/tracks -> /playlists/{id}/items ----
;; The new path also drops the owner segment.
(defun smudge-2026--playlist-tracks (playlist page callback)
  "Replacement for `smudge-api-playlist-tracks' (/items endpoint)."
  (let ((id (smudge-api-get-item-id playlist))
        (offset (* smudge-api-search-limit (1- page))))
    (smudge-api-call-async
     "GET"
     (concat (format "/playlists/%s/items?" (url-hexify-string id))
             (url-build-query-string `((limit  ,smudge-api-search-limit)
                                       (offset ,offset)
                                       (market from_token))
                                     nil t))
     nil
     callback)))
(advice-add 'smudge-api-playlist-tracks :override #'smudge-2026--playlist-tracks)

;; --- field rename: playlist-items entry `track' -> `item' ---------------------
(defun smudge-2026--get-playlist-tracks (json)
  "Replacement for `smudge-api-get-playlist-tracks' (entry track -> item)."
  (mapcar (lambda (entry) (gethash "item" entry))
          (smudge-api-get-items json)))
(advice-add 'smudge-api-get-playlist-tracks
            :override #'smudge-2026--get-playlist-tracks)

;; --- removed field: Track `popularity' --------------------------------------
;; Feb-2026 removed `popularity' from Track objects, so the popularity bar is
;; handed nil and `(/ nil 10)' crashes the track-list render. Degrade
;; gracefully (the column is now always empty for every track — when forking,
;; consider dropping the "Popularity" column from `smudge-track-search-print').
(defun smudge-2026--popularity-bar (popularity)
  "Replacement for `smudge-api-popularity-bar' (nil-safe; popularity removed)."
  (let ((num-bars (if (numberp popularity) (truncate (/ popularity 10)) 0)))
    (concat (make-string num-bars ?X)
            (make-string (- 10 num-bars) ?-))))
(advice-add 'smudge-api-popularity-bar :override #'smudge-2026--popularity-bar)

(provide 'smudge-2026)
;;; smudge-2026.el ends here
