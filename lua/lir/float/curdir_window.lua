local lvim = require("lir.vim")
local config = require("lir.config")
local Path = require("plenary.path")
local utils = require("lir.utils")

local api = vim.api

local CurdirWindow = {}

local ns = api.nvim_create_namespace("lir_curdir_win")

local function setup_autocmd_win_close(bufnr, win_id)
  vim.api.nvim_create_autocmd({ "WinClosed" }, {
    buffer = bufnr,
    nested = true,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win_id, true)
    end,
  })
end

-- from plenary
local split_by_separator = (function()
  local formatted = string.format("([^%s]+)", Path.path.sep)
  return function(filepath)
    local t = {}
    for str in string.gmatch(filepath, formatted) do
      table.insert(t, str)
    end
    return t
  end
end)()

local reverse = function(list)
  local n = #list
  local i = 1
  while i < n do
    list[i], list[n] = list[n], list[i]
    i = i + 1
    n = n - 1
  end
  return list
end

local normalize_path = function(filepath, width)
  local parts = split_by_separator(vim.fn.fnamemodify(filepath, ":~"))
  -- 切り上げるところ
  local threshold = width * 0.6

  local res = ""
  for i, part in ipairs(reverse(parts)) do
    -- '/' と 先頭の1文字で 2 になる計算
    if (res:len() + (2 * (#parts - i))) > threshold then
      res = part:sub(1, 1) .. Path.path.sep .. res
    else
      res = part .. Path.path.sep .. res
    end
  end

  if res:sub(1, 1) == "~" then
    return res
  end

  return Path.path.root() .. res
end

local hl_curdir_name = function(bufnr)
  local text = api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
  local start, _end = text:find(string.format("[^%s]+%s$", Path.path.sep, Path.path.sep))
  if start == nil or _end == nil then
    return
  end
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  api.nvim_buf_add_highlight(bufnr, ns, "LirFloatCurdirWindowDirName", 0, start - 1, _end)
end

local setup_curdir_text = function(lir_curdir_win)
  if config.values.float.curdir_window.enable and utils.win_get_var("lir_is_float") and lir_curdir_win then
    -- local dir = vim.fn.fnamemodify(lvim.get_context().dir, ":~")
    local width = api.nvim_win_get_config(lir_curdir_win.win_id).width
    local dir = normalize_path(lvim.get_context().dir, width)
    api.nvim_buf_set_lines(lir_curdir_win.bufnr, 0, -1, false, { dir })
    if config.values.float.curdir_window.highlight_dirname then
      hl_curdir_name(lir_curdir_win.bufnr)
    end

    vim.api.nvim_exec_autocmds("User", {
      modeline = false,
      pattern = "LirSetTextFloatCurdirWindow",
    })
  end
end

function CurdirWindow.new(content_win_id, win_config)
  local self = setmetatable({}, { __index = CurdirWindow })
  local context_win_config = api.nvim_win_get_config(content_win_id)

  local border_line = 0
  if win_config.border ~= nil and win_config.border ~= "none" and win_config.border ~= "shadow" then
    -- none 以外なら、1増やす
    border_line = 1
  end

  local win_config_row = context_win_config.row
  if type(win_config_row) ~= "number" then
    win_config_row = win_config_row[false]
  end
  local win_config_col = context_win_config.col
  if type(win_config_col) ~= "number" then
    win_config_col = win_config_col[false]
  end

  self.content_bufnr = vim.api.nvim_win_get_buf(content_win_id)
  self.content_win_id = content_win_id
  self.bufnr = api.nvim_create_buf(false, true)
  self.win_id = api.nvim_open_win(self.bufnr, false, {
    style = "minimal",
    row = win_config_row - 1 - border_line,
    col = win_config_col,
    width = context_win_config.width,
    height = 1,
    relative = "editor",
    focusable = false,
    border = win_config.border,
  })

  -- Since the process after this may result in an error, set it here
  api.nvim_win_set_option(
    self.win_id,
    "winhl",
    "Normal:LirFloatCurdirWindowNormal,EndOfBuffer:LirFloatCurdirWindowNormal,FloatBorder:LirFloatBorder"
  )
  setup_autocmd_win_close(self.content_bufnr, self.win_id)

  vim.w.lir_curdir_win = self
  setup_curdir_text(self)

  return self
end

local setup_autocmd_curdir_window = function()
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "lir",
    callback = function()
      local curdir_win = utils.win_get_var("lir_curdir_win")
      if config.values.float.curdir_window.enable and curdir_win and utils.win_get_var("lir_is_float") then
        setup_autocmd_win_close(vim.api.nvim_get_current_buf(), curdir_win.win_id)
        setup_curdir_text(curdir_win)
      end
    end,
  })
end
setup_autocmd_curdir_window()

return CurdirWindow
