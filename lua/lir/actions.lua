local history = require("lir.history")
local utils = require("lir.utils")
local config = require("lir.config")
local lvim = require("lir.vim")
local Path = require("plenary.path")

local sep = Path.path.sep

local fn = vim.fn
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
---@param quit_lir boolean | nil
local function open(cmd, quit_lir)
  local ctx = get_context()
  if not ctx:current_value() then
    return
  end
  local filename = vim.fn.fnameescape(ctx.dir .. ctx:current_value())
  if quit_lir ~= false then
    actions.quit()
  end
  vim.cmd(cmd .. " " .. filename)
  history.add(ctx.dir, ctx:current_value())
end

---@param pathname string
---@return boolean
local function is_root(pathname)
  if sep == "\\" then
    return string.match(pathname, "^[A-Z]:\\?$")
  end
  return pathname == "/"
end

-----------------------------
-- Export
-----------------------------

--- edit
---@param opts table
function actions.edit(opts)
  opts = opts or {}
  local modified_split_command = vim.F.if_nil(opts.modified_split_command, "split")

  local ctx = get_context()
  local dir, file = ctx.dir, ctx:current_value()
  if not file then
    return
  end

  local keepalt = (utils.win_get_var("lir_is_float") and "") or "keepalt"

  if utils.win_get_var("lir_is_float") and not ctx:is_dir_current() then
    -- 閉じてから開く
    actions.quit()
  end

  local cmd = (vim.api.nvim_buf_get_option(0, "modified") and modified_split_command) or "edit"

  vim.cmd(string.format("%s %s %s", keepalt, cmd, vim.fn.fnameescape(dir .. file)))
  history.add(dir, file)
end

--- split
---@param quit_lir boolean | nil
function actions.split(quit_lir)
  open("new", quit_lir)
end

--- vsplit
---@param quit_lir boolean | nil
function actions.vsplit(quit_lir)
  open("vnew", quit_lir)
end

--- tabedit
---@param quit_lir boolean | nil
function actions.tabedit(quit_lir)
  open("tabedit", quit_lir)
end

--- up
function actions.up()
  local cur_file, path, name, dir
  local ctx = get_context()
  cur_file = ctx:current_value()
  path = string.gsub(ctx.dir, sep .. "$", "")
  name = vim.fn.fnamemodify(path, ":t")
  if name == "" then
    return
  end
  dir = vim.fn.fnamemodify(path, ":p:h:h")
  history.add(path, cur_file)
  history.add(dir, name)
  vim.cmd("keepalt edit " .. dir)
  if is_root(dir) then
    vim.cmd("doautocmd BufEnter")
  end
end

--- quit
function actions.quit()
  if utils.win_get_var("lir_is_float") then
    a.nvim_win_close(0, true)
  else
    if utils.win_get_var("lir_file_quit_on_edit") ~= nil then
      vim.cmd("edit " .. utils.win_get_var("lir_file_quit_on_edit"))
    end
  end
end

--- mkdir
function actions.mkdir()
  vim.ui.input({ prompt = "Create directory: " }, function(name)
    if name == nil then
      return
    end

    if name == "." or name == ".." then
      utils.error("Invalid directory name: " .. name)
      return
    end

    local ctx = get_context()
    local path = Path:new(ctx.dir .. name)
    if path:exists() then
      utils.error("Directory already exists")
      -- cursor jump
      local lnum = ctx:indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
      return
    end

    path:mkdir({ parents = true })

    actions.reload()

    vim.schedule(function()
      local lnum = lvim.get_context():indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
    end)
  end)
end

--- touch
function actions.touch()
  vim.ui.input({ prompt = "Create file: " }, function(name)
    if name == nil then
      return
    end

    if name == "." or name == ".." then
      utils.error("Invalid file name: " .. name)
      return
    end

    local ctx = get_context()
    local path = Path:new(ctx.dir .. name)
    if path:exists() then
      utils.error("File already exists")
      -- cursor jump
      local lnum = ctx:indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
      return
    end

    path:touch()

    actions.reload()

    vim.schedule(function()
      local lnum = lvim.get_context():indexof(name)
      if lnum then
        vim.cmd(tostring(lnum))
      end
    end)
  end)
end

--- rename
function actions.rename(use_default)
  local ctx = get_context()
  local old = string.gsub(ctx:current_value(), sep .. "$", "")
  local default = ""
  if use_default ~= false then
    default = old
  end

  local opts = {
    completion = "dir",
    prompt = "Rename: ",
    default = default,
  }

  -- cd to the currently focused dir to get completion from the current directory
  local old_dir = fn.getcwd()

  vim.cmd("noau :cd " .. ctx.dir)

  vim.ui.input(opts, function(new)
    if new == nil or new == old then
      vim.cmd("noau :cd " .. old_dir)
      return
    end

    -- Restore working directory
    vim.cmd("noau :cd " .. old_dir)

    -- If target is a directory, move the file into the directory.
    -- Makes it work like linux `mv`
    local stat = uv.fs_stat(new)
    if stat and stat.type == "directory" then
      new = string.format("%s/%s", new, old)
    end

    if not uv.fs_rename(ctx.dir .. old, ctx.dir .. new) then
      utils.error("Rename failed")
    end

    actions.reload()
  end)
end

--- delete
function actions.delete(force)
  local ctx = get_context()
  local name = ctx:current_value()

  if not force and vim.fn.confirm("Delete?: " .. name, "&Yes\n&No", 1) ~= 1 then
    -- Esc は 0 を返す
    return
  end

  local path = Path:new(ctx.dir .. name)
  if path:is_dir() then
    path:rm({ recursive = true })
  else
    if not uv.fs_unlink(path:absolute()) then
      utils.error("Delete file failed")
      return
    end
  end

  actions.reload()
end

--- wipeout
function actions.wipeout()
  local ctx = get_context()
  if not ctx:is_dir_current() then
    local name = ctx:current().fullpath
    local bufnr = vim.fn.bufnr(name)
    if vim.fn.confirm("Delete?: " .. name, "&Yes\n&No", 1) ~= 1 then
      return
    end
    if bufnr ~= -1 then
      a.nvim_buf_delete(bufnr, { force = true })
    end
    actions.delete(true)
  else
    actions.delete()
  end
end

--- newfile
function actions.newfile()
  local ctx = get_context()
  if utils.win_get_var("lir_is_float") then
    a.nvim_feedkeys(":close | :edit " .. ctx.dir, "n", true)
  else
    a.nvim_feedkeys(":keepalt edit " .. ctx.dir, "n", true)
  end
end

--- cd
function actions.cd()
  local ctx = get_context()
  vim.cmd(string.format([[silent execute (haslocaldir() ? 'lcd' : 'cd') '%s']], ctx.dir))
  print("cd: " .. ctx.dir)
end

--- reload
function actions.reload(_)
  vim.cmd([[edit]])
end

--- yank_path
function actions.yank_path()
  local ctx = get_context()
  local path = ctx.dir .. ctx:current_value()
  path = string.gsub(path, ' ', '\\ ')
  vim.fn.setreg(vim.v.register, path)
  print("Yank path: " .. path)
end

--- toggle_show_hidden
function actions.toggle_show_hidden()
  config.values.show_hidden_files = not config.values.show_hidden_files
  actions.reload()
end

return actions
