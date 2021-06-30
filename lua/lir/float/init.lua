local actions = require("lir.actions")
local lvim = require("lir.vim")
local config = require("lir.config")
local helper = require("lir.float.helper")

local a = vim.api

---@class lir_float
local float = {}

--- 中央配置のウィンドウを開く
---@return number win_id
local function open_win(opts, winblend)
  local bufnr = a.nvim_create_buf(false, true)
  local win_id = a.nvim_open_win(bufnr, true, opts)

  vim.cmd("setlocal nocursorcolumn")
  a.nvim_win_set_option(win_id, "winblend", winblend)

  vim.cmd(string.format("autocmd WinLeave <buffer> silent! execute 'bdelete! %s'", bufnr))

  return win_id
end

---@return number
local function find_lir_float_win()
  for _, win in ipairs(a.nvim_tabpage_list_wins(0)) do
    local buf = a.nvim_win_get_buf(win)
    local is_float = vim.F.npcall(a.nvim_win_get_var, win, "lir_is_float")
    if a.nvim_buf_get_option(buf, "filetype") == "lir" and is_float then
      return win
    end
  end
  return nil
end

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

-- setlocal を使っているため、毎回セットする必要があるため BufWinEnter で呼び出す
function float.setlocal_winhl()
  if vim.w.lir_is_float then
    vim.cmd([[setlocal winhl=Normal:LirFloatNormal,EndOfBuffer:LirFloatNormal]])
  end
end

---@param dir_path? string
function float.init(dir_path)
  local dir, file, old_win
  if vim.bo.filetype == "lir" and dir_path == nil then
    dir = lvim.get_context().dir
    file = lvim.get_context():current_value()

    if not vim.w.lir_is_float then
      old_win = a.nvim_get_current_win()
    end
  else
    dir = dir_path or vim.fn.expand("%:p:h")
    file = vim.fn.expand("%:p")
  end

  local win_config
  if type(config.values.float.make_win_config) == "function" then
    win_config = config.values.float.make_win_config(win_config)
  else
    win_config = helper.make_default_win_config()
  end

  local win_id = open_win(win_config, config.values.float.winblend)

  vim.t.lir_float_winid = win_id
  -- To move the cursor
  if file then
    vim.w.lir_file_jump_cursor = file
  end
  vim.cmd("edit " .. vim.fn.fnameescape(dir))
  vim.w.lir_is_float = true

  float.setlocal_winhl()

  -- 空バッファに置き換える
  if old_win then
    a.nvim_win_set_buf(old_win, a.nvim_create_buf(true, false))
  end
end

return float
