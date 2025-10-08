-- from :https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#clangd
return {
    cmd = { 'clangd' },
    -- Filetypes to automatically attach to.
    filetypes = { 'cpp' },
    -- Sets the "workspace" to the directory where any of these files is found.
    -- Files that share a root directory will reuse the LSP server connection.
    -- Nested lists indicate equal priority, see |vim.lsp.Config|.
    root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },

    init_options = {
        fallbackFlags = { '--std=c++17' },
        Diagnostics = {
            Suppress = { "unused-includes" },
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
