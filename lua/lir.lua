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
      Devicons = {
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
  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.tbl_map(function(item)
    return item.display
  end, files))

  vim.b.lir_files = files
  vim.bo.modified = false
  vim.bo.modifiable = false

  local lnum = 1
  if History.exists(dir) then
    lnum = Buffer.indexof(History.get(dir))
  end

  local alt_dir = vim.fn.fnamemodify(vim.fn.expand('#'), ':p:h')
  local alt_file = vim.fn.fnamemodify(vim.fn.expand('#'), ':p:t')

  if alt_file and string.gsub(dir, '/$', '') == alt_dir then
    lnum = Buffer.indexof(alt_file)
  end

  Buffer.set_cursor(lnum, 1)
  Devicons.update_highlights(files)

  if #files == 0 then
    Utils.set_nocontent_text()
  end

  vim.cmd([[setlocal cursorline]])

  vim.bo.filetype  = 'lir'
end


return lir
