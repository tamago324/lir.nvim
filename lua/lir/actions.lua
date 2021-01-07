local history = require 'lir.history'
local utils = require 'lir.utils'
local Context = require 'lir.context'
local config = require 'lir.config'
local lvim = require 'lir.vim'
local Path = require 'plenary.path'

local vim = vim
local uv = vim.loop

local actions = {}

-----------------------------
-- Private
-----------------------------
local function open(cmd, context)
  if not context:current_value() then
    return
  end
  local filename = vim.fn.fnameescape(context.dir .. context:current_value())
  actions.quit()
  vim.cmd(cmd .. ' ' .. filename)
end

-----------------------------
-- Export
-----------------------------

--- edit
function actions.edit(context)
  local dir, file = context.dir, context:current_value()
  if not file then
    return
  end

  if vim.w.lir_is_float and not context:is_dir_current() then
    -- 閉じてから開く
    actions.quit()
  end

  vim.cmd('keepalt edit ' .. vim.fn.fnameescape(dir .. file))
  history.add(dir, file)
end

--- split
function actions.split(context)
  open('new', context)
end

--- vsplit
function actions.vsplit(context)
  open('vnew', context)
end

--- tabedit
function actions.tabedit(context)
  open('tabedit', context)
end

--- up
function actions.up(context)
  local cur_file, path, name, dir

  cur_file = context:current_value()
  path = string.gsub(context.dir, '/$', '')
  name = vim.fn.fnamemodify(path, ':t')
  if name == '' then
    return
  end
  dir = vim.fn.fnamemodify(path, ':p:h:h')
  history.add(path, cur_file)
  history.add(dir, name)
  vim.cmd('edit ' .. dir)
end

--- quit
function actions.quit()
  if vim.w.lir_is_float then
    vim.api.nvim_win_close(0, true)
  else
    vim.cmd('edit ' .. vim.w.lir_file_quit_on_edit)
  end
end

--- mkdir
function actions.mkdir(context)
  local name = vim.fn.input('Create directory: ')
  if name == '' then
    return
  end

  if name == '.' or name == '..' or string.match(name, '[/\\]') then
    utils.error('Invalid directory name: ' .. name)
    return
  end

  local path = Path:new(context.dir .. name)
  if path:exists() then
    utils.error('Directory already exists')
    -- cursor jump
    vim.cmd(tostring(context:indexof(name)))
    return
  end

  path:mkdir()

  actions.reload()

  vim.schedule(function()
    local lnum = lvim.get_context():indexof(name)
    vim.cmd(tostring(lnum))
  end)
end

--- rename
function actions.rename(context)
  local old = string.gsub(context:current_value(), '/$', '')
  local new = vim.fn.input('Rename: ', old)
  if new == '' or new == old then
    return
  end

  if new == '.' or new == '..' or string.match(new, '[/\\]') then
    utils.error('Invalid name: ' .. new)
    return
  end

  if not uv.fs_rename(context.dir .. old, context.dir .. new) then
    utils.error('Rename failed')
  end

  actions.reload()
end

--- delete
function actions.delete(context)
  local name = context:current_value()

  if vim.fn.confirm('Delete?: ' .. name, '&Yes\n&No\n&Force', 2) == 2 then
    return
  end

  local path = context.dir .. name
  if vim.fn.isdirectory(path) == 1 then
    if not uv.fs_rmdir(path) then
      utils.error('Delete directory failed')
      return
    end
  else
    if not uv.fs_unlink(path) then
      utils.error('Delete file failed')
      return
    end
  end

  actions.reload()
end

--- newfile
function actions.newfile(context)
  if vim.w.lir_is_float then
    vim.api.nvim_feedkeys(':close | :edit ' .. context.dir, 'n', true)
  else
    vim.api.nvim_feedkeys(':edit ' .. context.dir, 'n', true)
  end
end

--- cd
function actions.cd(context)
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']],
                        context.dir))
  print('cd: ' .. context.dir)
end

--- reload
function actions.reload(_)
  vim.cmd([[edit]])
end

--- yank_path
function actions.yank_path(context)
  local path = context.dir .. context:current_value()
  vim.fn.setreg(vim.v.register, path)
  print('Yank path: ' .. path)
end

--- toggle_show_hidden
function actions.toggle_show_hidden()
  config.values.show_hidden_files = not (config.values.show_hidden_files)
  actions.reload()
end

return actions
