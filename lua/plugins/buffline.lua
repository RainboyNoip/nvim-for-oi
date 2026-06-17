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
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>",            desc = "固定 / 取消固定 buffer" },
        { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "关闭未固定 buffer" },
        { "<leader>br", "<Cmd>BufferLineCloseRight<CR>",           desc = "关闭右侧 buffer" },
        { "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>",            desc = "关闭左侧 buffer" },
        { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            desc = "上一个 buffer" },
        { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            desc = "下一个 buffer" },
        { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "上一个 buffer" },
        { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "下一个 buffer" },
        { "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "向左移动 buffer" },
        { "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "向右移动 buffer" },
    },
}
