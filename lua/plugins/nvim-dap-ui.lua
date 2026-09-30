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
            { id = "watches", size = 1 },
          },
          position = "right",
          size = 36,
        },
        {
          elements = {
            { id = "repl", size = 1 },
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
