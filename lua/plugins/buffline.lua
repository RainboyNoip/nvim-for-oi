return {
    "akinsho/bufferline.nvim",
    dependencies = {
        "folke/snacks.nvim",
    },
    event = "VeryLazy",
    opts = {
        options = {
            mode = "buffers", -- set to "tabs" to only show tabpages instead
            -- stylua: ignore
            -- stylua: ignore
            close_command = function(n) require("snacks").bufdelete(n) end,
            -- stylua: ignore
            right_mouse_command = function(n) require("snacks").bufdelete(n) end,
            diagnostics = "nvim_lsp",

            -- 一直显示bufferline
            always_show_bufferline = true,
            -- 分割线样式
            separator_style = "slant",
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
                {
                    filetype = "snacks_layout_box",
                },
            },
            ---@param opts bufferline.IconFetcherOpts
            -- get_element_icon = function(opts)
            --     return LazyVim.config.icons.ft[opts.filetype]
            -- end,
        },
    },
    keys = {
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "Toggle Pin" },
        { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
        { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",           desc = "Delete Buffers to the Right" },
        { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",            desc = "Delete Buffers to the Left" },
        { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
        { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
        { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
        { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
        { "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
        { "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
    },
}
