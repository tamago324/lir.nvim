local lir = {}


local Buffer = require'lir.buffer'
local Devicons = require'lir.devicons'
local History = require'lir.history'
local Utils = require'lir.utils'
local vim = vim

local uv = vim.loop


local readdir = function(path)
  local files = {}
  local handle = uv.fs_scandir(path)
  if handle == nil then
    return {}
  end

  while true do
    local name, typ = uv.fs_scandir_next(handle)
    if name == nil then
      break
    end
    local is_dir = false
    if typ == 'directory' or typ == 'link' or typ == 'linked' then
      is_dir = true
    end

    local icon, highlight_name = Devicons.get_devicons(name, is_dir)
    icon = (icon and icon ~= '' and icon .. ' ' or '')

    table.insert(files, {
      value = name,
      display = ' ' .. icon .. name .. (is_dir and '/' or ''),
      devicons = {
        icon = icon,
        highlight_name = highlight_name,
      },
      is_dir = is_dir,
    })
  end
  return files
end


local sort = function(lhs, rhs)
  local l_val, r_val = lhs.value, rhs.value
  if lhs.is_dir and not rhs.is_dir then
    -- lhs がディレクトリなら そのまま
    return true
  elseif not lhs.is_dir and rhs.is_dir then
    -- rhs がディレクトリなら入れ替える
    return false
  end

  -- 単純に比較
  return lhs.value < rhs.value
end


--[[
  https://luarocks.org/modules/steved/microlight
  https://github.com/EvandroLG/array.lua
]]
-- slice っぽいのを返す
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


--- sub
local function tbl_sub(t, i1, i2)
  i2 = upper(t, i2)
  local res = {}
  -- ぐるぐるして集める
  for i = i1, i2 do
    table.insert(res, t[i])
  end
  return res
end


--[[
  カーソルを良い感じに調整しつつ、行をセットする
]]
local function setlines(dir, lines)
  local lnum = 1
  if History.exists(dir) then
    lnum = Buffer.indexof(History.get(dir))
  end

  -- 前が lir ではない場合、代替ファイルの位置にカーソルを移動する
  if not vim.w.lir_before_lir_buffer then
    local alt_file = vim.fn.fnamemodify(vim.fn.expand('#'), ':p:t')
    if alt_file then
      local alt_dir = vim.fn.fnamemodify(vim.fn.expand('#'), ':p:h')
      if string.gsub(dir, '/$', '') == alt_dir then
        lnum = Buffer.indexof(alt_file)
      end
    end
  end

  if lnum == nil or lnum == 1 then
    vim.api.nvim_buf_set_lines(0, 0, -1, true, lines)
    return
  end

  local before, after = tbl_sub(lines, 1, lnum - 1), tbl_sub(lines, lnum)
  -- カーソルの上の行にペーストし、カーソルを下にもってく
  vim.api.nvim_put(before, 'l', false, true)
  -- 置き換える
  vim.api.nvim_buf_set_lines(0, lnum-1, -1, true, after)
end


lir.init = function ()
  local path = vim.fn.resolve(vim.fn.expand('%:p'))

  local stat = uv.fs_stat(path)
  if path == '' or not stat or stat.type ~= 'directory' then
    return
  end

  -- 代替バッファを保持
  local alt_file_path = vim.fn.expand('#:p')
  if alt_file_path ~= '' then
    vim.w.alf_file = alt_file_path
  end

  local dir = path
  if not vim.endswith(path, '/') then
    dir = path .. '/'
  end

  vim.b.lir_dir = dir

  -- nvim_buf_set_lines() するため
  vim.bo.modifiable = true

  vim.bo.buftype   = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.buflisted = false
  vim.bo.swapfile  = false

  vim.cmd([[setlocal nowrap]])

  local files = readdir(path)
  table.sort(files, sort)
  if not vim.b.lir_show_hidden then
    files = vim.tbl_filter(function (val)
      return string.match(val.value, '^[^.]') ~= nil
    end, files)
  end

  vim.b.lir_files = files
  setlines(dir, vim.tbl_map(function(item)
    return item.display
  end, files))

  vim.bo.modified = false
  vim.bo.modifiable = false

  Devicons.update_highlights(files)

  if #files == 0 then
    Utils.set_nocontent_text()
  end

  vim.cmd([[setlocal cursorline]])

  vim.bo.filetype  = 'lir'
end


return lir
