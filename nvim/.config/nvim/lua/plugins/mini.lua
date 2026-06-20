return {
  "nvim-mini/mini.nvim",
  version = false,
  config = function()
    require("mini.comment").setup()
    require("mini.surround").setup()
    require("mini.icons").setup()
    require("mini.misc").setup()

    require("mini.files").setup()
    vim.keymap.set("n", "<leader>.", function()
      MiniFiles.open()
    end, { desc = "Open MiniFiles" })

    local pick = require("mini.pick")
    pick.setup {
      -- fzf-lua muscle memory: C-j/C-k move the selection.
      mappings = {
        move_down = "<C-j>",
        move_up = "<C-k>",
      },
    }

    -- Bold, distinctly-coloured highlight for the matched query in grep results.
    -- Borrow the colour mini uses for fuzzy matches and add bold; refresh on
    -- colorscheme change (deferred so mini re-defines its groups first).
    local function set_grep_match_hl()
      local base =
        vim.api.nvim_get_hl(0, { name = "MiniPickMatchRanges", link = false })
      vim.api.nvim_set_hl(
        0,
        "MiniPickGrepMatch",
        { fg = base.fg, sp = base.sp, bold = true }
      )
    end
    set_grep_match_hl()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup(
        "MiniPickGrepMatchHl",
        { clear = true }
      ),
      callback = function()
        vim.schedule(set_grep_match_hl)
      end,
    })

    -- Grep window: full width, bottom-anchored (mini's default position), and
    -- 10 rows shorter than mini's default height. Width/anchor/row not set here
    -- fall back to the defaults (height computed as mini does internally).
    local function grep_win_config()
      local has_tabline = vim.o.showtabline == 2
        or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
      local has_statusline = vim.o.laststatus > 0
      local max_height = vim.o.lines
        - vim.o.cmdheight
        - (has_tabline and 1 or 0)
        - (has_statusline and 1 or 0)
      local default_height = math.floor(0.618 * max_height)
      return { width = vim.o.columns, height = math.max(1, default_height - 10) }
    end

    -- Grep items are "path\0lnum\0col\0text"; the default show renders them in
    -- that order, so the matched text lands far right and gets truncated. Lead
    -- with the text instead, highlight the query within it, and dim a trailing
    -- "path:lnum".
    local grep_ns = vim.api.nvim_create_namespace("MiniPickGrep")
    local function grep_show(buf_id, items, query, _opts)
      local texts, locs, lines = {}, {}, {}
      local tab = string.rep(" ", vim.o.tabstop)
      for i, item in ipairs(items) do
        local path, lnum, _, text =
          tostring(item):match("^(.-)%z(%d+)%z(%d+)%z(.*)$")
        if text then
          texts[i] = text:gsub("\t", tab):gsub("[\r\n]", " "):gsub("^%s+", "")
          locs[i] = string.format("  %s:%s", path, lnum)
        else
          texts[i] = tostring(item):gsub("%z", "│"):gsub("[\r\n]", " ")
          locs[i] = ""
        end
        lines[i] = texts[i] .. locs[i]
      end
      vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
      vim.api.nvim_buf_clear_namespace(buf_id, grep_ns, 0, -1)

      -- Highlight literal (case-insensitive) occurrences of the typed query.
      local q = (type(query) == "table" and table.concat(query) or tostring(
        query or ""
      )):lower()
      for i = 1, #texts do
        if q ~= "" then
          local hay, init = texts[i]:lower(), 1
          while true do
            local s, e = hay:find(q, init, true)
            if not s then
              break
            end
            vim.api.nvim_buf_set_extmark(buf_id, grep_ns, i - 1, s - 1, {
              end_row = i - 1,
              end_col = e,
              hl_group = "MiniPickGrepMatch",
              hl_mode = "combine",
              priority = 201,
            })
            init = e + 1
          end
        end
        if locs[i] ~= "" then
          vim.api.nvim_buf_set_extmark(buf_id, grep_ns, i - 1, #texts[i], {
            end_row = i - 1,
            end_col = #texts[i] + #locs[i],
            hl_group = "Comment",
            hl_mode = "combine",
            priority = 200,
          })
        end
      end
    end

    -- Kept out of the file picker. `--hidden` stays on so dotfiles remain
    -- findable (this repo lives under hidden dirs like .config), but these are
    -- always noise.
    local file_ignore = {
      ".git",
      "node_modules",
      ".DS_Store",
      "*.lock", -- yarn.lock, Cargo.lock, poetry.lock, flake.lock, ...
      "*-lock.json", -- package-lock.json
      "*-lock.yaml", -- pnpm-lock.yaml
      "*.lockb", -- bun.lockb
      "build", -- C/C++ build folders
      ".build",
      ".cache",
    }
    local function pick_files()
      local cmd = { "rg", "--files", "--hidden" }
      for _, glob in ipairs(file_ignore) do
        cmd[#cmd + 1] = "--glob"
        cmd[#cmd + 1] = "!" .. glob
      end
      pick.builtin.cli({ command = cmd }, { source = { name = "Files" } })
    end

    vim.keymap.set({ "n", "x" }, "<c-p>", pick_files, { desc = "Pick files" })
    vim.keymap.set({ "n", "x" }, "<c-g>", function()
      pick.builtin.grep(
        {},
        { source = { show = grep_show }, window = { config = grep_win_config } }
      )
    end, { desc = "Grep" })
    vim.keymap.set({ "n", "x" }, "<c-_>", function()
      pick.builtin.grep_live(
        {},
        { source = { show = grep_show }, window = { config = grep_win_config } }
      )
    end, { desc = "Live grep" })
    vim.keymap.set({ "n", "x" }, "<c-/>", function()
      pick.builtin.grep_live(
        {},
        { source = { show = grep_show }, window = { config = grep_win_config } }
      )
    end, { desc = "Live grep" })
    vim.keymap.set({ "n", "x" }, "<c-b>", function()
      pick.builtin.buffers()
    end, { desc = "Pick buffers" })
    vim.keymap.set("n", "<leader>fd", function()
      pick.builtin.cli({
        command = {
          "fd",
          "--type",
          "d",
          "--hidden",
          "--exclude",
          ".git",
          "--exclude",
          "node_modules",
        },
      }, {
        source = {
          name = "Directories",
          choose = function(item)
            if item then
              require("oil").toggle_float(item)
            end
          end,
        },
      })
    end, { desc = "Open directory in oil" })

    require("conf.mini_statusline").setup()
  end,
}
