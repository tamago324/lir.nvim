local config = require("lir.config")
local devicons = require("lir.devicons")

local a = vim.api

-----------------------------
-- Private
-----------------------------
local ns = a.nvim_create_namespace("lir_dir")

-----------------------------
-- Export
-----------------------------

---@class lir_highlight
local highlight = {}

---@param files lir_item[]
function highlight.update_highlight(files)
  if config.values.devicons.enable then
    devicons.update_highlight(files)
  end
  if not config.values.devicons.enable or config.values.devicons.highlight_dirname then
    a.nvim_buf_clear_namespace(0, ns, 0, -1)
    for i, file in ipairs(files) do
      if file.is_dir then
        a.nvim_buf_add_highlight(0, ns, "LirDir", i - 1, 0, -1)
      end
    end
  end
end

return highlight
