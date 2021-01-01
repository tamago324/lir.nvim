local lvim = require 'lir.vim'

local api = vim.api

local CurdirWindow = {}

local function setup_autocmd(bufnr, win_id)
  vim.cmd(string.format(
              "autocmd WinClosed <buffer=%s> ++nested ++once :lua require('plenary.window').try_close(%s, true)",
              bufnr, win_id))
end

function CurdirWindow.new(content_bufnr, content_win_id)
  local self = setmetatable({}, {__index = CurdirWindow})
  local context_win_config = api.nvim_win_get_config(content_win_id)

  self.content_bufnr = content_bufnr
  self.content_win_id = content_win_id
  self.bufnr = api.nvim_create_buf(false, true)
  self.win_id = api.nvim_open_win(self.bufnr, false, {
    style = 'minimal',
    row = context_win_config.row[false] - 1,
    col = context_win_config.col[false],
    width = context_win_config.width,
    height = 1,
    relative = 'editor',
    focusable = false,
  })

  api.nvim_buf_set_lines(self.bufnr, 0, -1, false,
                         {vim.fn.fnamemodify(lvim.get_context().dir, ':~')})
  setup_autocmd(content_bufnr, self.win_id)
  return self
end

function _G._LirFloatSetCurdirText()
  if vim.w.lir_is_float and vim.w.lir_curdir_win then
    local dir = vim.fn.fnamemodify(lvim.get_context().dir, ':~')
    api.nvim_buf_set_lines(vim.w.lir_curdir_win.bufnr, 0, -1, false, {dir})
  end
end

function _G._LirFloatSetupAutocmd()
  if vim.w.lir_curdir_win then
    setup_autocmd(vim.fn.bufnr(), vim.w.lir_curdir_win.win_id)
  end
end

vim.cmd([[augroup lir-float]])
vim.cmd([[  autocmd!]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetCurdirText()]])
vim.cmd([[  autocmd FileType lir :lua _LirFloatSetupAutocmd()]])
vim.cmd([[augroup END]])

return CurdirWindow
