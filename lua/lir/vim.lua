-----------------------------
-- Private
-----------------------------
local lir_vim = {}

local function get_or_empty(key)
  if not lir_vim[key] then
    lir_vim[key] = {}
  end
  return lir_vim[key]
end


-----------------------------
-- Export
-----------------------------
local Vim = {}
Vim.b = setmetatable({}, {
  __index = function(t, key)
    if type(key) == 'number' then
      -- lvim.b[12]
      return get_or_empty(key)
    else
      -- lvim.b.context
      return get_or_empty(vim.fn.bufnr())[key]
    end

  end
})
-- Vim.w = {}


return Vim
