local lir = require 'lir'
local config = require 'lir.config'
local a = vim.api


-----------------------------
-- Private
-----------------------------
local MARK_TEXT = '* '
local SPACES = '  '

local function clear_marks()
  local col = config.values.hide_cursor and 0 or 1
  local end_col = col + string.len(MARK_TEXT)

  for i = 1, a.nvim_buf_line_count(0) do
    a.nvim_buf_set_text(0, i-1, col, i-1, end_col, {''})
  end
end

local function exec_in_modifiable(func)

  a.nvim_buf_set_option(0, 'modifiable', true)
  local result = func()
  a.nvim_buf_set_option(0, 'modifiable', false)

  return result
end

-----------------------------
-- Export
-----------------------------
local M = {}


M.mark = function (context)
  return exec_in_modifiable(function()
    if #context:marked_items() > 0 then
      -- 一旦リセット
      clear_marks()
    end

    context:current().marked = true

    for i = 1, #context.files do
      local col = config.values.hide_cursor and 0 or 1
      local text = context.files[i].marked and MARK_TEXT or SPACES
      a.nvim_buf_set_text(0, i-1, col, i-1, col, {text})
    end
  end)
end


M.unmark = function (context)
  if #context:marked_items() == 0 then
    return
  end

  return exec_in_modifiable(function()
    context:current().marked = false

    if #context:marked_items() == 0 then
      clear_marks()
      return
    end

    local col = config.values.hide_cursor and 0 or 1
    local end_col = col + string.len(MARK_TEXT)

    for i = 1, #context.files do
      local text = context.files[i].marked and MARK_TEXT or SPACES
      a.nvim_buf_set_text(0, i-1, col, i-1, end_col, {text})
    end
  end)
end


M.toggle_mark = function(context)
  if context:current().marked then
    M.unmark(context)
  else
    M.mark(context)
  end
end


return M
