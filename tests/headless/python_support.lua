local function assert_equal(actual, expected, label)
  assert(vim.deep_equal(actual, expected), string.format(
    "%s: expected %s, got %s",
    label,
    vim.inspect(expected),
    vim.inspect(actual)
  ))
end

local assets = require("snippetAssets")

local function run()
  assert(vim.lsp.config.clangd, "clangd config must remain registered")

  local config = vim.lsp.config.basedpyright
  assert(config, "basedpyright config must be registered")
  assert_equal(config.cmd, { "basedpyright-langserver", "--stdio" }, "basedpyright cmd")
  assert_equal(config.filetypes, { "python" }, "basedpyright filetypes")

  local analysis = config.settings.basedpyright.analysis
  assert_equal(analysis.diagnosticMode, "openFilesOnly", "diagnostic mode")
  assert_equal(analysis.typeCheckingMode, "basic", "type checking mode")
  assert_equal(
    analysis.diagnosticSeverityOverrides.reportPossiblyUnboundVariable,
    "error",
    "possibly unbound variable severity"
  )

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

  -- 注意：python-settings 是通过 ft 懒加载的，一个 nvim 进程里只会对「第一个」
  -- python buffer 触发一次 setup()。测试自己新建的 buffer 不会再触发它，
  -- 所以这里显式调用一次 setup，验证的是「配置生效后的结果」而不是 lazy 的触发时机。
  -- （foldmarker 是 window-local，所以要读显示该 buffer 的 window。）
  require("python-settings").setup()
  local win = vim.fn.bufwinid(bufnr)
  assert(win ~= -1, "python buffer must be displayed in a window")
  assert_equal(
    vim.api.nvim_get_option_value("foldmarker", { win = win }),
    "#oisnip_begin,#oisnip_end",
    "python foldmarker"
  )

  local luasnip = require("luasnip")
  local python_snippets = luasnip.get_snippets("python")
  assert_equal(#python_snippets, 67, "python snippet count")

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
    "lf",
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
    "flow",
    "lc",
    "sc",
    "dictc",
    "gen",
    "ta",
    "opt",
  }

  -- 从 C++ 迁移过来的正则触发 snippet，trigger 是完整 Lua pattern。
  local cpp_ported_triggers = {
    "i0%s+([%w_ ]+)",
    "ci%s+(.+)",
    "co%s+(.+)",
    "lg%s+(.+)",
    "so%s+(.+)",
    "rs%s+(.+)",
    "uq%s+(.+)",
    "pq%s+(.+)",
    "pqg%s+(.+)",
    "lb%s+(%S+)%s+(%S+)",
    "ub%s+(%S+)%s+(%S+)",
    "vi%s+(%S+)%s+(%S+)",
    "vl%s+(%S+)%s+(%S+)",
    "re%s+(%S+)",
    "ef%s+(%S+)",
    "ee%s+(%S+)",
    "eew%s+(%S+)",
    "ee2%s+(%S+)",
    "ee2w%s+(%S+)",
  }

  for _, trigger in ipairs(oj_triggers) do
    assert_equal(trigger_counts[trigger], 1, "OJ Python snippet: " .. trigger)
  end

  for _, trigger in ipairs(cpp_ported_triggers) do
    assert_equal(trigger_counts[trigger], 1, "C++ ported Python snippet: " .. trigger)
  end

  for _, trigger in ipairs(general_triggers) do
    assert_equal(trigger_counts[trigger], 1, "general Python snippet: " .. trigger)
  end

  assert_equal(#luasnip.get_snippets("cpp"), 40, "C++ snippet count")

  local package_path = assets.vscodeSnippets .. "/package.json"
  local package = vim.json.decode(table.concat(vim.fn.readfile(package_path), "\n"))
  local python_registered = false
  for _, contribution in ipairs(package.contributes.snippets) do
    if contribution.language == "python" and contribution.path == "./python.json" then
      python_registered = true
      break
    end
  end
  assert(python_registered, "snippetAssets.vscodeSnippets/package.json must register python.json")

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

  -- for 家族与 C++ 的 for.lua 对齐后的行为
  local plain_for = expand_snippet("f")
  assert(plain_for:find("for i in range(1, n + 1):", 1, true), "f must be inclusive from 1 to n")

  local reverse_for = expand_snippet("rf")
  assert(reverse_for:find("for i in range(n, 0, -1):", 1, true), "rf must count down to 0")

  local line_for = expand_snippet("lf")
  assert(line_for:find("for i in range(1, n + 1):", 1, true), "lf must be a single-line loop")

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

  local flow = expand_snippet("flow")
  assert(flow:find("def flow(value, *steps):", 1, true), "flow snippet must define flow()")
  assert(flow:find("for step in steps:", 1, true), "flow snippet must iterate over steps")
  assert(flow:find("value = step(value)", 1, true), "flow snippet must apply each step")

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

  -- nvim-dap 在 2026-08-22 被临时禁用，未安装时跳过 DAP 断言。
  local dap_ok, dap = pcall(require, "dap")
  if not dap_ok then
    print("python_support: dap not installed, skipping DAP assertions")
    return
  end

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
