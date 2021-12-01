--[[

This was written based on fern.vim under the MIT License.

Original code: https://git.io/Jt4L9
]]

local config = require("lir.config")

-----------------------------
-- Private
-----------------------------
local guicursor_saved = nil

local function hide_cursor_init()
  vim.cmd([[augroup lir-smart-cursor]])
  vim.cmd([[  autocmd! * <buffer>]])
  vim.cmd([[  autocmd BufEnter,WinEnter,CmdwinLeave,CmdlineLeave <buffer> setlocal cursorline]])
  vim.cmd([[  autocmd BufLeave,WinLeave,CmdwinEnter,CmdlineEnter <buffer> setlocal nocursorline]])
  vim.cmd([[  autocmd BufEnter,WinEnter,CmdwinLeave,CmdlineLeave <buffer> lua require'lir.smart_cursor'._hide()]])
  vim.cmd([[  autocmd BufLeave,WinLeave,CmdwinEnter,CmdlineEnter <buffer> lua require'lir.smart_cursor'._restore()]])
  vim.cmd([[  autocmd VimLeave <buffer> lua require'lir.smart_cursor'._restore()]])
  vim.cmd([[augroup END]])
end

-----------------------------
-- Export
-----------------------------

---@class lir_smart_cursor
local M = {}

function M._hide()
  if not guicursor_saved then
    guicursor_saved = vim.api.nvim_get_option("guicursor")
  end

  vim.api.nvim_set_option("guicursor", guicursor_saved .. ",a:LirTransparentCursor/lCursor")
end

function M._restore()
  vim.api.nvim_set_option("guicursor", guicursor_saved)
end

function M.init()
  if not config.values.hide_cursor then
    return
  end
  hide_cursor_init()
  M._hide()
end

return M
