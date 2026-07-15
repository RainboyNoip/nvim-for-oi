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

  local luasnip = require("luasnip")
  local python_snippets = luasnip.get_snippets("python")
  assert_equal(#python_snippets, 17, "python snippet count")

  local actual_triggers = {}
  for _, snippet in ipairs(python_snippets) do
    actual_triggers[snippet.trigger] = true
  end

  local expected_triggers = {
    "main",
    "solve",
    "fastin",
    "ii",
    "ints",
    "listi",
    "strin",
    "f",
    "fr",
    "fri",
    "rf",
    "enum",
    "tests",
    "heap",
    "bisect",
    "deque",
    "dbg",
  }

  for _, trigger in ipairs(expected_triggers) do
    assert(actual_triggers[trigger], "missing Python snippet: " .. trigger)
  end

  assert_equal(#luasnip.get_snippets("cpp"), 37, "C++ snippet count")

  local function expand_snippet(trigger)
    if luasnip.in_snippet() then
      luasnip.unlink_current()
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    for _, snippet in ipairs(python_snippets) do
      if snippet.trigger == trigger then
        luasnip.snip_expand(snippet)
        return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
      end
    end

    error("cannot expand missing snippet: " .. trigger)
  end

  local main_expansion = expand_snippet("main")
  assert(main_expansion:find("def solve():", 1, true), "main snippet must define solve()")
  assert(main_expansion:find('if __name__ == "__main__":', 1, true), "main guard is missing")
  assert(main_expansion:find("    solve()", 1, true), "main snippet must call solve()")

  local inclusive_range = expand_snippet("fri")
  assert(
    inclusive_range:find("for i in range(left, right + 1):", 1, true),
    "fri snippet must include the right endpoint"
  )

  local dap = require("dap")
  assert_equal(type(dap.adapters.python), "function", "Python DAP adapter type")

  local python_configurations = dap.configurations.python or {}
  assert_equal(#python_configurations, 1, "Python DAP configuration count")

  local python_configuration = python_configurations[1]
  assert_equal(python_configuration.name, "Launch current Python file", "Python DAP name")
  assert_equal(python_configuration.type, "python", "Python DAP type")
  assert_equal(python_configuration.request, "launch", "Python DAP request")
  assert_equal(python_configuration.console, "integratedTerminal", "Python DAP console")
  assert_equal(python_configuration.justMyCode, true, "Python DAP justMyCode")
  assert_equal(#(dap.configurations.cpp or {}), 1, "C++ DAP configuration count")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_support: ok")
