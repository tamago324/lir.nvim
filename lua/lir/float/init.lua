local actions = require("lir.actions")
local lvim = require("lir.vim")
local config = require("lir.config")
local CurdirWindow = require("lir.float.curdir_window")
local smart_cursor = require'lir.smart_cursor'

local a = vim.api

---@class lir_float
local float = {}

local default_win_opts = {
  width = 0.5,
  height = 0.5,
  border = "double",
}

--- Return the default value of the option
---@return table
local make_default_win_config = function()
  local width = math.floor(vim.o.columns * default_win_opts.width)
  local height = math.floor(vim.o.lines * default_win_opts.height)

  local result = {
    relative = "editor",
    width = width,
    height = height,
    style = "minimal",
    border = default_win_opts.border,
  }

  return result
end

--- Calculate the floating window position according to the given width and
--- height if the user didn't define them.
---@param win_config table
---@return table
local function calculate_position(win_config)
  if not win_config.row then
    win_config.row = (vim.o.lines / 2) - (win_config.height / 2) - 1
  end
  if not win_config.col then
    win_config.col = (vim.o.columns / 2) - (win_config.width / 2)
  end
  return win_config
end

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

---Is the current buffer terminal?
---@return boolean
local function is_terminal_current_win()
  local current_win_info = vim.fn["getwininfo"](vim.api.nvim_get_current_win())
  if current_win_info == nil or #current_win_info == 0 then
    return false
  end
  return current_win_info[1].terminal == 1
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
    if is_terminal_current_win() then
      --- If terminal, use cwd
      dir = dir_path or vim.fn["getcwd"]()
      file = nil
    else
      dir = dir_path or vim.fn.expand("%:p:h")
      file = vim.fn.expand("%:p")
    end
  end

  local user_win_opts = {}
  if type(config.values.float.win_opts) == "function" then
    user_win_opts = config.values.float.win_opts()
  end

  local win_config = vim.tbl_extend("force", make_default_win_config(), user_win_opts)
  win_config = calculate_position(win_config)
  local win_id = open_win(win_config, config.values.float.winblend)

  vim.t.lir_float_winid = win_id
  -- To move the cursor
  if file then
    vim.w.lir_file_jump_cursor = file
  end
  vim.cmd("edit " .. vim.fn.fnameescape(dir))
  vim.w.lir_is_float = true

  -- current directory window
  if config.values.float.curdir_window.enable then
    vim.w.lir_curdir_win = CurdirWindow.new(win_id, win_config)

    -- After creating curdir window, the cursor will restore, so hide it.
    if config.values.hide_cursor then
      smart_cursor._hide()
    end
  end

  float.setlocal_winhl()

  -- 空バッファに置き換える
  if old_win then
    a.nvim_win_set_buf(old_win, a.nvim_create_buf(true, false))
  end
end

return float
