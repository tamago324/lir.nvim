local history = require 'lir.history'
local utils = require 'lir.utils'
local config = require 'lir.config'
local lvim = require 'lir.vim'
local Path = require 'plenary.path'

local vim = vim
local uv = vim.loop
local a = vim.api

---@class lir_actions
local actions = {}

-----------------------------
-- Private
-----------------------------
local get_context = lvim.get_context

---@param cmd string
local function open(cmd)
  local ctx = get_context()
  if not ctx:current_value() then
    return
  end
  local filename = vim.fn.fnameescape(ctx.dir .. ctx:current_value())
  actions.quit()
  vim.cmd(cmd .. ' ' .. filename)
  history.add(ctx.dir, ctx:current_value())
end

-----------------------------
-- Export
-----------------------------

--- edit
function actions.edit()
  local ctx = get_context()
  local dir, file = ctx.dir, ctx:current_value()
  if not file then
    return
  end

  local keepalt = (vim.w.lir_is_float and '') or 'keepalt'

  if vim.w.lir_is_float and not ctx:is_dir_current() then
    -- 閉じてから開く
    actions.quit()
  end

  local cmd = (vim.api.nvim_buf_get_option(0, 'modified') and 'split') or 'edit'

  vim.cmd(string.format('%s %s %s', keepalt, cmd, vim.fn.fnameescape(dir .. file)))
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
  local ctx = get_context()
  cur_file = ctx:current_value()
  path = string.gsub(ctx.dir, '/$', '')
  name = vim.fn.fnamemodify(path, ':t')
  if name == '' then
    return
  end
  dir = vim.fn.fnamemodify(path, ':p:h:h')
  history.add(path, cur_file)
  history.add(dir, name)
  vim.cmd('keepalt edit ' .. dir)
  if vim.endswith(dir, '/') then
    vim.cmd('doautocmd BufEnter')
  end
end

--- quit
function actions.quit()
  if vim.w.lir_is_float then
    a.nvim_win_close(0, true)
  else
    if vim.w.lir_file_quit_on_edit ~= nil then
      vim.cmd('edit ' .. vim.w.lir_file_quit_on_edit)
    end
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

  local ctx = get_context()
  local path = Path:new(ctx.dir .. name)
  if path:exists() then
    utils.error('Directory already exists')
    -- cursor jump
    local lnum = ctx:indexof(name)
    if lnum then
      vim.cmd(tostring(lnum))
    end
    return
  end

  path:mkdir()

  actions.reload()

  vim.schedule(function()
    local lnum = lvim.get_context():indexof(name)
    if lnum then
      vim.cmd(tostring(lnum))
    end
  end)
end

--- rename
function actions.rename()
  local ctx = get_context()
  local old = string.gsub(ctx:current_value(), '/$', '')
  local new = vim.fn.input('Rename: ', old)
  if new == '' or new == old then
    return
  end

  if new == '.' or new == '..' or string.match(new, '[/\\]') then
    utils.error('Invalid name: ' .. new)
    return
  end

  if not uv.fs_rename(ctx.dir .. old, ctx.dir .. new) then
    utils.error('Rename failed')
  end

  actions.reload()
end

--- delete
function actions.delete()
  local ctx = get_context()
  local name = ctx:current_value()

  if vim.fn.confirm('Delete?: ' .. name, '&Yes\n&No', 1) ~= 1 then
    -- Esc は 0 を返す
    return
  end

  local path = Path:new(ctx.dir .. name)
  if path:is_dir() then
    path:rm({recursive = true})
  else
    if not uv.fs_unlink(path:absolute()) then
      utils.error('Delete file failed')
      return
    end
  end

  actions.reload()
end

--- newfile
function actions.newfile()
  local ctx = get_context()
  if vim.w.lir_is_float then
    a.nvim_feedkeys(':close | :edit ' .. ctx.dir, 'n', true)
  else
    a.nvim_feedkeys(':keepalt edit ' .. ctx.dir, 'n', true)
  end
end

--- cd
function actions.cd()
  local ctx = get_context()
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']],
                        ctx.dir))
  print('cd: ' .. ctx.dir)
end

--- reload
function actions.reload(_)
  vim.cmd([[edit]])
end

--- yank_path
function actions.yank_path()
  local ctx = get_context()
  local path = ctx.dir .. ctx:current_value()
  vim.fn.setreg(vim.v.register, path)
  print('Yank path: ' .. path)
end

--- toggle_show_hidden
function actions.toggle_show_hidden()
  config.values.show_hidden_files = not (config.values.show_hidden_files)
  actions.reload()
end

return actions
