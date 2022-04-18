local lvim = require("lir.vim")
local config = require("lir.config")
local Path = require("plenary.path")
local utils = require("lir.utils")

local api = vim.api

local CurdirWindow = {}

local ns = api.nvim_create_namespace("lir_curdir_win")

local function setup_autocmd(bufnr, win_id)
  vim.cmd(
    string.format(
      "autocmd WinClosed <buffer=%s> ++nested ++once :lua pcall(vim.api.nvim_win_close, %s, true)",
      bufnr,
      win_id
    )
  )
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

function CurdirWindow.new(content_win_id, win_config)
  local self = setmetatable({}, { __index = CurdirWindow })
  local context_win_config = api.nvim_win_get_config(content_win_id)

  local border_line = 0
  if win_config.border ~= nil and win_config.border ~= "none" and win_config.border ~= "shadow" then
    -- none 以外なら、1増やす
    border_line = 1
  end

  self.content_bufnr = vim.api.nvim_win_get_buf(content_win_id)
  self.content_win_id = content_win_id
  self.bufnr = api.nvim_create_buf(false, true)
  self.win_id = api.nvim_open_win(self.bufnr, false, {
    style = "minimal",
    row = context_win_config.row[false] - 1 - border_line,
    col = context_win_config.col[false],
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
  setup_autocmd(self.content_bufnr, self.win_id)

  vim.w.lir_curdir_win = self
  _G._LirFloatSetCurdirText(self)

  return self
end

function _G._LirFloatSetCurdirText(lir_curdir_win)
  lir_curdir_win = vim.F.if_nil(lir_curdir_win, utils.win_get_var("lir_curdir_win"))
  if config.values.float.curdir_window.enable and utils.win_get_var("lir_is_float") and lir_curdir_win then
    -- local dir = vim.fn.fnamemodify(lvim.get_context().dir, ":~")
    local width = api.nvim_win_get_config(lir_curdir_win.win_id).width
    local dir = normalize_path(lvim.get_context().dir, width)
    api.nvim_buf_set_lines(lir_curdir_win.bufnr, 0, -1, false, { dir })
    if config.values.float.curdir_window.highlight_dirname then
      hl_curdir_name(lir_curdir_win.bufnr)
    end

    vim.cmd("doautocmd <nomodeline> User LirSetTextFloatCurdirWindow")
  end
end

function _G._LirFloatSetupAutocmd()
  if config.values.float.curdir_window.enable and utils.win_get_var("lir_curdir_win") then
    setup_autocmd(vim.fn.bufnr(), utils.win_get_var("lir_curdir_win").win_id)
  end
end

vim.cmd([[augroup lir-float-curdir-window]])
vim.cmd([[  autocmd!]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetCurdirText()]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetupAutocmd()]])
vim.cmd([[augroup END]])

return CurdirWindow
