local lvim = require 'lir.vim'
local config = require'lir.config'

local a = vim.api

-----------------------------
-- Private
-----------------------------

---@param bufnr number
---@param win_id number
local function setup_autocmd(bufnr, win_id)
  -- By delaying it a bit, we can make it look like it's not closed when we move the directory.
  vim.cmd(string.format(
              [[autocmd BufWipeout,BufHidden,WinClosed <buffer=%s> ++nested ++once :lua
                  vim.defer_fn(function()
                    require('plenary.window').try_close(%s, true)
                  end, 10)]],
              bufnr, win_id))
end

---@return string
local function get_curdir()
  return vim.fn.fnamemodify(lvim.get_context().dir, ':~')
end

---@param content_win_id number
local function create_curdir_window(content_win_id)
  local content_bufnr = a.nvim_get_current_buf()
  local content_win_config = a.nvim_win_get_config(content_win_id)

  local curdir_bufnr = a.nvim_create_buf(false, true)
  local win_id = a.nvim_open_win(curdir_bufnr, false, {
    style = 'minimal',
    row = content_win_config.row[false] - 1,
    col = content_win_config.col[false],
    width = content_win_config.width,
    height = 1,
    relative = 'editor',
    focusable = false,
  })

  a.nvim_buf_set_lines(curdir_bufnr, 0, -1, false, {get_curdir()})
  setup_autocmd(content_bufnr, win_id)
end

-----------------------------
-- Export
-----------------------------

---@class lir_curdir_window
local curdir_window = {}

function curdir_window.new()
  local win = vim.t.lir_float_winid
  if config.values.float.border then
    -- To be displayed in border.lua
    return
  end
  if win and a.nvim_win_is_valid(win) then
    create_curdir_window(win)
  end
end

curdir_window.get_curdir = get_curdir

return curdir_window
