return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- "nvim-neotest/nvim-nio", -- 如果你的 Neovim 版本 < 1.10.0

            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            require("nvim-dap-virtual-text").setup()
            local Snacks = require("snacks")
            local dap = require('dap')
            dap.set_log_level('TRACE')
            -- require("dap").set_log_level("DEBUG")

            dap.listeners.after.event_initialized['dapui_config'] = function()
                vim.bo.readonly = true
                -- vim.bo.relativenumber = false
            end

            dap.listeners.before.event_terminated['dapui_config'] = function()
                vim.bo.readonly = false
                -- vim.bo.relativenumber = true
            end

            dap.listeners.before.event_exited['dapui_config'] = function()
                vim.bo.readonly = false
                -- vim.bo.relativenumber = true
            end

            local config_path = vim.fs.dirname(vim.fn.stdpath('config'))
            dap.defaults.fallback.terminal_win_cmd = "3split new" -- 这里把终端窗口设置的尽可能的小一点,我依然没有找到怎么隐藏这个 termina
            dap.adapters.lldb = {
                type = "executable",
                command = "/opt/homebrew/opt/llvm/bin/lldb-dap", -- or if not in $PATH: "/absolute/path/to/codelldb"
                name = "lldb-dap",
            }
            dap.configurations.cpp = {
                {
                    name = "Launch file",
                    type = "lldb",
                    request = "launch",
                    targetArchitecture = "arm64",
                    program = function()
                        -- return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/' .. vim. , 'file')
                        -- 1. 获取当前文件的完整路径 (例如: /home/user/src/1.cpp)
                        -- '%:p' 代表文件的绝对路径 (Full Path)
                        local full_path = vim.fn.expand('%:p')

                        -- 2. 获取文件的目录路径 (Head)
                        -- ':h' 是文件名修饰符，代表 "Head" (路径部分，不包含文件名)
                        local file_dir = vim.fn.fnamemodify(full_path, ':h')

                        -- 3. 获取文件的根名称 (Root)
                        -- ':t:r' 是修饰符，代表 "Tail" (文件名) 和 "Root" (去除扩展名)
                        local file_root = vim.fn.expand('%:t:r')

                        -- 4. 构造默认值：文件目录 + 分隔符 + 文件根名称 + ".out"
                        -- 注意：在 Unix-like 系统上，目录和文件名之间需要一个 '/'
                        local default_value = file_dir .. '/' .. file_root .. '.out'

                        -- 5. 使用 vim.fn.input() 进行同步输入
                        local val = vim.fn.input('Path to executable: ', default_value, 'file')

                        -- print(val)

                        return val
                    end,
                    runInTerminal = false,
                    cwd = function ()
                        return vim.fn.getcwd()
                    end,
                    stopOnEntry = false,
                    console = "internalConsole", -- 告诉适配器不要启动外部终端
                    args = {},
                    initCommands = function()
                        return {
                            -- "command source " .. vim.fn.stdpath("config") .. "/lua/plugins/dap/lldbinit",
                            -- "command script import " .. vim.fn.stdpath("config") .. "/lua/plugins/dap/lldb_scripts/tu.py",
                            -- "command script import " .. vim.fn.stdpath("config") .. "/lua/plugins/dap/lldb_scripts/arr.py"
                        }
                    end,
                    -- lldb-dap 22 才支持
                    -- stdio = function()
                    --     local input_file = vim.fn.input("Path to read: ", vim.fn.getcwd() .. '/in','file')
                    --     -- print(input_file)
                    --     return { input_file, 'out.txt'}
                    --     -- return input_file
                    -- end
                },
            }
        end,
        keys = require("plugins.dap.keys"),
    }
}
