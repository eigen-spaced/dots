-- pnpm installs global bins as shell shims, not symlinks, so typescript-tools'
-- own discovery (project node_modules -> npm root -g -> resolved exepath) never
-- reaches the pnpm-global typescript.  Locate tsserver.js through the shim's
-- cmd-shim-target trailer, which pnpm rewrites on every global change, so this
-- survives upgrades.  Returns nil when the project carries its own typescript:
-- tsserver_path outranks every other lookup, and a pinned local TS should win.
local function pnpm_global_tsserver()
  local buf_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  local node_modules = vim.fs.find("node_modules", {
    upward = true,
    type = "directory",
    limit = math.huge,
    path = buf_dir,
  })
  for _, dir in ipairs(node_modules) do
    if vim.uv.fs_stat(dir .. "/typescript/lib/tsserver.js") then
      return nil
    end
  end
  local shim = vim.fn.exepath("tsserver")
  if shim == "" or vim.fn.filereadable(shim) == 0 then
    return nil
  end
  for _, line in ipairs(vim.fn.readfile(shim)) do
    local target = line:match("cmd%-shim%-target=(.+)$")
    if target then
      local tsserver_js = target:gsub("bin/tsserver$", "lib/tsserver.js")
      if vim.uv.fs_stat(tsserver_js) then
        return tsserver_js
      end
    end
  end
end

return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {},
  config = function()
    require("typescript-tools").setup {
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
      },
      settings = {
        tsserver_path = pnpm_global_tsserver(),
        separate_diagnostic_server = true,
        tsserver_max_memory = "auto",
        single_file_support = false,
        tsserver_plugins = {
          "@vue/typescript-plugin",
        },
      },
    }
  end,
}
