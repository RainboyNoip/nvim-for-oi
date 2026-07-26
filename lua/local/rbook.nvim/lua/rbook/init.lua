local config = require("rbook.config")

local M = {}

local commands = {
  RbookCode = {
    desc = "Rbook 正式代码模板",
    run = function()
      M.code()
    end,
  },
  RbookCodeFiles = {
    desc = "Rbook 浏览全部代码文件",
    run = function()
      M.code_files()
    end,
  },
  RbookCodeRefresh = {
    desc = "Rbook 刷新索引",
    run = function()
      M.refresh()
    end,
  },
  RbookDoctor = {
    desc = "Rbook 检查模板索引",
    run = function()
      M.doctor()
    end,
  },
}

local function register_commands()
  for name, command in pairs(commands) do
    vim.api.nvim_create_user_command(name, command.run, {
      desc = command.desc,
      force = true,
    })
  end
end

function M.setup(opts)
  config.setup(opts)
  -- lazy.nvim 在加载插件前会删除 cmd 占位命令，因此这里必须创建真实命令。
  register_commands()
end

function M.code()
  require("rbook.picker").code()
end

function M.code_files()
  require("rbook.picker").code_files()
end

function M.refresh()
  local data = require("rbook.catalog").refresh()
  if data then
    vim.notify("Rbook 索引已刷新")
  end
end

function M.doctor()
  require("rbook.doctor").run()
end

return M
