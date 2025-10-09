local U = {}

-- @class Autocommand
-- @field description string
-- @field event  string[] list of autocommand events
-- @field pattern string[] list of autocommand patterns
-- @field command string | function
-- @field nested  boolean
-- @field once    boolean
-- @field buffer  number

-- Create an autocommand
-- returns the group ID so that it can be cleared or manipulated.
-- @param name string
-- @param commands Autocommand[]
-- @return number
U.augroup = function(name, commands)
  local id = vim.api.nvim_create_augroup(name, { clear = true })

  for _, autocmd in ipairs(commands) do
    local is_callback = type(autocmd.command) == "function"
    vim.api.nvim_create_autocmd(autocmd.event, {
      group = id,
      pattern = autocmd.pattern,
      desc = autocmd.description,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

--- @class CommandArgs
--- @field args string
--- @field fargs table
--- @field bang boolean

---Create an nvim command
---@param name any
---@param rhs string | function(args: CommandArgs)
---@param opts table
function U.command(name, rhs, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, rhs, opts)
end

-- Reload current buffer if it is a vim or lua file
U.source_filetype = function()
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  if ft == "lua" or ft == "vim" then
    vim.cmd("source %")
    Snacks.notify.info(ft .. " file reloaded!")
  else
    Snacks.notify.error("Not a lua or vim file")
  end
end

U.is_git_directory = function()
  local git_dir = io.popen("git rev-parse --git-dir 2>/dev/null")
  if git_dir then
    local git_dir_result = git_dir:read("*a")
    git_dir:close()

    return git_dir_result ~= ""
  end
end

local function branch_name()
  local cmd_output = vim.fn.systemlist("git branch --show-current 2> /dev/null")
  return #cmd_output > 0 and cmd_output[1] or ""
end

-- Display the filename in the statusbar
local function file_name()
  local root_path = vim.fn.getcwd()
  local root_dir = root_path:match("[^/]+$")
  local home_path = vim.fn.expand("%:~")
  local overlap, _ = home_path:find(root_dir)
  if home_path == "" then
    return root_path:gsub("/Users/[^/]+", "~")
  elseif overlap then
    return home_path:sub(overlap)
  else
    return home_path
  end
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "FocusGained" }, {
  callback = function()
    vim.b.branch_name = branch_name()
    vim.b.file_name = file_name()
  end,
})

function U._echo_multiline(msg)
  for _, s in ipairs(vim.fn.split(msg, "\n")) do
    vim.cmd("echom '" .. s:gsub("'", "''") .. "'")
  end
end

function U.prequire(...)
  local status, lib = pcall(require, ...)
  if status then
    return lib
  end
  return nil
end

-- sudo write and execute within neovim
-- directly stolen from https://github.com/ibhagwan/nvim-lua/blob/main/lua/utils.lua#L307
return U
