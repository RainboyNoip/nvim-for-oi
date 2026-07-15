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
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_support: ok")
