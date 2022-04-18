-- local a = vim.api

-----------------------------
-- Export
-----------------------------

---@class lir_utils
local utils = {}

---@param msg string
function utils.error(msg)
  vim.cmd([[redraw]])
  vim.cmd([[echohl Error]])
  vim.cmd(string.format([[echomsg '%s']], msg))
  vim.cmd([[echohl None]])
end

---@alias lir.WinVarName
---   "'lir_file_jump_cursor'"
--- | "'lir_is_float'"
--- | "'lir_curdir_win'"
--- | "'lir_prev_filetype'"
--- | "'lir_file_quit_on_edit'"

--- Use vim.F.npcall() to return the result of nvim_win_get_var()
---@param name lir.WinVarName
---@param win? any
---@return any
function utils.win_get_var(name, win)
  win = win or 0
  return vim.F.npcall(vim.api.nvim_win_get_var, win, name)
end

return utils
