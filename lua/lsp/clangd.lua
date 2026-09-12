-- from :https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#clangd
return {
    cmd = {
        "clangd",
        -- 只为 OI 单文件服务，用不到的参数都去掉了（理由见 docs/config-optimization.md §2.1）：
        --   --background-index  本机没有 compile_commands.json，跨文件索引基本用不到
        --   --clang-tidy        每次改动都跑 readability/modernize，产生不想看的诊断
        --   iwyu               会在接受补全时往文件头插 #include，你写 OI 还得手删
        "--header-insertion=never",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    -- Filetypes to automatically attach to.
    filetypes = { 'cpp' },
    -- Sets the "workspace" to the directory where any of these files is found.
    -- Files that share a root directory will reuse the LSP server connection.
    -- Nested lists indicate equal priority, see |vim.lsp.Config|.
    --
    -- 刻意不含 ".git"（详见 docs/config-optimization.md §2.1）：实测三个文件跨两个 git
    -- 仓库 + /tmp 时，含 .git → 2 个 clangd 实例（每仓库一个）；去掉后 → 1 个（root=nil）。
    -- 注意 root 不是“落回当前目录”，而是 nil；因 clangd 定位 compile_commands.json 是
    -- 从**文件所在目录**向上找，与 workspace root 无关，所以去掉 .git 不丢工程配置。
    -- 真正的工程标记（.clangd / compile_commands.json 等）保留，真实项目的 root 不变。
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac" },

--     Diagnostics:
--   IncludeCleaner:
--     Check: Never

    init_options = {
        fallbackFlags = { '--std=c++17' },
        Diagnostics = {
            -- Suppress = { "unused-includes" },
            UnusedIncludes = "None"
        },
    },

    capabilities = {
        offsetEncoding = { "utf-8", "utf-16" },
        textDocument = {
            completion = {
                editsNearCursor = true
            }
        }
    }
}
