-- local a = vim.api

-----------------------------
-- Export
-----------------------------
local utils = {}

function utils.error(msg)
  vim.cmd([[redraw]])
  vim.cmd([[echohl Error]])
  vim.cmd(string.format([[echomsg '%s']], msg))
  vim.cmd([[echohl None]])
end

return utils
