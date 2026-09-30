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
  for _, ft in ipairs({ "dapui_scopes", "dapui_stacks", "dapui_breakpoints", "dapui_console" }) do
    assert(not visible[ft], "unexpected DAP window: " .. ft)
  end
  local watches = require("dapui").elements.watches
  watches.add("value")
  assert(watches.get()[1].expression == "value", "disp must retain the watched variable")

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
