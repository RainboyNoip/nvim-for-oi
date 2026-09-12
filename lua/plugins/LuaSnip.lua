return {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp",
    -- 懒加载。原来既没 lazy= 也没 ft/event，于是启动期就 require；审计时测得冷启动
    -- require("luasnip.util.jsregexp") 约 36ms，是启动开销里最大的一块。
    -- 实测收益：空启动 42.8–55.2ms → 23.0–24.4ms（约 -20ms）；代价是这部分加载
    -- 搬到了第一个 cpp/python buffer 的 FileType 事件，所以开 .cpp 的总耗时几乎不变。
    -- ft 覆盖所有真的挂了 snippet 的 filetype：lua_snippets 挂在 cpp / python，
    -- vscode-snippets 还有 c / cpp / python / markdown / haskell（各一个 json/目录）。
    ft = { "c", "cpp", "python", "markdown", "haskell" },
    -- module 是必需的保险，别删：nvim-cmp 的 config 在 InsertEnter 会显式
    -- require("luasnip")。如果那个 buffer 的 filetype 不在上面列表里（例如 .txt
    -- 临时 buffer、gitcommit），没有 module = "luasnip" 时 require 会失败，
    -- cmp 的整个 config 报错，补全在该 buffer 里彻底失效。
    module = "luasnip",
    config = function ()
        local ls = require("luasnip")

        -- snippet 源文件放在仓库根目录的 lua_snippets/snippets/，不在 Neovim 的
        -- lua/ 搜索路径里，所以要把这一层加进 package.path。
        -- 为什么 snippets/ 里又套一层：文件之间用 require("snippets.utils") 互相引用，
        -- 而 io.lua / debug.lua 与 Lua 标准库同名（直接 require("io") 会拿到标准库），
        -- 保留 snippets. 命名空间就不需要改任何一条 require。
        -- 必须在 from_lua.load 之前注入。
        local snippets_root = vim.fn.stdpath("config") .. "/lua_snippets"
        package.path = package.path .. ";" .. snippets_root .. "/?.lua"

        -- 加载 VSCode JSON snippets 和 LuaSnip Lua snippets。
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/vscode-snippets" } })
        -- paths 指向 snippets 这一层，不是 lua_snippets：from_lua 推导 filetype 的规则是
        -- 「直接子文件取文件名（cpp.lua -> cpp），嵌套更深时取 root 下第一层目录名」。
        -- 若指向 lua_snippets，所有 snippet 都会被挂到假 filetype `snippets` 上。
        require("luasnip.loaders.from_lua").load({ paths = snippets_root .. "/snippets" })
        
        -- Set up keymaps
        vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
        vim.keymap.set({ "i" }, "<C-L>", function() ls.jump(1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-J>", function() ls.jump(-1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-E>", function() if ls.choice_active() then ls.change_choice(1) end end, { silent = true })
    end
}
