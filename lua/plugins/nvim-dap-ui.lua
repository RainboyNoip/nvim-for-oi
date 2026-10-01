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

    -- 布局：右侧一栏分上下两格——上= DAP（REPL），下= disp（Watches）。
    -- <leader>dr 整栏开关（dapui.toggle）。程序结束后保留右栏，方便查看 stdout。
    dapui.setup({
      controls = {
        element = "repl",
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
            { id = "repl", size = 0.65 },
            { id = "watches", size = 0.35 },
          },
          position = "right",
          size = 48,
        },
      },
    })

    dap.listeners.after.event_initialized["rainboy_dapui"] = function()
      dapui.open()
    end
  end,
}
