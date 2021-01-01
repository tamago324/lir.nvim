local history = require 'lir.history'
local utils = require 'lir.utils'
local Context = require 'lir.context'
local config = require 'lir.config'
local lvim = require 'lir.vim'

local vim = vim
local uv = vim.loop

local actions = {}

-----------------------------
-- Private
-----------------------------
local function open(cmd)
  if not lvim.get_context():current_value() then
    return
  end
  local filename = vim.fn.fnameescape(lvim.get_context().dir ..
                                          lvim.get_context():current_value())
  actions.quit()
  vim.cmd(cmd .. ' ' .. filename)
end

-----------------------------
-- Export
-----------------------------

--- edit
function actions.edit()
  local dir, file = lvim.get_context().dir, lvim.get_context():current_value()
  if not file then
    return
  end

  if vim.w.lir_is_float and not lvim.get_context():is_dir_current() then
    -- 閉じてから開く
    actions.quit()
  end

  vim.cmd('keepalt edit ' .. vim.fn.fnameescape(dir .. file))
  history.add(dir, file)
end

--- split
function actions.split()
  open('new')
end

--- vsplit
function actions.vsplit()
  open('vnew')
end

--- tabedit
function actions.tabedit()
  open('tabedit')
end

--- up
function actions.up()
  local cur_file, path, name, dir

  cur_file = lvim.get_context():current_value()
  path = string.gsub(lvim.get_context().dir, '/$', '')
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
function actions.mkdir()
  local name = vim.fn.input('Create directory: ')
  if name == '' then
    return
  end

  if name == '.' or name == '..' or string.match(name, '[/\\]') then
    utils.error('Invalid directory name: ' .. name)
    return
  end

  if vim.fn.mkdir(lvim.get_context().dir .. name) == 0 then
    utils.error('Create directory failed')
    return
  end

  actions.reload()
  vim.fn.search(string.format([[\v^%s]], name .. '/'), 'c')
end

--- rename
function actions.rename()
  local old = string.gsub(lvim.get_context():current_value(), '/$', '')
  local new = vim.fn.input('Rename: ', old)
  if new == '' or new == old then
    return
  end

  if new == '.' or new == '..' or string.match(new, '[/\\]') then
    utils.error('Invalid name: ' .. new)
    return
  end

  if not uv.fs_rename(lvim.get_context().dir .. old, lvim.get_context().dir .. new) then
    utils.error('Rename failed')
  end

  actions.reload()
end

--- delete
function actions.delete()
  local name = lvim.get_context():current_value()

  if vim.fn.confirm('Delete?: ' .. name, '&Yes\n&No\n&Force', 2) == 2 then
    return
  end

  local path = lvim.get_context().dir .. name
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
function actions.newfile()
  if vim.w.lir_is_float then
    vim.api.nvim_feedkeys(':close | :edit ' .. lvim.get_context().dir, 'n', true)
  else
    vim.api.nvim_feedkeys(':edit ' .. lvim.get_context().dir, 'n', true)
  end
end

--- cd
function actions.cd()
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']],
                        lvim.get_context().dir))
  print('cd: ' .. lvim.get_context().dir)
end

--- reload
function actions.reload()
  vim.cmd([[edit]])
end

--- yank_path
function actions.yank_path()
  local path = lvim.get_context().dir .. lvim.get_context():current_value()
  vim.fn.setreg(vim.v.register, path)
  print('Yank path: ' .. path)
end

--- toggle_show_hidden
function actions.toggle_show_hidden()
  config.values.show_hidden_files = not (config.values.show_hidden_files)
  actions.reload()
end

return actions
