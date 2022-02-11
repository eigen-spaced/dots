local M = {}

function M.config()
  local status_ok, trouble = pcall(require, "trouble")

  if not status_ok then
    return
  end

  trouble.setup {
    open_split = { "<c-x>" },
  }
end

return M
