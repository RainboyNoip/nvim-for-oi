-- dap 快捷键
return {
    -- { "<leader>d",  group = "dap",                                                                        desc = "debug:nvim-dap short keys" },
    { "<leader>dR", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end,                                    desc = "Toggle Breakpoint" },
    { "<leader>dc", function() require("dap").continue() end,                                             desc = "Continue" },
    { "<leader>dC", function() require("dap").run_to_cursor() end,                                        desc = "Run to Cursor" },
    { "<leader>dg", function() require("dap").goto_() end,                                                desc = "Go to line (no execute)" },
    { "<leader>di", function() require("dap").step_into() end,                                            desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end,                                                 desc = "Down" },
    { "<leader>dk", function() require("dap").up() end,                                                   desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end,                                             desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end,                                             desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end,                                            desc = "Step Over" },
    { "<leader>dp", function() require("dap").pause() end,                                                desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end,                                          desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end,                                     desc = "Widgets" },
    -- 结束
    {
        "<F4>",
        function()
            require("dap").terminate()
            require("dapui").close()
        end,
        desc = "Terminate"
    },
    -- 启动调试/继续执行
    { "<F5>", function() require("dap").continue() end,          desc = "Continue" },
    -- 切换断点
    { "<F6>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    -- step_into
    { "<F7>", function() require("dap").step_into() end,         desc = "Step Into" },
    -- step out
    { "<F8>", function() require("dap").step_over() end,         desc = "Step Over" },
    { "<F9>", function() require("dap").run_to_cursor() end,     desc = "Run to Cursor" },
    {
        "n",
        function()
            local dap = require("dap")
            if (dap.session()) then
                dap.step_over()
            else
                return "n"
            end
        end,
        desc = "Step Over",
        mode = "n",
        expr = true
    },
    {
        "i",
        function()
            local dap = require("dap")
            if (dap.session()) then
                dap.step_into()
            else
                return "i"
            end
        end,
        desc = "Step Into",
        mode = "n",
        expr = true
    },
    {
        "b",
        function()
            local dap = require("dap")
            if (dap.session()) then
                dap.toggle_breakpoint()
            else
                return "b"
            end
        end,
        desc = "Step Over",
        mode = "n",
        expr = true
    },
    {
        "r",
        function()
            local dap = require("dap")
            if (dap.session()) then
                dap.restart()
            else
                return "r"
            end
        end,
        desc = "Step Over",
        mode = "n",
        expr = true
    },
    {
        "u",
        function()
            local dap = require("dap")
            if (dap.session()) then
                dap.run_to_cursor()
            else
                return "u"
            end
        end,
        desc = "run to cursor",
        mode = "n",
        expr = true
    },
}