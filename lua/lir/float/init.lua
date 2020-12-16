local win_float = require 'plenary.window.float'
local actions = require 'lir.actions'
local CurdirWindow = require 'lir.float.curdir_window'
local lvim = require 'lir.vim'
local config = require 'lir.config'

local api = vim.api

local float = {}

local function is_show()
  for i, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    local is_float = vim.F.npcall(api.nvim_win_get_var, win, 'lir_is_float')
    if api.nvim_buf_get_option(buf, 'filetype') == 'lir' and is_float then
      return true
    end
  end
  return false
end

--- toggle
function float.toggle(dir)
  if is_show() then
    vim.api.nvim_set_current_win(vim.t.lir_float_winid)
    actions.quit()
  else
    float.init(dir)
  end
end

--- init
function float.init(dir_path)
  local dir, file
  if vim.bo.filetype == 'lir' then
    dir = lvim.b.context.dir
    file = lvim.b.context:current()
  else
    dir = dir_path or vim.fn.expand('%:p:h')
    file = vim.fn.expand('%:p')
  end
  local info = win_float.centered({
    percentage = config.values.float.size_percentage,
    winblend = config.values.float.winblend,
  })
  vim.t.lir_float_winid = info.win_id
  -- To move the cursor
  vim.w.lir_file_jump_cursor = file
  vim.cmd('edit ' .. vim.fn.fnameescape(dir))
  vim.w.lir_is_float = true
  vim.w.lir_curdir_win = CurdirWindow.new(info.bufnr, info.win_id)
end

return float
