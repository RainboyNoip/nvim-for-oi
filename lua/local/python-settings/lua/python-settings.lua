local M = {}
local did_setup = false

-- 用 ruff format 格式化当前 buffer。
-- Python 不能像 C++ 那样走 LSP 格式化：BasedPyright 不提供
-- textDocument/formatting（实测 capabilities 里没有），只能调外部工具。
--
-- 刻意只做手动触发（<leader>cf），不在保存前自动跑：ruff format 是 Black 语义，
-- 会把 if x: f() 这类一行复合语句拆成多行，自动跑会反复改掉 OI 的一行流写法。
local function format_python_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  if vim.fn.executable("ruff") ~= 1 then
    vim.notify(
      "格式化失败：未找到 ruff（可 sudo pacman -S ruff 或 pip install ruff）",
      vim.log.levels.ERROR,
      { title = "Python 格式化" }
    )
    return
  end

  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    name = "solution.py"
  end

  local ok, result = pcall(function()
    return vim.system({ "ruff", "format", "--stdin-filename", name, "-" }, { stdin = text }):wait()
  end)
  if not ok or result.code ~= 0 then
    local msg = ok and (result.stderr or "") or tostring(result)
    vim.notify("ruff format 失败：\n" .. (msg ~= "" and msg or "未知错误"), vim.log.levels.ERROR, { title = "Python 格式化" })
    return
  end

  local formatted = result.stdout
  if formatted == "" or formatted == text then
    return
  end

  -- 整段替换会丢光标位置，先存后还。
  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(formatted:gsub("\n$", ""), "\n"))
  vim.fn.winrestview(view)
end

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

  -- 与 C++ 侧同键位（buffer-local）：<leader>cf 手动格式化。
  vim.keymap.set("n", "<leader>cf", function()
    format_python_buffer(bufnr)
  end, {
    buffer = bufnr,
    silent = true,
    desc = "格式化 Python 代码",
  })
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
