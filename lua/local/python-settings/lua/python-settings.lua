local M = {}

function M.setup()
  vim.bo.tabstop = 4
  vim.bo.softtabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.expandtab = true
  vim.bo.commentstring = "# %s"

  vim.opt_local.foldmarker = { "#oisnip_begin", "#oisnip_end" }
end

return M
