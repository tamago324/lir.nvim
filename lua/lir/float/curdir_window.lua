local lvim = require 'lir.vim'

local a = vim.api

-----------------------------
-- Private
-----------------------------
local function setup_autocmd(bufnr, win_id)
  -- By delaying it a bit, we can make it look like it's not closed when we move the directory.
  vim.cmd(string.format(
              "autocmd BufWipeout,BufHidden,WinClosed <buffer=%s> ++nested ++once :lua vim.defer_fn(function() require('plenary.window').try_close(%s, true) end, 10)",
              bufnr, win_id))
end

local function create_curdir_window(content_win_id)
  local content_bufnr = a.nvim_get_current_buf()
  local context_win_config = a.nvim_win_get_config(content_win_id)

  curdir_bufnr = a.nvim_create_buf(false, true)
  win_id = a.nvim_open_win(curdir_bufnr, false, {
    style = 'minimal',
    row = context_win_config.row[false] - 1,
    col = context_win_config.col[false],
    width = context_win_config.width,
    height = 1,
    relative = 'editor',
    focusable = false,
  })

  a.nvim_buf_set_lines(curdir_bufnr, 0, -1, false,
                         {vim.fn.fnamemodify(lvim.get_context().dir, ':~')})
  setup_autocmd(content_bufnr, win_id)
end

-----------------------------
-- Export
-----------------------------
local curdir_window = {}

function curdir_window.new()
  local win = vim.t.lir_float_winid
  if win and a.nvim_win_is_valid(win) then
    create_curdir_window(win)
  end
end

return curdir_window
