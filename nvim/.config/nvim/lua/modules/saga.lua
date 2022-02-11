local M = {}

function M.config()
  local status_ok, saga = pcall(require, "lspsaga")

  if not status_ok then
    return
  end

  saga.init_lsp_saga {
    error_sign = " 🞮",
    warn_sign = " ▲",
    hint_sign = " ",
    infor_sign = " ",
    code_action_prompt = {
      enable = true,
      sign = true,
      sign_priority = 15,
      virtual_text = false,
    },
    code_action_keys = { quit = { "q", "<ESC>" }, exec = "<CR>" },
  }
end

return M
