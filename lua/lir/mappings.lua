--[[
From https://github.com/norcalli/nvim_utils
]] local api = vim.api

-----------------------------
-- Global
-----------------------------
_LirBufKeymap = _LirBufKeymap or {}

-----------------------------
-- Private
-----------------------------
--- escape_keymap
local function escape_keymap(key)
  -- Prepend with a letter so it can be used as a dictionary key
  return 'k' .. key:gsub('.', string.byte)
end

-----------------------------
-- Export
-----------------------------
local mappings = {}

function mappings.apply_mappings(mappings)
  local bufnr = api.nvim_get_current_buf()
  local options = {}
  options.noremap = true
  options.silent = true

  for lhs, rhs in pairs(mappings) do
    local escaped = escape_keymap(lhs)
    local key_mapping
    -- cleanup
    if not _LirBufKeymap[bufnr] then
      _LirBufKeymap[bufnr] = {}
      api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
          _LirBufKeymap[bufnr] = nil
        end,
      })
    end
    _LirBufKeymap[bufnr][escaped] = rhs
    key_mapping =
        (':<C-u>lua _LirBufKeymap[%d].%s()<CR>'):format(bufnr, escaped)
    api.nvim_buf_set_keymap(bufnr, 'n', lhs, key_mapping, options)
  end
end

return mappings
