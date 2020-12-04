local utils = {}

function utils.error(msg)
  vim.cmd([[redraw]])
  vim.cmd([[echohl Error]])
  vim.cmd(string.format([[echomsg '%s']], msg))
  vim.cmd([[echohl None]])
end

function utils.set_nocontent_text(devicon_enable)
  -- From vim-clap
  local text = string.format(' %s Directory is empty',
                             (devicon_enable and '' or ''))
  vim.api.nvim_buf_set_virtual_text(0, -1, 0, {{text, "BlueSign"}}, {})
end

return utils
