-----------------------------
-- Private
-----------------------------
local _histories = {}

local normalize = function(dir)
  return string.gsub(dir, '/$', '')
end


-----------------------------
-- Export
-----------------------------

---@class lir_history
local history = {}

---@param dir string
---@param file string
history.add = function(dir, file)
  _histories[normalize(dir)] = file
end


---@param dir string
---@return string
history.get = function(dir)
  return _histories[normalize(dir)]
end


---@param dir string
---@return boolean
history.exists = function(dir)
  return _histories[normalize(dir)] ~= nil
end

---@return string[]
history.get_all = function()
  return _histories
end

return history
