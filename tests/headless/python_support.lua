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
  assert_equal(analysis.pythonVersion, "3.15", "target Python version")
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

  -- lazy.nvim 在首个 FileType 后才执行本地插件的 setup，所以显式调用一次；
  -- setup 会处理当前 buffer，并为后续 Python buffer 注册 autocmd。
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
  assert_equal(#python_snippets, 74, "python snippet count")

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
    "testsdata",
    "heap",
    "bisect",
    "deque",
    "dbg",
  }

  local general_triggers = {
    "mainread",
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
    "type",
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
    "next%s+(.+)",
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

  assert_equal(#luasnip.get_snippets("cpp"), 42, "C++ snippet count")

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

  -- 正则触发 snippet 必须走真实匹配路径：直接 snip_expand 拿不到 captures，
  -- 而 dynamic_node 里的名字就是从 captures 取。
  -- 末尾补一个空格，让光标落在空格上、等价于“刚打完最后一个 token”。
  local function expand_regex_snippet(line_before_cursor)
    if luasnip.in_snippet() then
      luasnip.unlink_current()
    end
    local padded = line_before_cursor .. " "
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { padded })
    vim.api.nvim_win_set_cursor(0, { 1, #padded - 1 })
    assert(luasnip.expandable(), line_before_cursor .. " must match a snippet")
    luasnip.expand()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    lines[#lines] = lines[#lines]:gsub(" $", "")
    return table.concat(lines, "\n")
  end

  local main_expansion = expand_snippet("main")
  assert(main_expansion:find("def solve():", 1, true), "main snippet must define solve()")
  assert(
    main_expansion:find("input = sys.stdin.buffer.readline", 1, true),
    "main snippet must use line input"
  )
  assert(main_expansion:find('if __name__ == "__main__":', 1, true), "main guard is missing")
  assert(main_expansion:find("    solve()", 1, true), "main snippet must call solve()")

  local mainread_expansion = expand_snippet("mainread")
  assert(mainread_expansion:find("def solve(data):", 1, true), "mainread must pass the iterator")
  assert(
    mainread_expansion:find("data = iter(map(int, sys.stdin.buffer.read().split()))", 1, true),
    "mainread must read stdin once"
  )
  assert(mainread_expansion:find("    solve(data)", 1, true), "mainread must call solve(data)")

  local testsdata_expansion = expand_snippet("testsdata")
  assert(
    testsdata_expansion:find("for _ in range(next(data)):", 1, true),
    "testsdata must read the case count from data"
  )
  assert(
    testsdata_expansion:find("    solve(data)", 1, true),
    "testsdata must pass data to solve"
  )

  -- for 家族：
  --   不带显式下界的默认形态是 0-based 半开 range(n)（Python 习惯，不再是 1-based）；
  --   显式给 l r 的仍保留闭区间 range(l, r + 1)；倒序 rf 仍 1-based 含端点。
  local plain_for = expand_snippet("f")
  assert(plain_for:find("for i in range(n):", 1, true), "f must be half-open range(n)")
  assert(not plain_for:find("+ 1", 1, true), "f must not add +1 to the bound")

  local reverse_for = expand_snippet("rf")
  assert(reverse_for:find("for i in range(n, 0, -1):", 1, true), "rf must count down to 0")

  local line_for = expand_snippet("lf")
  assert(line_for:find("for i in range(n):", 1, true), "lf must mirror f's half-open range")

  -- f 10 -> range(10)（循环 10 次，不写死 +1）
  local for_count = expand_regex_snippet("f 10")
  assert(
    for_count:find("for i in range(10):", 1, true),
    "f 10 must expand to range(10), not range(1, 10 + 1)"
  )

  -- f l r 仍是闭区间：显式给下界时 “到 r” 含 r
  local for_bounds = expand_regex_snippet("f l r")
  assert(
    for_bounds:find("for i in range(l, r + 1):", 1, true),
    "f l r must stay inclusive range(l, r + 1)"
  )

  -- 走真实触发词匹配，检查数字捕获、多位数、前导零和遍历对象的保留。
  local tab = require("cmp").get_config().mapping["<Tab>"].i
  for _, case in ipairs({
    { "enum", "enumerate(a)" },
    { "enum a", "enumerate(a)" },
    { "enum values", "enumerate(values)" },
    { "enum a[1:]", "enumerate(a[1:])" },
    { "enum0 a", "enumerate(a, 0)", "0" },
    { "enum1 a", "enumerate(a, 1)", "1" },
    { "enum2 a", "enumerate(a, 2)", "2" },
    { "enum10 values", "enumerate(values, 10)", "10" },
    { "enum002 a", "enumerate(a, 2)", "2" },
  }) do
    assert_equal(
      expand_regex_snippet(case[1]),
      "for idx, val in " .. case[2] .. ":\n    pass",
      case[1] .. " expansion"
    )
    -- 起始索引来自 trigger，是静态文本；可编辑字段始终只有 idx/val/pass。
    local fields = { "idx", "val", "pass" }
    for position, text in ipairs(fields) do
      local node = luasnip.session.current_nodes[bufnr]
      assert_equal(node.pos, position, case[1] .. " contiguous jump index")
      assert_equal(node:get_text(), { text }, case[1] .. " editable field")
      tab(function() error(case[1] .. " Tab must jump through fields and exit") end)
    end
    local exit_node = luasnip.session.current_nodes[bufnr]
    assert(not exit_node or exit_node.pos == 0, case[1] .. " must exit the dynamic snippet")
  end

  -- 起始索引和遍历对象固定；idx 改成触发词 f 后，Tab 仍跳到 val。
  expand_regex_snippet("enum002 a")
  local enum_node = luasnip.session.current_nodes[bufnr]
  assert_equal(enum_node.pos, 1, "enumerate first field must be idx")
  local first, last = enum_node.mark:pos_begin_end()
  vim.api.nvim_buf_set_text(bufnr, first[1], first[2], last[1], last[2], { "f" })
  vim.api.nvim_win_set_cursor(0, { first[1] + 1, first[2] + 1 })
  luasnip.active_update_dependents()
  assert(luasnip.expandable(), "f must match a snippet to reproduce the Tab conflict")
  tab(function() error("Tab must jump within enumerate") end)
  assert_equal(luasnip.session.current_nodes[bufnr].pos, 2, "Tab must jump to val")
  assert_equal(luasnip.session.current_nodes[bufnr]:get_text(), { "val" }, "val placeholder")
  luasnip.jump(1)
  assert_equal(luasnip.session.current_nodes[bufnr]:get_text(), { "pass" }, "loop body placeholder")

  -- next a b c：名字从正则捕获取，data 是唯一的可改字段（三处 mirror）
  local next_three = expand_regex_snippet("next a b c")
  assert_equal(
    next_three,
    "a, b, c = next(data), next(data), next(data)",
    "next a b c expansion"
  )

  -- next() 的个数跟名字个数走
  local next_two = expand_regex_snippet("next a b")
  assert_equal(next_two, "a, b = next(data), next(data)", "next a b expansion")

  local next_one = expand_regex_snippet("next n")
  assert_equal(next_one, "n = next(data)", "next n expansion")

  -- data 必须是可跳转的 insert_node，不是死文本；三处 next() 共用一个 jump index。
  -- 前面的 next n 只有一处 next()，所以这里重新展开一次 next a b c。
  expand_regex_snippet("next a b c")
  local node_types = require("luasnip.util.types")
  assert(luasnip.in_snippet(), "next a b c 展开后必须处于 snippet session 中")
  local active = luasnip.session.current_nodes[bufnr]
  assert(active, "展开后应该有 current_node")
  local inner = active.parent.snippet.insert_nodes[1].snip
  local insert_nodes, mirror_nodes = {}, {}
  for _, node in ipairs(inner.nodes) do
    if node.type == node_types.insertNode then
      table.insert(insert_nodes, node)
    elseif node.type == node_types.functionNode then
      table.insert(mirror_nodes, node)
    end
  end
  assert_equal(#insert_nodes, 1, "next 只应有一个可改字段 data")
  assert_equal(insert_nodes[1]:get_static_text()[1], "data", "可改字段默认值是 data")
  assert_equal(#mirror_nodes, 2, "剩下两个 next() 应该是 mirror")
  for _, node in ipairs(mirror_nodes) do
    assert_equal(node.args, { 1 }, "mirror 必须指向 jump index 1")
  end
  luasnip.unlink_current()

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

  -- 第二个 Python buffer 也必须自动恢复 Python 的 window-local foldmarker。
  local second = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, second)
  vim.wo.foldmarker = "//oisnip_begin,//oisnip_end"
  vim.bo[second].filetype = "python"
  assert_equal(vim.wo.foldmarker, "#oisnip_begin,#oisnip_end", "second Python buffer foldmarker")

  local dap = require("dap")

  assert_equal(type(dap.adapters.python), "function", "Python DAP adapter type")

  local python_configurations = dap.configurations.python or {}
  assert_equal(#python_configurations, 1, "Python DAP configuration count")

  local python_configuration = python_configurations[1]
  assert_equal(python_configuration.name, "Launch current Python file", "Python DAP name")
  assert_equal(python_configuration.type, "python", "Python DAP type")
  assert_equal(python_configuration.request, "launch", "Python DAP request")
  assert_equal(python_configuration.console, "internalConsole", "Python DAP console")
  assert_equal(python_configuration.justMyCode, true, "Python DAP justMyCode")
  assert_equal(#(dap.configurations.cpp or {}), 0, "C++ DAP must remain disabled")
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_support: ok")
