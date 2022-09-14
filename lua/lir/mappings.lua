--[[
From https://github.com/norcalli/nvim_utils
From telescope.nvim
]]
local a = vim.api

-----------------------------
-- Private
-----------------------------

-- { bufnr = { esc_key = function } }
local buf_keymap = {}

-----------------------------
-- Export
-----------------------------

---@class lir_mappings
local M = {}

---@param mappings table
function M.apply_mappings(mappings)
  if mappings == nil then
    return
  end
  local bufnr = a.nvim_get_current_buf()
  local options = {}

  for lhs, rhs in pairs(mappings) do
    vim.keymap.set("n", lhs, rhs, {
      buffer = bufnr,
      noremap = true,
      silent = true,
      nowait = true,
    })
  end
end

return M
