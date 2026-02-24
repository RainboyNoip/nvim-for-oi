-- 需要的时候查看文档: https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#quickstart
return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            return {
                ensure_installed = { "cpp" ,"c"},
                auto_install = true,
                highlight = {
                    enable = true,
                },
            }
        end,
    },
}
