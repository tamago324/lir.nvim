local Path = require("plenary.path")

local lir = require("lir")
local clipboard = require("lir.clipboard")
local utils = require("lir.utils")
local actions = require("lir.actions")
local mark_utils = require("lir.mark.utils")

local uv = vim.loop

-----------------------------
-- Private
-----------------------------

---
---@param status any
---@vararg any
---@return any
local function ok_or_nil(status, ...)
  if not status then
    return
  end
  return ...
end

---@param fn function Function to run
---@vararg any Function arguments
---@return any Result of `fn(...)` if there are no errors, otherwise nil.
--- Returns nil if errors occur during {fn}, otherwise returns
local function npcall(fn, ...)
  return ok_or_nil(pcall(fn, ...))
end

local PASTE_ACTIONS = {
  SKIP = 1,
  RENAME = 2,
  FORCE = 3,
  QUIT = 4,

  CANCEL = 0,
}

---@return string name
function Path:name()
  return string.match(self:absolute(), "[^/]+$")
end

--- 指定のディレクトリを再帰的にコピー
---@param from string
---@param to string
local copy_dir_recurse
copy_dir_recurse = function(from, to)
  vim.validate({
    from = { from, "string", false },
    to = { to, "string", false },
  })

  local from_path = Path:new(from)
  local to_path = Path:new(to)

  -- まずは、ディレクトリ自体を作成する
  if not to_path:exists() then
    to_path:mkdir({
      mode = tonumber("744", 8),
      parents = true,
    })
  end

  -- ディレクトリ配下を再帰的にコピーする
  local handle = uv.fs_scandir(from)

  if handle == nil then
    return
  end

  while true do
    local name, _ = uv.fs_scandir_next(handle)
    if name == nil then
      break
    end

    local old_path = from_path:joinpath(name)
    local new_path = to_path:joinpath(name)
    if old_path:is_dir() then
      copy_dir_recurse(old_path:absolute(), new_path:absolute())
    else
      uv.fs_copyfile(old_path:absolute(), new_path:absolute())
    end
  end

  return true
end

local paste_funcs = {
  copy = function(from, to, is_error_if_exists)
    -- https://www.geeksforgeeks.org/node-js-fs-copyfile-function/
    -- https://github.com/luvit/luv/blob/429e7/docs.md#uvfs_copyfilepath-new_path-flags-callback
    if Path:new(from):is_dir() then
      return copy_dir_recurse(from, to)
    else
      return uv.fs_copyfile(from, to, {
        -- もし、ファイルが存在した場合、エラーにする
        excl = is_error_if_exists,
      })
    end
  end,
  cut = function(from, to)
    return uv.fs_rename(from, to)
  end,
}

---@param path string
---@param kind string
local function ask_action(path, kind)
  --- base idea coc-explorer
  -- (S)kip
  -- (R)ename
  -- (F)orce replace
  -- (Q)uit

  -- copy のときのみ、 force を出す
  local force_text = kind == "copy" and ", \n&Force replace" or ""

  vim.cmd("redraw!")
  local question = string.format("&Skip\n&Rename%s\n&Quit", force_text)
  local res = vim.fn.confirm(string.format("Paste: %s is already exists.", path), question)
  return res
end

---
---@param from string
---@param to string
---@param kind lir_clipboard__kind
---@return boolean
local function _paste(from, to, kind)
  local from_path, to_path = Path:new(from), Path:new(to)
  local is_error_if_exists = true

  if to_path:exists() then
    local res = ask_action(to_path:absolute(), kind)

    if res == PASTE_ACTIONS.CANCEL or res == PASTE_ACTIONS.QUIT then
      return true
    elseif res == PASTE_ACTIONS.SKIP then
      return false
    elseif res == PASTE_ACTIONS.RENAME then
      vim.cmd([[redraw!]])
      local prompt = string.format("Rename: %s -> ", to_path:absolute())
      vim.cmd([[noautocmd normal! :]])
      local new_path = npcall(vim.fn.input, prompt, to_path:absolute())
      if not (new_path and #new_path > 0) then
        return true
      end
      to_path = Path:new(new_path)
    elseif res == PASTE_ACTIONS.FORCE then
      is_error_if_exists = false
    end
  end

  if not paste_funcs[kind](from_path:absolute(), to_path:absolute(), is_error_if_exists) then
    utils.error("Paste failed")
    return true
  end

  return false
end

-----------------------------
-- Export
-----------------------------

---@class lir_clipboard_actions
local M = {}

M.copy = function()
  local context = lir.get_context()
  clipboard.set_marked_items("copy", context)
  mark_utils.change_mark_text("C", context)
end

M.cut = function()
  local context = lir.get_context()
  clipboard.set_marked_items("cut", context)
  mark_utils.change_mark_text("X", context)
end

M.paste = function()
  local context = lir.get_context()
  local files, kind = clipboard.get().files, clipboard.get().kind
  for _, f in ipairs(files) do
    local quit_or_cancel = _paste(f.fullpath, context.dir .. f.value, kind)
    if quit_or_cancel then
      break
    end
  end
  actions.reload(context)
end

M._print = function()
  print(vim.inspect(clipboard.get()))
end

return M
