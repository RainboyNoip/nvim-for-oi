-- 需要的时候查看文档: https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file#quickstart
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp", "markdown" },
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if lang then
                        vim.treesitter.start(args.buf, lang)
                    end
                end,
            })
        end,
    },
}
