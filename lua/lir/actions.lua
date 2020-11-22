local actions = {}
local Buffer = require 'lir.buffer'
local History = require 'lir.history'
local Utils = require 'lir.utils'
local vim = vim
local uv = vim.loop


local fnameescape = vim.fn.fnameescape

local current_path = function ()
  return fnameescape(Buffer.curdir() .. Buffer.current())
end

actions.edit = function ()
  -- 代替フ ァイルを変更しないで開く (<C-^)
  vim.cmd('keepalt edit ' .. current_path())
end


actions.split = function ()
  local filename = current_path()
  actions.quit()
  vim.cmd('new ' .. filename)
end


actions.vsplit = function ()
  local filename = current_path()
  actions.quit()
  vim.cmd('vnew ' .. filename)
end


actions.tabopen = function ()
  local filename = current_path()
  actions.quit()
  vim.cmd('tabe ' .. filename)
end


actions.up = function ()
  local cur_file, path, name, dir

  cur_file = Buffer.current()
  path = string.gsub(vim.b.lir_dir, '/$', '')
  name = vim.fn.fnamemodify(path, ':t')
  if name == '' then
    return
  end
  dir = vim.fn.fnamemodify(path, ':p:h:h')
  vim.cmd('keepalt edit ' .. dir)
  Buffer.set_cursor(Buffer.indexof(name))

  History.add(path, cur_file)
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
    Utils.error('Invalid directory name: ' .. name)
    return
  end

  if vim.fn.mkdir(Buffer.curdir() .. name) == 0 then
    Utils.error('Create directory failed')
    return
  end

  actions.reload()
  vim.fn.search(string.format([[\v^%s]], name .. '/'), 'c')
end


actions.rename = function ()
  local old = string.gsub(Buffer.current(), '/$', '')
  local new = vim.fn.input('Rename: ', old)
  if new == '' or new == old then
    return
  end

  if new == '.' or new == '..' or string.match(new, '[/\\]') then
    Utils.error('Invalid name: ' .. new)
    return
  end

  if not uv.fs_rename(Buffer.curdir() .. old, Buffer.curdir() .. new) then
    Utils.error('Rename failed')
  end

  actions.reload()
end


actions.delete = function ()
  local name = Buffer.current()

  if vim.fn.confirm('Delete?: ' .. name, '&Yes\n&No\n&Force', 2) == 2 then
    return
  end

  local path = Buffer.curdir() .. name
  if vim.fn.isdirectory(path) == 1 then
    if not uv.fs_rmdir(path) then
      Utils.error('Delete directory failed')
      return
    end
  else
    if not uv.fs_unlink(path) then
      Utils.error('Delete file failed')
      return
    end
  end

  actions.reload()
end


actions.newfile = function()
  vim.api.nvim_feedkeys(':edit ' .. Buffer.curdir(), 'n', true)
end


actions.cd = function ()
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']], Buffer.curdir()))
  print('cd: ' .. Buffer.curdir())
end


actions.reload = function ()
  vim.cmd([[edit]])
end


actions.yank_path = function ()
  local path = Buffer.curdir() .. Buffer.current()
  vim.fn.setreg(vim.v.register, path)
  print('Yank path: ' .. path)
end


actions.toggle_show_hidden = function ()
  vim.b.lir_show_hidden = not (vim.b.lir_show_hidden or false)
  actions.reload()
end


return actions
