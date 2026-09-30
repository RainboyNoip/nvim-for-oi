return {
  "rcarriga/nvim-dap-ui",
  ft = { "python" },
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    -- 布局：右侧是 DAP（REPL）窗口，由 nvim-dap 自己打开（见 dap.lua，<leader>dr 切换）；
    -- dapui 只负责底部的 disp（Watches）窗口。
    dapui.setup({
      controls = {
        -- 控制条挂在 watches 窗口顶部（原来挂 repl 元素，现 repl 已不归 dapui 管）
        element = "watches",
        enabled = true,
      },
      floating = {
        border = "single",
        mappings = { close = { "q", "<Esc>" } },
      },
      icons = { collapsed = "", expanded = "", current_frame = "" },
      layouts = {
        {
          elements = {
            { id = "watches", size = 1 },
          },
          position = "bottom",
          size = 10,
        },
      },
    })

    dap.listeners.after.event_initialized["rainboy_dapui"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["rainboy_dapui"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["rainboy_dapui"] = function()
      dapui.close()
    end
  end,
}
