local actions = {}
local buffer = require 'lir.buffer'
local history = require 'lir.history'
local utils = require 'lir.utils'
local vim = vim
local uv = vim.loop


local esc_current = function ()
  local file = buffer.current()
  if file then
    return vim.fn.fnameescape(file)
  end
  return ''
end

actions.edit = function ()
  -- 代替フ ァイルを変更しないで開く (<C-^)
  vim.cmd('keepalt edit ' .. vim.b.lir_dir .. esc_current())
end


actions.split = function ()
  local filename = esc_current()
  actions.quit()
  vim.cmd('new ' .. filename)
end


actions.vsplit = function ()
  local filename = esc_current()
  actions.quit()
  vim.cmd('vnew ' .. filename)
end


actions.tabopen = function ()
  local filename = esc_current()
  actions.quit()
  vim.cmd('tabe ' .. filename)
end


actions.up = function ()
  local cur_file, path, name, dir

  cur_file = buffer.current()
  path = string.gsub(vim.b.lir_dir, '/$', '')
  name = vim.fn.fnamemodify(path, ':t')
  if name == '' then
    return
  end
  dir = vim.fn.fnamemodify(path, ':p:h:h')
  vim.cmd('keepalt edit ' .. dir)
  buffer.set_cursor(buffer.indexof(name))

  history.add(path, cur_file)
end


actions.quit = function ()
  vim.cmd('edit ' .. vim.w.alf_file)
end


actions.mkdir = function ()
  local name = vim.fn.input('Create directory: ')
  if name == '' then
    return
  end

  if name == '.' or name == '..' or string.match(name, '[/\\]') then
    utils.error('Invalid directory name: ' .. name)
    return
  end

  if vim.fn.mkdir(buffer.curdir() .. name) == 0 then
    utils.error('Create directory failed')
    return
  end

  actions.reload()
  vim.fn.search(string.format([[\v^%s]], name .. '/'), 'c')
end


actions.rename = function ()
  local old = string.gsub(buffer.current(), '/$', '')
  local new = vim.fn.input('Rename: ', old)
  if new == '' or new == old then
    return
  end

  if new == '.' or new == '..' or string.match(new, '[/\\]') then
    utils.error('Invalid name: ' .. new)
    return
  end

  if not uv.fs_rename(buffer.curdir() .. old, buffer.curdir() .. new) then
    utils.error('Rename failed')
  end

  actions.reload()
end


actions.delete = function ()
  local name = buffer.current()

  if vim.fn.confirm('Delete?: ' .. name, '&Yes\n&No\n&Force', 2) == 2 then
    return
  end

  local path = buffer.curdir() .. name
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


actions.newfile = function()
  vim.api.nvim_feedkeys(':edit ' .. buffer.curdir(), 'n', true)
end


actions.cd = function ()
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']], buffer.curdir()))
  print('cd: ' .. buffer.curdir())
end


actions.reload = function ()
  vim.cmd([[edit]])
end


actions.yank_path = function ()
  local path = buffer.curdir() .. buffer.current()
  vim.fn.setreg(vim.v.register, path)
  print('Yank path: ' .. path)
end


actions.toggle_show_hidden = function ()
  vim.b.lir_show_hidden = not (vim.b.lir_show_hidden or false)
  actions.reload()
end


return actions
