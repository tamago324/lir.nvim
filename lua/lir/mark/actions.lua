local config = require 'lir.config'
local a = vim.api
local mark_utils = require 'lir.mark.utils'
local lir = require 'lir'

-----------------------------
-- Private
-----------------------------
local MARK_TEXT = '* '
local SPACES = '  '

---@return number
local get_start_col = function()
  return config.values.hide_cursor and 0 or 1
end

---@return number
local get_end_col = function()
  return get_start_col() + string.len(MARK_TEXT)
end

local clear_marks = function()
  for i = 1, a.nvim_buf_line_count(0) do
    a.nvim_buf_set_text(0, i - 1, get_start_col(), i - 1, get_end_col(), {''})
  end
end

---@param old_marked_items lir_item[]
local redraw_marks = function(old_marked_items)
  a.nvim_buf_set_option(0, 'modifiable', true)

  if #old_marked_items > 0 then
    clear_marks()
  end

  ---@type lir_item[]
  local context = lir.get_context()
  if #context:get_marked_items() > 0 then
    local col = get_start_col()
    for i = 1, #context.files do
      local text = context.files[i].marked and MARK_TEXT or SPACES
      a.nvim_buf_set_text(0, i - 1, col, i - 1, col, {text})
    end
  end

  a.nvim_buf_set_option(0, 'modifiable', false)
end

---@param func function
local update_redraw_marks = function(func)
  local save_marked_items = lir.get_context():get_marked_items()
  func()
  redraw_marks(save_marked_items)
end

-----------------------------
-- Export
-----------------------------

---@class lir_mark_actions
local M = {}

---@alias lir_mark_mode 'n'|'v'

---@param mode lir_mark_mode
M.mark = function(mode)
  update_redraw_marks(function()
    for _, f in ipairs(lir.get_context():current_items(mode)) do
      f.marked = true
    end
  end)
end

---@param mode lir_mark_mode
M.unmark = function(mode)
  update_redraw_marks(function()
    for _, f in ipairs(lir.get_context():current_items(mode)) do
      f.marked = false
    end
  end)
end

---@param mode lir_mark_mode
M.toggle_mark = function(mode)
  update_redraw_marks(function()
    for _, f in ipairs(lir.get_context():current_items(mode)) do
      f.marked = not f.marked
    end
  end)
end

return M
