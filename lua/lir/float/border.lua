local Border = require'plenary.window.border'
local config = require'lir.config'

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


local create_border = function(content_win_id)
  local content_bufnr = a.nvim_win_get_buf(content_win_id)
  local win_config = a.nvim_win_get_config(content_win_id)
  win_config.row = win_config.row[false] - 1
  win_config.col = win_config.col[false]
  win_config.height = win_config.height + 1 -- height of curdir_window

  local b_top , b_right , b_bot , b_left , b_topleft , b_topright , b_botright , b_botleft =
    unpack(config.values.float.borderchars)

  local thickness = Border._default_thickness
  local opts = {
    border_thickness = thickness,
    top = b_top,
    bot = b_bot,
    right = b_right,
    left = b_left,
    topleft = b_topleft,
    topright = b_topright,
    botright = b_botright,
    botleft = b_botleft,
  }

  local bufnr = vim.api.nvim_create_buf(false, true)
  local contents = Border._create_lines(win_config, opts)

  a.nvim_buf_set_lines(bufnr, 0, -1, false, contents)

  local border_win_id = a.nvim_open_win(bufnr, false, {
    anchor = win_config.anchor,
    relative = win_config.relative,
    style = "minimal",
    row = win_config.row - thickness.top,
    col = win_config.col - thickness.left,
    width = win_config.width + thickness.left + thickness.right,
    height = win_config.height + thickness.top + thickness.bot,
    focusable = false,
  })

  setup_autocmd(content_bufnr, border_win_id)

  a.nvim_win_set_option(border_win_id, 'winhl', 'Normal:LirFloatBorder')
end


-----------------------------
-- Export
-----------------------------
local M = {}


M.new = function()
  local win = vim.t.lir_float_winid
  if win and config.values.float.border and a.nvim_win_is_valid(win) then
    create_border(win)
  end
end


return M
