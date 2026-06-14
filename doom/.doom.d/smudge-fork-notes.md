# smudge fork — starting notes

Context: [`smudge`](https://github.com/danielfm/smudge) is effectively unmaintained
(author not responding to issues), and the **Spotify Web API Feb-2026 breaking
changes** broke it. We patched it locally tonight; this is the plan + change list
for turning those patches into a proper fork + upstream PR.

- API changelog: <https://developer.spotify.com/documentation/web-api/references/changes/february-2026>
- Our local patches live in `~/.doom.d/smudge-2026.el` (API shims, `:override`
  advice) and `~/.doom.d/config.el` (the `(use-package! smudge …)` block — UX tweaks).

## How to migrate to the fork

Fork: **git@github.com:eigen-spaced/smudge.git**, cloned locally at
**~/Documents/projects/smudge** (origin = the fork).

1. Wire straight to the fork so edits are testable. Either point the recipe at
   the fork — `(package! smudge :recipe (:host github :repo "eigen-spaced/smudge"))`
   — and edit in `~/.emacs.d/.local/straight/repos/smudge`; OR symlink that path
   to `~/Documents/projects/smudge` and edit there. Then `doom sync`.
2. For each shim in `smudge-2026.el`, paste its **body** into the matching `defun`
   in `smudge-api.el` and delete the `advice-add` line. (Each shim is written as
   the fixed upstream function, so this is mechanical.)
3. Apply the UX fixes below where they belong (most are upstreamable).
4. Delete `(load! "smudge-2026")` (and `smudge-2026.el`) + the now-upstreamed
   bits from config.el once the fork carries them.
5. Test (checklist at the bottom), commit, push to the fork, open a PR.

---

## A. API-compat changes (DONE — in `smudge-2026.el`)

These are the Feb-2026 changes; each is verified working.

| Upstream fn (smudge-api.el) | Change | Fix |
|---|---|---|
| `smudge-api-search` (+ `smudge-api-search-limit`) | `/search` `limit` max dropped 50→10 | cap the `/search` `limit` at 10; keep the shared var at 50 for playlist/track pages |
| `smudge-api-user-playlists` | `GET /users/{id}/playlists` **removed** | use `GET /me/playlists` |
| `smudge-api-get-playlist-track-count` | playlist field `tracks` **renamed → `items`** | read `items.total` (nil-safe: non-owned playlists return metadata only) |
| `smudge-api-playlist-tracks` | `GET /playlists/{id}/tracks` **renamed → `/playlists/{id}/items`** | hit `/items` (and drop the now-unused owner path segment) |
| `smudge-api-get-playlist-tracks` | per-entry track field `track` **renamed → `item`** | read `item` from each entry |
| `smudge-api-popularity-bar` | Track `popularity` **removed** | nil-safe (renders empty bar; consider dropping the column upstream) |

## B. UX / Doom-evil fixes (DONE — in config.el `use-package! smudge`)

Some of these are real upstream bugs worth PRing; others are Doom/evil-specific
(keep those local).

| What | Where it should live |
|---|---|
| `force-mode-line-update` after `smudge-controller-update-player-status` so the play/pause indicator is live (smudge updates the var on its 5s timer but never forces a repaint) | **upstream** — genuine bug |
| Preserve point on `l`/load-more (smudge reprints the list and dumps point at the top despite `remember-pos`) — `cust/smudge-preserve-point` around the `*-search-print` fns | **upstream** — genuine bug |
| OAuth "authorize in the browser" message (smudge sets `inhibit-message` so the blocking busy-wait looks like a hang) | **upstream** — UX bug |
| Bind `l`/`g`/`RET` for evil normal state in the list buffers (evil shadows smudge's `l`/`g`; `RET` = play, smudge only binds `M-RET`) | **local** (Doom+evil) — don't upstream |
| Hide mode-line in list buffers | **local** (personal taste) |

## C. NOT yet patched (TODO when forking — write/less-used paths)

We only fixed the read paths actually used (search, my-playlists, view+play
tracks). The Feb-2026 changelog also changed these, still on the old endpoints in
smudge — fix them in the fork:

- `POST /users/{id}/playlists` → **`POST /me/playlists`** (`smudge-api-playlist-create`)
- `POST/PUT/DELETE /playlists/{id}/tracks` → **`/playlists/{id}/items`**
  (`smudge-api-playlist-add-track`, `smudge-api-playlist-remove-track`, reorder)
- Library consolidation: `PUT/DELETE /me/{tracks,albums,episodes,shows}` →
  **`/me/library`**, and the various `…/contains` → **`/me/library/contains`**
- Removed catalog/browse endpoints (top-tracks, new-releases, several "Get
  Several …", browse categories, featured playlists) — audit smudge for any use.
- Removed **User** profile fields (`country`, `product`, `email`, `followers`,
  `explicit_content`) — check anything reading `product` (premium detection).
  We sidestep this with the `apple` transport; the `connect` transport may care.
- Other removed object fields (Track/Album/Artist `popularity`, `available_markets`,
  Track `linked_from`, …) — guard any accessor that hits them.

## D. Test checklist (in Emacs, with the fork loaded)

- [ ] `SPC o M s` track search returns results
- [ ] `SPC o M m` lists playlists with track counts (no `hash-table-p nil`)
- [ ] `RET` on a playlist → tracks; `RET` on a track → plays
- [ ] `l` paginates a long playlist without jumping to top; `g` reloads
- [ ] play/pause indicator updates within ~5s of a direct Spotify play/pause
- [ ] (if patching write paths) add/remove a track, create a playlist
