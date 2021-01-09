local win_float = require 'plenary.window.float'
local actions = require 'lir.actions'
local lvim = require 'lir.vim'
local config = require 'lir.config'

local api = vim.api

local float = {}

local function find_lir_float_win()
  for i, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    local is_float = vim.F.npcall(api.nvim_win_get_var, win, 'lir_is_float')
    if api.nvim_buf_get_option(buf, 'filetype') == 'lir' and is_float then
      return win
    end
  end
  return nil
end


--- toggle
function float.toggle(dir)
  local float_win = find_lir_float_win()
  if float_win then
    api.nvim_set_current_win(float_win)
    actions.quit()
  else
    float.init(dir)
  end
end

--- init
function float.init(dir_path)
  local dir, file
  if vim.bo.filetype == 'lir' then
    dir = lvim.get_context().dir
    file = lvim.get_context():current_value()
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
end

return {
  init = float.init,
  toggle = float.toggle,
}
