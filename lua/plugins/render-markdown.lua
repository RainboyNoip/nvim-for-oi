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

        -- 公式渲染：把 $...$ / $$...$$ 转成 Unicode 文本画在 buffer 里。
        -- 注意这不是 KaTeX，也不是 LaTeX 排版 —— render-markdown 的 latex 模块
        -- 只是调用一个外部命令，把公式源码经 stdin 传进去，再把 stdout 当成
        -- 文本行显示（见 handler/latex.lua 的 Handler.convert）。所以 pdflatex /
        -- typst 这类产出 PDF 的工具在这里毫无用处，必须是「LaTeX → Unicode」转换器：
        --   utftex     来自 libtexprintf，多行排版（分式堆叠、积分带上下限）—— 优先
        --   latex2text 来自 pylatexenc，单行近似（\frac{a}{b} -> a/b）  —— 兜底
        -- 两个都不在 Arch 官方仓库里，安装方法见 docs/how-to-render-math.md。
        -- converter 是列表，按顺序取第一个存在的；都没装则整个模块静默跳过。
        latex = {
            enabled = true,
            converter = { "utftex", "latex2text" },
            inline = true,
            block = true,
            -- center 仅在公式渲染成单行时生效，多行会自动退化成 above。
            position = "center",
        },
    },
    keys = {
        { "<leader>mm", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown 渲染切换", ft = "markdown" },
        { "<leader>me", "<cmd>RenderMarkdown enable<cr>", desc = "Markdown 渲染开启", ft = "markdown" },
        { "<leader>md", "<cmd>RenderMarkdown disable<cr>", desc = "Markdown 渲染关闭", ft = "markdown" },
    },
}
