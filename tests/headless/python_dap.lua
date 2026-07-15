local function run()
  local dap = require("dap")
  local breakpoints = require("dap.breakpoints")
  local stopped = false

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

  dap.terminate()
  assert(vim.wait(5000, function()
    return dap.session() == nil
  end, 50), "Python DAP session did not terminate")

  breakpoints.clear()
  dap.listeners.after.event_stopped["rainboy.python-test"] = nil
end

local ok, err = xpcall(run, debug.traceback)
if not ok then
  pcall(require("dap").terminate)
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit 1")
  return
end

print("python_dap: ok")
