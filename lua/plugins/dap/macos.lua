return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            -- "nvim-neotest/nvim-nio", -- 如果你的 Neovim 版本 < 0.10.0
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require('dap')
            local config_path = vim.fs.dirname(vim.fn.stdpath('config'))
            dap.adapters.codelldb = {
                type = "executable",
                -- command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"
                command = config_path .. '/codelldb/adapter/codelldb',
                name = "lldb",
                -- On windows you may have to uncomment this:
                -- detached = false,
            }
            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false, -- 必需是false,不然有汇编代码
                    -- from here:  https://github.com/vadimcn/codelldb/blob/master/MANUAL.md#stdio-redirection
                    stdio = function() 
                        local input_file = vim.fn.input("Path to read: ", vim.fn.getcwd() .. '/' )
                        return { input_file , 'log.txt', 'tty' }
                    end,
                },
            }
        end,
        keys = require("plugins.dap.keys"),
    }
}
