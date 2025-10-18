return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- "nvim-neotest/nvim-nio", -- 如果你的 Neovim 版本 < 1.10.0
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require('dap')
            local config_path = vim.fs.dirname(vim.fn.stdpath('config'))
            dap.defaults.fallback.terminal_win_cmd = "3split new" -- 这里把终端窗口设置的尽可能的小一点,我依然没有找到怎么隐藏这个 termina
            dap.adapters.codelldb = {
                type = "executable",
                -- command = "codelldb", -- or if not in $PATH: "/absolute/path/to/codelldb"
                command = config_path .. '/codelldb/adapter/codelldb',
                name = "lldb",
                -- On windows you may have to uncomment this:
                -- detached = false,
                terminal_win_cmd = "50vsplit new"
            }
            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    initCommands = function()
                        return {
                            "command source " .. vim.fn.stdpath("config") .. "/lua/plugins/dap/lldbinit"
                        }
                    end,
                    cwd = '${workspaceFolder}',
                    -- console = "internalConsole",
                    stopOnEntry = false, -- 必需是false,不然有汇编代码

                    -- 调试的程序输入重定向 from here:  https://github.com/vadimcn/codelldb/blob/master/MANUAL.md#stdio-redirection
                    stdio = function()
                        local input_file = vim.fn.input("Path to read: ", vim.fn.getcwd() .. '/')
                        return { input_file, 'log.txt', 'stderr.log' }
                    end
                },
            }
        end,
        keys = require("plugins.dap.keys"),
    }
}
