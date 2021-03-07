local a = vim.api
local config = require 'lir.config'
local lir = require 'lir'

-----------------------------
-- Private
-----------------------------

-----------------------------
-- Export
-----------------------------

---@class lir_mark_utils
local M = {}

---@param func function
---@return any
M.exec_in_modifiable = function(func)

  a.nvim_buf_set_option(0, 'modifiable', true)
  local result = func()
  a.nvim_buf_set_option(0, 'modifiable', false)

  return result
end

---@param char string
---@param context lir_context
M.change_mark_text = function(char, context)
  assert(#char == 1)

  context = context or lir.get_context()
  M.exec_in_modifiable(function()
    local col = config.values.hide_cursor and 0 or 1
    for i, f in ipairs(context.files) do
      if f.marked then
        a.nvim_buf_set_text(0, i - 1, col, i - 1, col + 1, {char})
      end
    end
  end)
end

---@param context lir_context
---@return lir_item[]
M.get_marked_items = function(context)
  vim.api.nvim_echo({
    {"`lir.mark.get_marked_items()` is deprecated. Use require('lir').get_context():get_marked_items() instead", 'WarningMsg'}
  }, true, {})

  context = context or lir.get_context()
  local results = {}
  for _, f in ipairs(context.files) do
    if f.marked then
      table.insert(results, f)
    end
  end
  return results
end

return M
