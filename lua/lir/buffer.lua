local buffer = {}
local vim = vim


local get_value = function(lnum)
  local file = vim.b.lir_files[lnum]
  if file then
    return file.value
  end
  return nil
end


function buffer.current()
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



function buffer.is_dir_current()
  local file = vim.b.lir_files[vim.fn.line('.')]
  if file then
    return file.is_dir
  end
  return nil
end

return buffer
