local buffer = {}
local vim = vim


local get_value = function(lnum)
  return vim.b.lir_files[lnum].value
end


function buffer.current ()
  return get_value(vim.fn.line('.'))
end


function buffer.curdir()
  return vim.b.lir_dir
end


-- from microlight
function buffer.indexof(value)
  for i = 1, #vim.b.lir_files do
    local v = vim.b.lir_files[i]
    if v.value == value then
      return i
    end
  end
end


function buffer.set_cursor(lnum, col)
  -- XXX: なぜか、defer_fn が必要
  vim.defer_fn(function ()
    vim.fn.cursor(lnum, 1)
  end, 1)
end


return buffer
