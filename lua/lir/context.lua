-----------------------------
-- Export
-----------------------------

---@class lir_context
---@field dir   string
---@field files lir_item[]
local Context = {}


---@class lir_item
---@field value string
---@field is_dir boolean
---@field fullpath string
---@field display string
---@field devicons table
---@field marked boolean


---@param dir string
---@return lir_context
function Context.new(dir)
  local self = setmetatable({}, {__index = Context})
  self.dir = dir
  self.files = nil
  return self
end

---@return lir_item|nil
function Context:current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file
  end
  return nil
end


---@param mode? 'n'|'v'
---@return lir_item[]
function Context:current_items(mode)
  local s, e
  if mode == 'v' then
    s, e = vim.fn.line("'<"), vim.fn.line("'>")
  else
    s, e = vim.fn.line('.'), vim.fn.line('.')
  end

  local results = {}
  for i = s, e do
    table.insert(results, self.files[i])
  end
  return results
end

---@return string
function Context:current_value()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.value
  end
  return nil
end

---@param value string
---@return number
function Context:indexof(value)
  for i = 1, #self.files do
    local v = self.files[i]
    if v.value == value then
      return i
    end
  end
end

---@return boolean
function Context:is_dir_current()
  local file = self.files[vim.fn.line('.')]
  if file then
    return file.is_dir
  end
  return false
end


---@return lir_item[]
function Context:get_marked_items()
  local results = {}
  for _, f in ipairs(self.files) do
    if f.marked then
      table.insert(results, f)
    end
  end
  return results
end


return Context
