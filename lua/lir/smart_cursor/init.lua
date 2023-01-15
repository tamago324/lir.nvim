--[[

This was written based on fern.vim under the MIT License.

Original code: https://git.io/Jt4L9
]]

local config = require("lir.config")

---@class lir_smart_cursor
local M = {}

local guicursor_saved = nil

local function hide_cursor_init()
  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "CmdwinLeave", "CmdlineLeave" }, {
    buffer = bufnr,
    command = "setlocal cursorline",
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "CmdwinEnter", "CmdlineEnter" }, {
    buffer = bufnr,
    command = "setlocal nocursorline",
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "CmdwinLeave", "CmdlineLeave" }, {
    buffer = bufnr,
    callback = M._hide,
  })

  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "CmdwinEnter", "CmdlineEnter" }, {
    buffer = bufnr,
    callback = M._restore,
  })

  vim.api.nvim_create_autocmd({ "VimLeave" }, {
    buffer = bufnr,
    callback = M._restore,
  })
end

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
