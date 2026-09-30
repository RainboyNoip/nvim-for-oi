-- dap 快捷键
return {
    { "<leader>d", group = "Python 调试" },
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
    { "<leader>dr", function() require("dap").repl.toggle({ width = 48 }, 'botright vsplit') end,                                          desc = "Toggle DAP window" },
    { "<leader>ds", function() require("dap").session() end,                                              desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end,                                            desc = "Terminate" },
    { "<leader>dw", function()
        require("dapui").elements.watches.add(vim.fn.expand("<cword>"))
    end, desc = "disp：监视光标变量" },
    { "<leader>de", function()
        require("snacks").input({ prompt = "监视表达式" }, function(expression)
            if expression and expression:match("%S") then
                require("dapui").elements.watches.add(expression)
            end
        end)
    end, desc = "disp：添加监视表达式" },
    -- 重启
    { "<leader>dn",
        function() 
            local dap  = require("dap")
            if dap.session() then
                dap.restart()
            else
                dap.continue()
            end
        end,
        desc = "restart"
    },
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
}
