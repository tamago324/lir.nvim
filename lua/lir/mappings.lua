--[[
From https://github.com/norcalli/nvim_utils
From telescope.nvim
]]
local api = vim.api
local lvim = require'lir.vim'

-----------------------------
-- Private
-----------------------------

-- { bufnr = { esc_key = function } }
local buf_keymap = buf_keymap or {}

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
    if not buf_keymap[bufnr] then
      buf_keymap[bufnr] = {}
      api.nvim_buf_attach(bufnr, false, {
        on_detach = function()
          buf_keymap[bufnr] = nil
        end,
      })
    end
    buf_keymap[bufnr][escaped] = rhs
    key_mapping =
        ([[:<C-u>lua require"lir.mappings".execute_keymap(%d, "%s")<CR>]]):format(bufnr, escaped)
    api.nvim_buf_set_keymap(bufnr, 'n', lhs, key_mapping, options)
  end
end

function mappings.execute_keymap(bufnr, escaped)
  local func = buf_keymap[bufnr][escaped]
  func(lvim.get_context())
end

return mappings
