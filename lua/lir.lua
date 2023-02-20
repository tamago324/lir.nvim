local devicons = require("lir.devicons")
local history = require("lir.history")
local config = require("lir.config")
local mappings = require("lir.mappings")
local highlight = require("lir.highlight")
local smart_cursor = require("lir.smart_cursor")
local Context = require("lir.context")
local lvim = require("lir.vim")
local Path = require("plenary.path")
local utils = require("lir.utils")

local sep = Path.path.sep

local vim = vim
local uv = vim.loop
local a = vim.api

-----------------------------
-- Private
-----------------------------

---@param path string
---@return lir_item[]
local function readdir(path)
  local files = {}
  local handle = uv.fs_scandir(path)
  if handle == nil then
    return {}
  end

  while true do
    local name, _ = uv.fs_scandir_next(handle)
    if name == nil then
      break
    end
    local p = Path:new(path):joinpath(name)
    local is_dir = p:is_dir()
    ---@type lir_item
    local file = {
      value = name,
      is_dir = is_dir,
      fullpath = p:absolute(),
      display = nil,
      devicons = nil,
    }

    local prefix = config.values.hide_cursor and "" or " "

    if config.values.devicons.enable then
      local icon, highlight_name = devicons.get_devicons(name, is_dir)
      file.display = string.format("%s%s %s%s", prefix, icon, name, (is_dir and "/" or ""))
      file.devicons = { icon = icon, highlight_name = highlight_name }
    else
      file.display = prefix .. name .. (is_dir and "/" or "")
    end

    table.insert(files, file)
  end
  return files
end

---@param lhs lir_item
---@param rhs lir_item
local function sort(lhs, rhs)
  if lhs.is_dir and not rhs.is_dir then
    return true
  elseif not lhs.is_dir and rhs.is_dir then
    return false
  end
  return lhs.value < rhs.value
end

---  Return values like slice
---@param t table
---@param i2 number
---@return number
---@see https://luarocks.org/modules/steved/microlight, https://github.com/EvandroLG/array.lua
local function upper(t, i2)
  if not i2 or i2 > #t then
    return #t
  elseif i2 < 0 then
    -- 後ろから
    return #t + i2 + 1
  else
    return i2
  end
end

---@param t table
---@param i1 number
---@param i2 number
local function tbl_sub(t, i1, i2)
  i2 = upper(t, i2)
  local res = {}
  -- ぐるぐるして集める
  for i = i1, i2 do
    table.insert(res, t[i])
  end
  return res
end

--- Set the lines while adjusting the cursor to feel good
---@param dir string
---@param lines string[]
local function setlines(dir, lines)
  local lnum = 1
  if history.exists(dir) then
    lnum = lvim.get_context():indexof(history.get(dir))
  end

  -- 前が lir ではない場合
  if utils.win_get_var("lir_prev_filetype") ~= "lir" then
    -- ジャンプ対象のファイルが指定されていれば、そのファイルの位置にカーソルを移動する
    -- そうでなければ、代替ファイルの位置にカーソルを移動する
    local file = utils.win_get_var("lir_file_jump_cursor") or vim.fn.expand("#")
    file = vim.fn.fnamemodify(file, ":p:t")
    if file then
      local alt_dir = vim.fn.fnamemodify(vim.fn.expand("#"), ":p:h")
      if string.gsub(dir, sep .. "$", "") == alt_dir then
        lnum = lvim.get_context():indexof(file)
      end
    end
    a.nvim_win_set_var(0, "lir_file_jump_cursor", nil)
  end

  if lnum == nil or lnum == 1 then
    a.nvim_buf_set_lines(0, 0, -1, true, lines)
    -- move cursor
    vim.schedule(function()
      vim.cmd("normal! 0")
    end)
    return
  end

  local before, after = tbl_sub(lines, 1, lnum - 1), tbl_sub(lines, lnum)
  a.nvim_put(before, "l", false, true)
  a.nvim_buf_set_lines(0, lnum - 1, -1, true, after)
end

---@param path string
---@return boolean
local function is_symlink(path)
  -- If it is not accessible, it returns nil, so check it.
  local res, _ = uv.fs_lstat(path)
  if res then
    return uv.fs_lstat(path).type == "link"
  end
  return false
end

---@param dir string
---@param files lir_item[]
local function set_virtual_text_symlink(dir, files)
  for i, file in ipairs(files) do
    if is_symlink(dir .. file.value) then
      local text = "-> " .. uv.fs_readlink(dir .. file.value)
      a.nvim_buf_set_virtual_text(0, -1, i - 1, { { text, "LirSymLink" } }, {})
    end
  end
end

local function set_nocontent_text()
  -- From vim-clap
  local text = " Directory is empty"
  a.nvim_buf_set_virtual_text(0, -1, 0, { { text, "LirEmptyDirText" } }, {})
end

--- filter を適用する
--- 用途としては並び替えをしたり、要素を削除したりする
---@param files lir_item[]
---@return lir_item[]
local function do_filter(files)
  for _, filter in ipairs(config.values.get_filters()) do
    files = filter(files)
  end
  return files
end

-----------------------------
-- Export
-----------------------------

---@class lir
local lir = {}

function lir.init()
  local path = vim.fn.expand("%:p")

  if path == "" or not Path:new(path):is_dir() then
    return
  end

  local alt_f = vim.fn.expand("#:p")
  if alt_f ~= "" then
    vim.w.lir_file_quit_on_edit = alt_f
  end

  local dir = path
  if not vim.endswith(path, sep) then
    dir = path .. sep
  end

  local context = Context.new(dir)
  lvim.set_context(context)

  -- nvim_buf_set_lines() するため
  a.nvim_buf_set_option(0, "modifiable", true)

  a.nvim_buf_set_option(0, "buftype", "nofile")
  a.nvim_buf_set_option(0, "bufhidden", "wipe")
  a.nvim_buf_set_option(0, "buflisted", false)
  a.nvim_buf_set_option(0, "swapfile", false)

  smart_cursor.init()

  local files = readdir(path)
  if not config.values.show_hidden_files then
    files = vim.tbl_filter(function(val)
      return string.match(val.value, "^[^.]") ~= nil
    end, files)
  end

  files = vim.tbl_filter(function(val)
    return not vim.tbl_contains(config.values.ignore, val.value)
  end, files)

  table.sort(files, sort)

  local do_filter_status, filtered_files = pcall(do_filter, files)
  if do_filter_status then
    files = filtered_files
  end

  context.files = files
  setlines(
    dir,
    vim.tbl_map(function(item)
      return item.display
    end, files)
  )

  highlight.update_highlight(files)

  if #files == 0 then
    set_nocontent_text()
  end
  set_virtual_text_symlink(dir, files)

  vim.cmd([[setlocal nowrap]])
  vim.cmd([[setlocal cursorline]])

  mappings.apply_mappings(config.values.mappings)

  a.nvim_buf_set_option(0, "modified", false)
  a.nvim_buf_set_option(0, "modifiable", false)
  a.nvim_buf_set_option(0, "filetype", "lir")

  config.values.on_init(context)
end

---@param prefs lir.config.values
function lir.setup(prefs)
  -- Set preferences
  config.set_default_values(prefs)

  -- devicons
  if config.values.devicons.enable then
    devicons.setup()
  end
end

lir.get_context = lvim.get_context

return lir
