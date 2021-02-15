-----------------------------
-- Export
-----------------------------

-- @class lir_context
-- @field dir   string
-- @field files lir_item[]
local Context = {}


-- @class lir_item
-- @field value string
-- @field is_dir boolean
-- @field fullpath string
-- @field display string
-- @field devicons table


-- @param dir string
-- @return lir_context
function Context.new(dir)
  local self = setmetatable({}, {__index = Context})
  self.dir = dir
  self.files = nil
  return self
end

-- @return table
function Context:current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file
  end
  return nil
end

-- @return string
function Context:current_value()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.value
  end
  return nil
end

-- @param value string
-- @return number
function Context:indexof(value)
  for i = 1, #self.files do
    local v = self.files[i]
    if v.value == value then
      return i
    end
  end
end

-- @return boolean
function Context:is_dir_current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.is_dir
  end
  return false
end

return Context
