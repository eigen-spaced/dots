;;; mpd-rcp.el --- mpdel: drive the MPD daemon from Emacs -*- lexical-binding: t; -*-
;; Client for the same MPD daemon that rmpc and the Hammerspoon ⌘⌥ keys control,
;; so all three share one queue.  libmpdel defaults to localhost:6600 (the daemon).
;; Bindings live under the `SPC a' leader (meow-rcp); mpdel's own C-x Z is left off.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package mpdel
  :commands (mpdel-core-open-artists mpdel-browser-open mpdel-playlist-open
             mpdel-core-open-stored-playlists mpdel-song-open
             libmpdel-playback-play-pause libmpdel-playback-next
             libmpdel-playback-previous libmpdel-stop
             mpdel-core-volume-increase mpdel-core-volume-decrease))

;; Embark actions (add to playlist, play next, …) on mpdel entities and on
;; completing-read candidates; loads once both mpdel and embark are up.
(use-package mpdel-embark
  :after (mpdel embark)
  :config (mpdel-embark-setup))

(provide 'mpd-rcp)
;;; mpd-rcp.el ends here
