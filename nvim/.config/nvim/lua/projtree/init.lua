-- projtree: a dead-simple, read-only project tree pinned to a sidebar.
--
-- It is *not* a file manager. There is no opening, selecting, renaming or
-- deleting -- just a persistent view of the project's shape so you keep your
-- bearings while you navigate with mini.pick / oil / mini.files. Two modes,
-- toggled in place:
--   * "tree"    -- folders + files (the full picture)
--   * "folders" -- directory skeleton only (the high-level shape)
--
-- File listing respects .gitignore (via `git ls-files`), falling back to `fd`
-- and then a plain filesystem walk outside git repos.

local M = {}

local has_mini, MiniIcons = pcall(require, "mini.icons")

M.config = {
  side = "right", -- "left" | "right"
  width = 34,
  mode = "tree", -- "tree" | "folders"
  -- Names skipped by the non-git fallback walk (git mode honours .gitignore).
  fallback_ignore = { ".git", "build", ".cache", "node_modules", ".DS_Store" },
}

-- Live state. `buf` is reused across toggles so reopening is instant; `win` is
-- nil whenever the sidebar is closed.
local state = {
  buf = nil,
  win = nil,
  root = nil,
}

local ns = vim.api.nvim_create_namespace("projtree")

----------------------------------------------------------------------
-- Project discovery
----------------------------------------------------------------------

-- The project root is simply the cwd -- whatever directory you've cd'd into,
-- not the git toplevel above it. `git ls-files` run from a subdirectory still
-- lists just that subtree (relative, .gitignore-respected), so you keep the
-- filtering without climbing to the repo root. Tracks `:cd` / DirChanged.
local function find_root()
  return vim.fn.getcwd()
end

