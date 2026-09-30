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

-- 在启动 adapter 前完成异步选择；Esc 取消时不启动调试进程。
function M.select_input(directory, callback)
  local files = vim.fs.find(function(name)
    return name == "in" or name:match("%.in$") or name:match("%.txt$")
      or name:match("^in%d+$")
  end, { path = directory, type = "file", limit = math.huge, depth = 3 })
  table.sort(files)
  local items = {}
  for _, path in ipairs(files) do
    items[#items + 1] = { path = path, text = vim.fs.relpath(directory, path) or path }
  end
  items[#items + 1] = { path = "/dev/null", text = "空输入（不读取样例）" }
  require("snacks").picker.select(items, {
    prompt = "Python 调试：选择标准输入文件",
    format_item = function(item) return item.text end,
  }, function(item)
    if item then callback(item.path) end
  end)
end

local function enrich_config(config, on_config)
  local launcher = vim.fn.stdpath("config") .. "/scripts/python_dap_launch.py"
  local source = config.program
  local arguments = config.args or {}
  -- 不支持原地 restart 的 adapter 会把已处理的配置再次交回来。
  if source == launcher then
    source = arguments[1]
    arguments = vim.list_slice(arguments, 3)
  end
  M.select_input(vim.fs.dirname(source), function(input)
    if vim.fn.filereadable(input) ~= 1 and input ~= "/dev/null" then
      vim.notify("无法读取输入文件：" .. input, vim.log.levels.ERROR)
      return
    end
    local launch = vim.deepcopy(config)
    launch.program = launcher
    launch.args = { source, input }
    vim.list_extend(launch.args, arguments)
    on_config(launch)
  end)
end

function M.setup(dap)
  dap.adapters.python = function(callback)
    callback({
      type = "executable",
      command = "python3",
      args = { "-m", "debugpy.adapter" },
      enrich_config = enrich_config,
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
        return vim.fn.expand("%:p:h")
      end,
      console = "internalConsole",
      redirectOutput = true,
      justMyCode = true,
    },
  }
end

return M
