local history = {}
local histories = {}

local normalize = function(dir)
  return string.gsub(dir, '/$', '')
end

history.add = function(dir, file)
  histories[normalize(dir)] = file
end

history.get = function(dir)
  return histories[normalize(dir)]
end

history.exists = function(dir)
  return histories[normalize(dir)] ~= nil
end

history.get_all = function()
  return histories
end

return history
