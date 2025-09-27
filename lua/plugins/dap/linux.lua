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
            dap.adapters.cppdbg = {
                id = 'cppdbg',
                type = 'executable',
                command = config_path .. '/vscode-cpptools/debugAdapters/bin/OpenDebugAD7',
            }

            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "cppdbg",
                    request = "launch",
                    -- program = function()
                    --     return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    -- end,
                    program = function()
                        local currentFileName = vim.api.nvim_buf_get_name(0)
                        -- local currentFileName = vim.fn.expand("%")
                        local newFileName = currentFileName:gsub('%.%w+$', '.out')

                        local exists = vim.fn.filereadable(newFileName) == 1

                        print(newFileName)
                        -- if exists then
                        --     print("File already exists")
                        -- end
                        -- return newFileName
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopAtEntry = true,
                },
            }
        end,
        keys = require("plugins.dap.keys"),
    }
}
