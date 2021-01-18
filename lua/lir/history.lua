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
local history = {}

history.add = function(dir, file)
  _histories[normalize(dir)] = file
end

history.get = function(dir)
  return _histories[normalize(dir)]
end

history.exists = function(dir)
  return _histories[normalize(dir)] ~= nil
end

history.get_all = function()
  return _histories
end

return history
