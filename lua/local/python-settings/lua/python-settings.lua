local M = {}
local did_setup = false

local function apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "python" then
    return
  end

  for name, value in pairs({
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
    commentstring = "# %s",
  }) do
    vim.api.nvim_set_option_value(name, value, { buf = bufnr })
  end

  -- foldmarker 是 window-local；更新所有正在显示这个 Python buffer 的窗口。
  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_set_option_value("foldmarker", "#oisnip_begin,#oisnip_end", { win = winid })
  end
end

function M.setup()
  apply()

  if did_setup then
    return
  end
  did_setup = true

  local group = vim.api.nvim_create_augroup("RainboyPythonSettings", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "python",
    callback = function(args)
      apply(args.buf)
    end,
    desc = "为每个 Python buffer 应用本地设置",
  })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    pattern = "*.py",
    callback = function(args)
      apply(args.buf)
    end,
    desc = "切回 Python buffer 时恢复窗口折叠标记",
  })
end

return M
