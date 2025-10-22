return {
    "folke/snacks.nvim",
    ---@type snacks.Config
    lazy = false,
    priority = 1001,
    opts = {
        dashboard = require("plugins.snacks.dashboard"),
        -- 默认配置 的 explorer
        explorer = {}, 
        terminal = {
            win = {
                position = "float", -- 默认浮动
                width = 0.8,        -- 宽度 80%
                height = 0.7,       -- 高度 70%
                border = "rounded", -- 圆角边框
                wo = {
                    winblend = 10,  -- 窗口透明度
                }
            },
            interactive = true,
            auto_insert = true,
            auto_close = false, -- 保持终端打开
        }
    },
    keys = {
        -- toggle explorer
        {
            "<leader>e",
            function()
                require("snacks").explorer()
            end,
            desc = "Toggle Snacks Explorer",
        },
        {
            "<leader>t",
            group = "Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tt",
            function()
                require("snacks.terminal").toggle()
            end,
            desc = "Toggle Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tc",
            function()
                require("plugins.snacks.terminal").select_toggle()
            end,
            desc = "Select Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tf",
            function()
                require("snacks.terminal").get("bash",{auto_close = false})
            end,
            desc = "Open Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>ts",
            function()
                print(#require("snacks.terminal").list())
            end,
            desc = "print terminal list size",
            mode = { "n", "t" },

        }

    }
}
