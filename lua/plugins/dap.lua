-- 只启用 Python 调试。C/C++ 继续使用终端调试工具。
return {
  "mfussenegger/nvim-dap",
  ft = { "python" },
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local dap = require("dap")
    require("plugins.dap.python").setup(dap)
    require("plugins.dap.repl_commands").setup(dap)
    require("nvim-dap-virtual-text").setup({})
  end,
  keys = require("plugins.dap.keys"),
}
