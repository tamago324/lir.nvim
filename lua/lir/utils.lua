-- local a = vim.api

-----------------------------
-- Export
-----------------------------

-- @class lir_utils
local utils = {}

-- @param msg string
function utils.error(msg)
  vim.cmd([[redraw]])
  vim.cmd([[echohl Error]])
  vim.cmd(string.format([[echomsg '%s']], msg))
  vim.cmd([[echohl None]])
end

return utils
