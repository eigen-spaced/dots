local M = {}

function M.config()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
    ignore_install = { "java", "php", "kotlin", "scala" }, -- List of parsers to ignore installing
    highlight = {
      enable = true,              -- false will disable the whole extension
      disable = { "cpp", "rust", "go" },  -- list of language that will be disabled
      use_languagetree = true,
    },
    indent = {
      enable = true
    }
  }
end

return M
