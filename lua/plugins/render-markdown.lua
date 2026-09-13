return {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        enabled = true,
        file_types = { "markdown" },
    },
    keys = {
        { "<leader>mm", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown 渲染切换", ft = "markdown" },
        { "<leader>me", "<cmd>RenderMarkdown enable<cr>", desc = "Markdown 渲染开启", ft = "markdown" },
        { "<leader>md", "<cmd>RenderMarkdown disable<cr>", desc = "Markdown 渲染关闭", ft = "markdown" },
    },
}
