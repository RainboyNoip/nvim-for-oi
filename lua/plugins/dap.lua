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

    -- DAP（REPL）窗口固定在右侧：会话启动自动打开，<leader>dr 随时开关。
    -- 程序结束后不关，方便查看 stdout/stderr。
    local repl_winopts = { width = 48 }
    dap.listeners.after.event_initialized["rainboy_dap_repl"] = function()
      dap.repl.open(repl_winopts, "botright vsplit")
    end
  end,
  keys = require("plugins.dap.keys"),
}
