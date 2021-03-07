local utils = require 'lir.utils'

-----------------------------
-- Private
-----------------------------

---@alias lir_clipboard__kind 'copy'|'cut'

---@class lir_clipboard__data
local _clipboard = {
  ---@type lir_item[]
  files = {},
  ---@type lir_clipboard__kind
  kind = nil,
}


-----------------------------
-- Export
-----------------------------

---@class lir_clipboard
local M = {}


---@return lir_clipboard__data
M.get = function()
  return _clipboard
end


---@param files lir_item[]
---@param kind lir_clipboard__kind
M.set = function(files, kind)
  _clipboard = {files = files, kind = kind}
end


---@param kind lir_clipboard
---@param context lir_context
M.set_marked_items = function(kind, context)
  local marked_items = context:get_marked_items()
  if #marked_items == 0 then
    utils.error('Please mark one or more.')
    return
  end

  M.set(marked_items, kind)
end

return M
