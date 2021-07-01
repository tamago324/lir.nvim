local M = {}

--- Return a table with highlighted borderchars.
---   { {'=', highlight }, {'|', highlight}, ... }
---@param borderchars table
---@param highlight string
---@return table
M.make_border_opts = function(borderchars, highlight)
  return vim.tbl_map(function(char)
    return { char, highlight }
  end, borderchars)
end

return M
