return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  event = {
    "BufReadPre " .. vim.fn.expand("~") .. "/notes/*.md",
    "BufNewFile " .. vim.fn.expand("~") .. "/notes/*.md",
  },
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    workspaces = {
      {
        name = "main",
        path = "~/notes",
      },
    },
    completion = {
      nvim_cmp = false,
      min_chars = 0,
    },
    picker = {
      name = "fzf-lua",
    },
    note_id_func = function(title)
      if title ~= nil then
        return title
      else
        local suffix = ""
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
        return suffix
      end
    end,
    frontmatter = {
      func = function(note)
        local out = { collection = "Uncategorised", tags = note.tags }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end
        return out
      end,
      sort = { "tags", "collections" },
    },
  },
}
