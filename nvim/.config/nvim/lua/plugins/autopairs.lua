return {
  "windwp/nvim-autopairs",
  -- event = "VeryLazy",
  config = function()
    require("nvim-autopairs").setup {}

    local autopairs = require("nvim-autopairs")
    local cond = require("nvim-autopairs.conds")
    local Rule = require("nvim-autopairs.rule")

    -- remove add single quote on filetype scheme or lisp
    autopairs.get_rules("`")[1].not_filetypes = { "clojure", "lisp" }
    autopairs.get_rules("'")[1].not_filetypes = { "clojure", "lisp" }
    -- autopairs.get_rules("(")[1].not_filetypes = { "clojure", "lisp" }

    autopairs.add_rules {
      -- Rule to insert only '() without adding duplicate quotes
      Rule("'", ")", { "clojure", "lisp" })
        :with_pair(cond.not_after_text("("))
        :with_move(cond.none())
        :with_cr(cond.none())
        :use_key("("), -- Trigger on typing '('
    }
  end,
}
