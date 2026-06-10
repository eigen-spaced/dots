return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel" }, -- etc
    lazy = true,
    init = function()
      -- This is VERY helpful when reporting an issue with the project
      -- vim.g["conjure#debug"] = true
      vim.g["conjure#mapping#doc_word"] = "gk"
    end,
  },

  {
    "julienvincent/nvim-paredit",
    config = function()
      require("nvim-paredit").setup()
    end,
  },
}
