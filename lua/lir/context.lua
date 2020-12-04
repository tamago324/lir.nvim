-----------------------------
-- Export
-----------------------------
local Context = {}


--- Context.new
function Context.new(dir)
  local self = setmetatable({}, { __index = Context })
  self.dir = dir
  self.files = nil
  return self
end

--- Context:current
function Context:current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.value
  end
  return nil
end


--- Context:indexof
-- from microlight
function Context:indexof(value)
  for i = 1, #self.files do
    local v = self.files[i]
    if v.value == value then
      return i
    end
  end
end

--- Context:is_dir_current
function Context:is_dir_current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.is_dir
  end
  return nil
end


return Context
