local lir = require 'lir'
local config = require 'lir.config'
local a = vim.api


-----------------------------
-- Private
-----------------------------
local MARK_TEXT = '*'
local SPACES = ' '

local function get_lnum_start_end()
  -- TODO: Support visual mode
  -- local mode = a.nvim_get_mode()
  --
  -- if mode == 'v' or mode == 'V' then
  --   -- clear visual mode
  --   local key = nvim_replace_termcodes('<Esc>', true, true, true)
  --   a.nvim_feedkeys(key, 'n', true)
  --   return {vim.fn.line("'<"), vim.fn.line("'>")}
  -- end

  local lnum = vim.fn.line('.')
  return {lnum, lnum}
end

local function clear_marks()
  local col = config.values.hide_cursor and 0 or 1
  local end_col = col + string.len(MARK_TEXT)

  for i = 1, a.nvim_buf_line_count(0) do
    a.nvim_buf_set_text(0, i-1, col, i-1, end_col, {''})
  end
end

-----------------------------
-- Export
-----------------------------
local M = {}


M.mark = function (context)
  a.nvim_buf_set_option(0, 'modifiable', true)
  local col = config.values.hide_cursor and 0 or 1

  if #context:marked_items() > 0 then
    -- 一旦リセット
    clear_marks()
  end

  local start_lnum, end_lnum = unpack(get_lnum_start_end())
  for i = 1, #context.files do
    if start_lnum <= i and i <= end_lnum then
      context.files[i].marked = true
    end

    local text = context.files[i].marked and MARK_TEXT or SPACES
    a.nvim_buf_set_text(0, i-1, col, i-1, col, {text})
  end

  a.nvim_buf_set_option(0, 'modifiable', false)
end


M.unmark = function (context)
  if #context:marked_items() == 0 then
    return
  end

  a.nvim_buf_set_option(0, 'modifiable', true)

  local col = config.values.hide_cursor and 0 or 1
  local end_col = col + string.len(MARK_TEXT)

  local start_lnum, end_lnum = unpack(get_lnum_start_end())
  for i = start_lnum, end_lnum do
    if context.files[i].marked then
      context.files[i].marked = false
    end
  end

  if #context:marked_items() == 0 then
    clear_marks()
  else
    for i = 1, #context.files do
      local text = context.files[i].marked and MARK_TEXT or SPACES
      a.nvim_buf_set_text(0, i-1, col, i-1, end_col, {text})
    end
  end

  a.nvim_buf_set_option(0, 'modifiable', false)
end


return M