-- File paths relative to `root`, honouring .gitignore where possible.
local function list_paths(root)
  -- Tracked + untracked-but-not-ignored, so brand-new files show up too.
  local paths = vim.fn.systemlist {
    "git",
    "-C",
    root,
    "-c",
    "core.quotePath=false",
    "ls-files",
    "--cached",
    "--others",
    "--exclude-standard",
  }
  if vim.v.shell_error == 0 and #paths > 0 then
    return paths
  end

  -- Outside a git repo: fd gives us relative paths via --base-directory.
  if vim.fn.executable("fd") == 1 then
    local cmd = { "fd", "--type", "f", "--hidden", "--base-directory", root }
    for _, name in ipairs(M.config.fallback_ignore) do
      cmd[#cmd + 1] = "--exclude"
      cmd[#cmd + 1] = name
    end
    paths = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
      return paths
    end
  end

  -- Last resort: a shallow-ish manual walk.
  local ignore = {}
  for _, name in ipairs(M.config.fallback_ignore) do
    ignore[name] = true
  end
  local results = {}
  local function walk(dir, prefix)
    local handle = vim.loop.fs_scandir(dir)
    if not handle then
      return
    end
    while true do
      local name, typ = vim.loop.fs_scandir_next(handle)
      if not name then
        break
      end
      if not ignore[name] then
        local rel = prefix == "" and name or (prefix .. "/" .. name)
        if typ == "directory" then
          walk(dir .. "/" .. name, rel)
        else
          results[#results + 1] = rel
        end
      end
    end
  end
  walk(root, "")
  return results
end

----------------------------------------------------------------------
-- Tree model + rendering
----------------------------------------------------------------------

-- Turn a flat list of "a/b/c.lua" paths into a nested { dirs, files } tree.
local function build_tree(paths)
  local root = { dirs = {}, files = {} }
  for _, p in ipairs(paths) do
    local parts = vim.split(p, "/", { plain = true })
    local node = root
    for i = 1, #parts - 1 do
      local d = parts[i]
      node.dirs[d] = node.dirs[d] or { dirs = {}, files = {} }
      node = node.dirs[d]
    end
    node.files[#node.files + 1] = parts[#parts]
  end
  return root
end

local function dir_icon(name)
  if has_mini then
    local icon, hl = MiniIcons.get("directory", name)
    return icon, hl
  end
  return "", "Directory"
end

local function file_icon(name)
  if has_mini then
    local icon, hl = MiniIcons.get("file", name)
    return icon, hl
  end
  return "", "Normal"
end

local function sorted_keys(tbl)
  local keys = vim.tbl_keys(tbl)
  table.sort(keys)
  return keys
end

-- Render `node` into `lines`, accumulating highlight segments in `hls`.
-- Each hl entry is { line = <0-based>, col = <byte>, end_col = <byte>, hl = group }.
local function render_node(node, prefix, lines, hls, mode)
  local entries = {}
  for _, name in ipairs(sorted_keys(node.dirs)) do
    entries[#entries + 1] =
      { type = "dir", name = name, node = node.dirs[name] }
  end
  if mode ~= "folders" then
    table.sort(node.files)
    for _, name in ipairs(node.files) do
      entries[#entries + 1] = { type = "file", name = name }
    end
  end

  for i, entry in ipairs(entries) do
    local last = i == #entries
    local connector = last and "└ " or "├ "
    local icon, icon_hl
    local display = entry.name
    if entry.type == "dir" then
      icon, icon_hl = dir_icon(entry.name)
      display = display .. "/"
    else
      icon, icon_hl = file_icon(entry.name)
    end

    local line = prefix .. connector .. icon .. " " .. display
    local lnum = #lines -- 0-based index of the line we're about to add
    lines[#lines + 1] = line

    -- Highlight the tree guides, the icon, and (for dirs) the name.
    local pre_bytes = #prefix + #connector
    hls[#hls + 1] =
      { line = lnum, col = 0, end_col = pre_bytes, hl = "Comment" }
    hls[#hls + 1] = {
      line = lnum,
      col = pre_bytes,
      end_col = pre_bytes + #icon,
      hl = icon_hl,
    }
    if entry.type == "dir" then
      hls[#hls + 1] = {
        line = lnum,
        col = pre_bytes + #icon + 1,
        end_col = #line,
        hl = "Directory",
      }
      local child_prefix = prefix .. (last and "  " or "│ ")
      render_node(entry.node, child_prefix, lines, hls, mode)
    end
  end
end

-- Build the full buffer contents (header + tree) and highlight list.
local function render(root, mode)
  local tree = build_tree(list_paths(root))
  local lines, hls = {}, {}

  -- Header: <icon> rootname/   ·<mode>
  local rootname = vim.fn.fnamemodify(root, ":t")
  local ricon, ricon_hl = dir_icon(rootname)
  local header = ricon .. " " .. rootname .. "/"
  local tag = "  ·" .. mode
  lines[1] = header .. tag
  hls[#hls + 1] = { line = 0, col = 0, end_col = #ricon, hl = ricon_hl }
  hls[#hls + 1] = { line = 0, col = #ricon, end_col = #header, hl = "Title" }
  hls[#hls + 1] =
    { line = 0, col = #header, end_col = #header + #tag, hl = "Comment" }

  render_node(tree, "", lines, hls, mode)

  if #lines == 1 then
    lines[2] = "  (no files)"
    hls[#hls + 1] = { line = 1, col = 0, end_col = #lines[2], hl = "Comment" }
  end
  return lines, hls
end

----------------------------------------------------------------------
-- Buffer + window plumbing
----------------------------------------------------------------------

local function ensure_buf()
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    return state.buf
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].buflisted = false
  vim.bo[buf].filetype = "projtree"
  vim.bo[buf].modifiable = false
  pcall(vim.api.nvim_buf_set_name, buf, "projtree")

  -- View controls only -- nothing here touches a file. `nowait` lets the
  -- buffer-local <leader><leader> fire instantly instead of waiting on the
  -- global smart-splits <leader><leader>h/j/k/l swap maps.
  local function map(lhs, fn, desc)
    vim.keymap.set(
      "n",
      lhs,
      fn,
      { buffer = buf, silent = true, nowait = true, desc = desc }
    )
  end
  map("<Space><Space>", M.toggle_mode, "Toggle folders / full tree")
  map("m", M.toggle_mode, "Toggle folders / full tree")
  map("q", M.close, "Close project tree")
  map("R", M.refresh, "Refresh project tree")
  map("<Tab>", "<Nop>", "disabled")
  map("<S-Tab>", "<Nop>", "disabled")

  state.buf = buf
  return buf
end

local function apply(buf, lines, hls)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, h in ipairs(hls) do
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, h.line, h.col, {
      end_col = h.end_col,
      hl_group = h.hl,
      hl_mode = "combine",
    })
  end
end

local function open_win(buf)
  local split = M.config.side == "left" and "topleft vsplit"
    or "botright vsplit"
  vim.cmd(split)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_set_width(win, M.config.width)

  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.foldcolumn = "0"
  wo.statuscolumn = ""
  wo.wrap = false
  wo.list = false
  wo.spell = false
  wo.cursorline = true
  wo.winfixwidth = true
  wo.winfixheight = true
  return win
end

----------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

-- Re-read the project and repaint (only if the sidebar is showing).
function M.refresh()
  if not M.is_open() then
    return
  end
  state.root = find_root()
  local lines, hls = render(state.root, M.config.mode)
  apply(state.buf, lines, hls)
end

function M.open()
  if M.is_open() then
    vim.api.nvim_set_current_win(state.win)
    return
  end
  local buf = ensure_buf()
  state.root = find_root()
  local lines, hls = render(state.root, M.config.mode)
  apply(buf, lines, hls)
  state.win = open_win(buf)
  -- Move into the tree on open (open_win already made it the current window).
  vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
end

function M.close()
  if M.is_open() then
    vim.api.nvim_win_close(state.win, false)
  end
  state.win = nil
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

function M.set_mode(mode)
  M.config.mode = mode == "folders" and "folders" or "tree"
  M.refresh()
end

function M.toggle_mode()
  M.set_mode(M.config.mode == "tree" and "folders" or "tree")
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_user_command("ProjTree", function(cmd)
    local action = cmd.args ~= "" and cmd.args or "toggle"
    if action == "toggle" then
      M.toggle()
    elseif action == "open" then
      M.open()
    elseif action == "close" then
      M.close()
    elseif action == "mode" then
      M.toggle_mode()
    elseif action == "refresh" then
      M.refresh()
    else
      vim.notify(
        "ProjTree: unknown action '" .. action .. "'",
        vim.log.levels.WARN
      )
    end
  end, {
    nargs = "?",
    complete = function()
      return { "toggle", "open", "close", "mode", "refresh" }
    end,
    desc = "Project tree sidebar",
  })

  local group = vim.api.nvim_create_augroup("ProjTree", { clear = true })

  -- Track the project: repaint when cwd changes or a file is written (so new
  -- and deleted files appear). Cheap, and only when the sidebar is visible.
  vim.api.nvim_create_autocmd({ "DirChanged", "BufWritePost" }, {
    group = group,
    callback = function()
      if M.is_open() then
        vim.schedule(M.refresh)
      end
    end,
  })

  -- Forget the window handle if it gets closed by other means, and quit nvim
  -- if the sidebar is all that's left (counting only normal, non-float windows).
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(ev)
      local closed = tonumber(ev.match)
      if closed == state.win then
        state.win = nil
        return
      end
      vim.schedule(function()
        if not M.is_open() then
          return
        end
        local real = vim.tbl_filter(function(w)
          return vim.api.nvim_win_get_config(w).relative == ""
        end, vim.api.nvim_tabpage_list_wins(0))
        if #real == 1 and real[1] == state.win then
          vim.cmd("quit")
        end
      end)
    end,
  })
end

return M
