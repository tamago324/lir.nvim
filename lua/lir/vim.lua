-----------------------------
-- Private
-----------------------------
local lir_vim = {}

-- @param bufnr number
-- @return table<number, table>
local function get_or_empty(bufnr)
  if not lir_vim[bufnr] then
    lir_vim[bufnr] = {}
  end
  return lir_vim[bufnr]
end

-----------------------------
-- Export
-----------------------------

-- @class lir_vim
local Vim = setmetatable({}, {
  __index = function(_, key)
    local bufnr
    if type(key) == 'number' then
      -- lvim[12]
      bufnr = key
      return get_or_empty(bufnr)
    else
      -- lvim.dir
      bufnr = vim.fn.bufnr()
      return get_or_empty(bufnr)[key]
    end

  end,
})

-- @param bufnr? number
-- @return lir_context
function Vim.get_context(bufnr)
  bufnr = bufnr or vim.fn.bufnr()
  return get_or_empty(bufnr).context
end

-- @param context lir_context
-- @param bufnr? number
function Vim.set_context(context, bufnr)
  bufnr = bufnr or vim.fn.bufnr()
  get_or_empty(bufnr).context = context
end

function Vim.print()
  print(vim.inspect(lir_vim))
end

return Vim
