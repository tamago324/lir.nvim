local lvim = require("lir.vim")
local config = require("lir.config")

local api = vim.api

local CurdirWindow = {}

local function setup_autocmd(bufnr, win_id)
  vim.cmd(
    string.format(
      "autocmd WinClosed <buffer=%s> ++nested ++once :lua pcall(vim.api.nvim_win_close, %s, true)",
      bufnr,
      win_id
    )
  )
end

function CurdirWindow.new(content_win_id, user_win_opts)
  local self = setmetatable({}, { __index = CurdirWindow })
  local context_win_config = api.nvim_win_get_config(content_win_id)

  local border_line = 0
  if user_win_opts.border ~= nil and user_win_opts.border ~= "none" and user_win_opts.border ~= "shadow" then
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
    border = user_win_opts.border,
  })

  api.nvim_buf_set_lines(self.bufnr, 0, -1, false, { vim.fn.fnamemodify(lvim.get_context().dir, ":~") })
  api.nvim_win_set_option(
    self.win_id,
    "winhl",
    "Normal:LirFloatCurdirWindowNormal,EndOfBuffer:LirFloatCurdirWindowNormal"
  )
  setup_autocmd(self.content_bufnr, self.win_id)
  return self
end

function _G._LirFloatSetCurdirText()
  if config.values.float.curdir_window_enable and vim.w.lir_is_float and vim.w.lir_curdir_win then
    local dir = vim.fn.fnamemodify(lvim.get_context().dir, ":~")
    api.nvim_buf_set_lines(vim.w.lir_curdir_win.bufnr, 0, -1, false, { dir })
  end
end

function _G._LirFloatSetupAutocmd()
  if config.values.float.curdir_window_enable and vim.w.lir_curdir_win then
    setup_autocmd(vim.fn.bufnr(), vim.w.lir_curdir_win.win_id)
  end
end

vim.cmd([[augroup lir-float-curdir-window]])
vim.cmd([[  autocmd!]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetCurdirText()]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetupAutocmd()]])
vim.cmd([[augroup END]])

return CurdirWindow
