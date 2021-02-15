local win_float = require 'plenary.window.float'
local actions = require 'lir.actions'
local lvim = require 'lir.vim'
local config = require 'lir.config'

local a = vim.api


-----------------------------
-- Private
-----------------------------

---@return number
local function find_lir_float_win()
  for _, win in ipairs(a.nvim_tabpage_list_wins(0)) do
    local buf = a.nvim_win_get_buf(win)
    local is_float = vim.F.npcall(a.nvim_win_get_var, win, 'lir_is_float')
    if a.nvim_buf_get_option(buf, 'filetype') == 'lir' and is_float then
      return win
    end
  end
  return nil
end


-----------------------------
-- Export
-----------------------------

---@class lir_float
local float = {}

---@param dir string
function float.toggle(dir)
  local float_win = find_lir_float_win()
  if float_win then
    a.nvim_set_current_win(float_win)
    actions.quit()
  else
    float.init(dir)
  end
end

---@param dir_path? string
function float.init(dir_path)
  local dir, file, old_win
  if vim.bo.filetype == 'lir' then
    dir = lvim.get_context().dir
    file = lvim.get_context():current_value()

    if not vim.w.lir_is_float then
      old_win = a.nvim_get_current_win()
    end
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

  a.nvim_win_set_option(info.win_id, 'winhl', 'Normal:LirFloatNormal')

  -- 空バッファに置き換える
  if old_win then
    a.nvim_win_set_buf(old_win, a.nvim_create_buf(true, false))
  end
end

return float
