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
  assert_equal(#python_snippets, 41, "python snippet count")

  local trigger_counts = {}
  for _, snippet in ipairs(python_snippets) do
    trigger_counts[snippet.trigger] = (trigger_counts[snippet.trigger] or 0) + 1
  end

  local oj_triggers = {
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

  local general_triggers = {
    "df",
    "dft",
    "adf",
    "lm",
    "cls",
    "init",
    "dcls",
    "prop",
    "deco",
    "ifm",
    "ife",
    "mt",
    "fe",
    "wh",
    "tr",
    "trf",
    "wth",
    "ctx",
    "lc",
    "sc",
    "dictc",
    "gen",
    "ta",
    "opt",
  }

  for _, trigger in ipairs(oj_triggers) do
    assert_equal(trigger_counts[trigger], 1, "OJ Python snippet: " .. trigger)
  end

  for _, trigger in ipairs(general_triggers) do
    assert_equal(trigger_counts[trigger], 1, "general Python snippet: " .. trigger)
  end

  assert_equal(#luasnip.get_snippets("cpp"), 37, "C++ snippet count")

  local package_path = vim.fn.stdpath("config") .. "/vscode-snippets/package.json"
  local package = vim.json.decode(table.concat(vim.fn.readfile(package_path), "\n"))
  local python_registered = false
  for _, contribution in ipairs(package.contributes.snippets) do
    if contribution.language == "python" and contribution.path == "./python.json" then
      python_registered = true
      break
    end
  end
  assert(python_registered, "vscode-snippets/package.json must register python.json")

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

  local property = expand_snippet("prop")
  assert(property:find("@property", 1, true), "prop snippet must define a property")
  assert(property:find("@name.setter", 1, true), "prop snippet must define a setter")
  assert(property:find("self._name = value", 1, true), "prop snippet must update the backing attribute")

  local decorator = expand_snippet("deco")
  assert(decorator:find("from functools import wraps", 1, true), "deco snippet must import wraps")
  assert(decorator:find("@wraps(func)", 1, true), "deco snippet must preserve function metadata")

  local context_manager = expand_snippet("ctx")
  assert(context_manager:find("@contextmanager", 1, true), "ctx snippet must use contextmanager")
  assert(context_manager:find("yield resource", 1, true), "ctx snippet must yield its resource")
  assert(context_manager:find("release(resource)", 1, true), "ctx snippet must release its resource")

  local list_comprehension = expand_snippet("lc")
  assert(
    list_comprehension:find("[expression for item in iterable]", 1, true),
    "lc snippet default must not require a filter"
  )

  local choice_reached = false
  for _ = 1, 5 do
    if luasnip.choice_active() then
      choice_reached = true
      break
    end
    if luasnip.jumpable(1) then
      luasnip.jump(1)
    end
  end
  assert(choice_reached, "lc snippet must provide a filter choice")
  luasnip.change_choice(1)
  local filtered_comprehension = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
  assert(
    filtered_comprehension:find("[expression for item in iterable if condition]", 1, true),
    "lc filter choice must insert `if condition`"
  )

  for _, trigger in ipairs(general_triggers) do
    local expansion = expand_snippet(trigger)
    local result = vim.system({
      "python3",
      "-c",
      "import sys; compile(sys.argv[1], '<" .. trigger .. ">', 'exec')",
      expansion,
    }, { text = true }):wait()
    assert(result.code == 0, string.format(
      "%s snippet is not valid Python:\n%s\n%s",
      trigger,
      expansion,
      result.stderr or ""
    ))
  end

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
