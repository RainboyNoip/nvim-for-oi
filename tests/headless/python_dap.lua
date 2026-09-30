local function run()
  local dap = require("dap")
  local breakpoints = require("dap.breakpoints")
  local stopped = false
  local python = require("plugins.dap.python")
  local picker = require("snacks").picker
  local select_input = picker.select
  local source = vim.api.nvim_buf_get_name(0)
  picker.select = function(_, _, callback) callback(nil) end
  python.select_input(vim.fs.dirname(source), function()
    error("cancelling the picker must not launch the program")
  end)
  picker.select = function(items, options, callback)
    assert(options.prompt:find("标准输入"), "input picker must have a clear prompt")
    for _, item in ipairs(items) do
      if item.path == vim.fs.dirname(source) .. "/python_dap.in" then
        callback(item)
        return
      end
    end
    error("input picker did not discover the sample beside the source")
  end
  local output = ""
  dap.listeners.after.event_output["rainboy.python-test"] = function(_, event)
    if event.category == "stdout" then output = output .. event.output end
  end

  dap.listeners.after.event_stopped["rainboy.python-test"] = function()
    stopped = true
  end

  breakpoints.set({}, vim.api.nvim_get_current_buf(), 2)
  dap.run(dap.configurations.python[1], { filetype = "python" })

  assert(vim.wait(15000, function()
    return stopped
  end, 50), "debugpy did not stop at the breakpoint within 15 seconds")

  assert(vim.wait(5000, function()
    local active = dap.session()
    return active and active.stopped_thread_id ~= nil and active.current_frame ~= nil
  end, 50), "Python DAP session has no stopped frame")

  local session = assert(dap.session(), "Python DAP session is missing")

  local evaluated
  local evaluate_error
  session:evaluate("value", function(err, result)
    evaluate_error = err
    evaluated = result and result.result
  end)

  assert(vim.wait(5000, function()
    return evaluate_error ~= nil or evaluated ~= nil
  end, 50), "debugpy did not evaluate `value` within 5 seconds")
  assert(not evaluate_error, vim.inspect(evaluate_error))
  assert(evaluated == "21", "expected value == 21, got " .. vim.inspect(evaluated))

  local visible = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    visible[ft] = true
  end
  assert(visible["dap-repl"] and visible.dapui_watches, "REPL and watches must be visible")
  local repl_win, watches_win
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ft = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
    if ft == "dap-repl" then repl_win = win end
    if ft == "dapui_watches" then watches_win = win end
  end
  assert(repl_win and watches_win, "REPL and watches windows must exist")
  local repl_pos = vim.api.nvim_win_get_position(repl_win)
  local watches_pos = vim.api.nvim_win_get_position(watches_win)
  assert(repl_pos[2] > watches_pos[2], "DAP 窗口必须在右侧")
  assert(watches_pos[1] > repl_pos[1], "watch 窗口必须在下方")
  dap.repl.toggle({ width = 48 }, "botright vsplit")
  assert(not vim.api.nvim_win_is_valid(repl_win), "<leader>dr 必须能关闭 DAP 窗口")
  dap.repl.toggle({ width = 48 }, "botright vsplit")
  local reopened
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "dap-repl" then reopened = win end
  end
  assert(reopened, "<leader>dr 必须能重新打开 DAP 窗口")
  for _, ft in ipairs({ "dapui_scopes", "dapui_stacks", "dapui_breakpoints", "dapui_console" }) do
    assert(not visible[ft], "unexpected DAP window: " .. ft)
  end
  local watches = require("dapui").elements.watches
  watches.add("value")
  assert(watches.get()[1].expression == "value", "disp must retain the watched variable")

  -- cgdb 风格 REPL 命令（见 lua/plugins/dap/repl_commands.lua）
  local repl_commands = require("plugins.dap.repl_commands")
  local custom = require("dap.repl").commands.custom_commands
  for _, name in ipairs({
    "n", "next", "s", "step", "fin", "finish", "c", "continue",
    "until", "b", "break", "p", "print", "bt", "where", "locals", "info",
    "display", "undisplay",
  }) do
    assert(type(custom[name]) == "function", "REPL command missing: " .. name)
  end

  local scratch = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, {
    "@decorator",
    "def solve():",
    "    x = 1",
    "async def gen():",
    "    yield 1",
  })
  assert(
    repl_commands.find_function_line(scratch, "solve") == 3,
    "b 函数名必须落在函数体首行（装饰器不计入）"
  )
  assert(repl_commands.find_function_line(scratch, "gen") == 5, "b 函数名必须支持 async def")
  assert(repl_commands.find_function_line(scratch, "missing") == nil, "b 函数名找不到时返回 nil")

  -- b if / b 文件:行号 if：条件必须落到 breakpoints 上
  local fixture_win = vim.fn.bufwinid(vim.fn.bufnr(source))
  if fixture_win ~= -1 then
    vim.api.nvim_set_current_win(fixture_win)
  end
  local breakpoints = require("dap.breakpoints")
  custom.b("if value > 1")
  local bps = breakpoints.get()[vim.fn.bufnr(source)] or {}
  assert(#bps == 1 and bps[1].condition == "value > 1", "b if 必须在当前行设条件断点")
  custom.b(source .. ":1 if value == 21")
  local line1
  for _, bp in ipairs(breakpoints.get()[vim.fn.bufnr(source)] or {}) do
    if bp.line == 1 then line1 = bp end
  end
  assert(line1 and line1.condition == "value == 21", "b 文件:行号 if 必须支持")
  breakpoints.clear()  -- 清掉条件断点，避免 continue 后再次停下

  -- display / undisplay → disp
  custom.display("value * 2")
  assert(watches.get()[2].expression == "value * 2", "display 必须加入 disp")
  custom.undisplay("value * 2")
  assert(#watches.get() == 1, "undisplay 必须从 disp 移除")

  dap.continue()
  assert(vim.wait(5000, function()
    return dap.session() == nil
  end, 50), "Python DAP session did not terminate")
  assert(output:find("21", 1, true), "stdout must reach DAP/REPL without a terminal")

  breakpoints.clear()
  dap.listeners.after.event_stopped["rainboy.python-test"] = nil
  dap.listeners.after.event_output["rainboy.python-test"] = nil
  picker.select = select_input
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  pcall(require("dap").terminate)
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_dap: ok")
