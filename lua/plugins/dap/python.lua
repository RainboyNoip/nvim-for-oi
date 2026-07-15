local M = {}

local docs_path = "docs/how-to-use-in-python.md"

local function abort(dap, message)
  vim.notify(message .. " See " .. docs_path .. ".", vim.log.levels.ERROR, { title = "Python DAP" })
  return dap.ABORT
end

local function resolve_program(dap)
  local program = vim.fn.expand("%:p")
  if program == "" or vim.bo.modified or vim.fn.filereadable(program) ~= 1 then
    return abort(dap, "Save the current Python file before debugging.")
  end

  if vim.fn.executable("python3") ~= 1 then
    return abort(dap, "`python3` is not available in PATH.")
  end

  local result = vim.system({ "python3", "-c", "import debugpy" }, { text = true }):wait()
  if result.code ~= 0 then
    return abort(dap, "debugpy is unavailable. Run `sudo pacman -S python-debugpy`.")
  end

  return program
end

function M.setup(dap)
  dap.adapters.python = function(callback)
    callback({
      type = "executable",
      command = "python3",
      args = { "-m", "debugpy.adapter" },
    })
  end

  dap.configurations.python = {
    {
      name = "Launch current Python file",
      type = "python",
      request = "launch",
      program = function()
        return resolve_program(dap)
      end,
      cwd = function()
        return vim.fn.getcwd()
      end,
      console = "integratedTerminal",
      justMyCode = true,
    },
  }
end

return M
