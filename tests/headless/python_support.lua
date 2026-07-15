local function assert_equal(actual, expected, label)
  assert(vim.deep_equal(actual, expected), string.format(
    "%s: expected %s, got %s",
    label,
    vim.inspect(expected),
    vim.inspect(actual)
  ))
end

local function run()
  assert(vim.lsp.config.clangd, "clangd config must remain registered")

  local config = vim.lsp.config.basedpyright
  assert(config, "basedpyright config must be registered")
  assert_equal(config.cmd, { "basedpyright-langserver", "--stdio" }, "basedpyright cmd")
  assert_equal(config.filetypes, { "python" }, "basedpyright filetypes")

  local analysis = config.settings.basedpyright.analysis
  assert_equal(analysis.diagnosticMode, "openFilesOnly", "diagnostic mode")
  assert_equal(analysis.typeCheckingMode, "basic", "type checking mode")

  local disabled_diagnostics = {
    "reportMissingTypeStubs",
    "reportUnusedCallResult",
    "reportUnusedImport",
    "reportUnusedVariable",
    "reportUnknownArgumentType",
    "reportUnknownLambdaType",
    "reportUnknownMemberType",
    "reportUnknownParameterType",
    "reportUnknownVariableType",
  }

  for _, name in ipairs(disabled_diagnostics) do
    assert_equal(analysis.diagnosticSeverityOverrides[name], "none", name)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(bufnr, vim.fn.tempname() .. ".py")
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.cmd("setfiletype python")

  vim.wait(1000, function()
    return vim.bo[bufnr].filetype == "python"
  end, 10)

  assert_equal(vim.bo[bufnr].tabstop, 4, "python tabstop")
  assert_equal(vim.bo[bufnr].softtabstop, 4, "python softtabstop")
  assert_equal(vim.bo[bufnr].shiftwidth, 4, "python shiftwidth")
  assert_equal(vim.bo[bufnr].expandtab, true, "python expandtab")
  assert_equal(vim.bo[bufnr].commentstring, "# %s", "python commentstring")
  assert_equal(vim.wo.foldmarker, "#oisnip_begin,#oisnip_end", "python foldmarker")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_support: ok")
