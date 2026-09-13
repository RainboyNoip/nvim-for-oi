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
    -- ft 覆盖所有真的挂了 snippet 的 filetype：lua-snippets 挂在 cpp / python，
    -- vscode-snippets 还有 c / cpp / python / markdown / haskell（各一个 json/目录）。
    ft = { "c", "cpp", "python", "markdown", "haskell" },
    -- module 是必需的保险，别删：nvim-cmp 的 config 在 InsertEnter 会显式
    -- require("luasnip")。如果那个 buffer 的 filetype 不在上面列表里（例如 .txt
    -- 临时 buffer、gitcommit），没有 module = "luasnip" 时 require 会失败，
    -- cmp 的整个 config 报错，补全在该 buffer 里彻底失效。
    module = "luasnip",
    config = function ()
        local ls = require("luasnip")

        -- 所有 snippet 资源都在 all-snippets/ 下，分成三组：
        --   lua-snippets/     LuaSnip 的 Lua 片段（cpp.lua / python.lua 两个入口）
        --   vscode-snippets/  VSCode 格式 JSON（Neovim 与 VSCode 共用）
        --   oi-snippets/      file snippet（files/）与 rbook 模板（rbook/）
        -- 三组只是归档在一起，加载机制各不相同（见 docs/adr/0001）。
        -- 归档路径集中在 lua/snippetAssets.lua，避免多处硬编码（Shotgun Surgery）。
        local assets = require("snippetAssets")
        local lua_dir = assets.luaSnippets

        -- 入口模块用 require("cpp") / require("python") 引入，
        -- 所以要把 lua-snippets 加进 package.path。
        -- 为什么保留一层命名空间：实现目录里的 utils/io/debug 这些名字和 Lua
        -- 标准库重名（直接 require("io") 会拿到标准库），require("cpp.io") 才安全。
        package.path = package.path .. ";" .. lua_dir .. "/?.lua"

        require("luasnip.loaders.from_vscode").lazy_load({ paths = { assets.vscodeSnippets } })

        -- 入口模块 cpp.lua / python.lua 各自 list_extend 了实现目录里的片段，
        -- 所以只需注册这两个。
        -- 关键：**不要**用 from_lua.load 递归扫目录 —— 它会把 cpp/ 下的实现文件
        -- 当成独立片段再加载一遍（与入口模块重复），而且 cpp/io.lua 会被挂到
        -- 假 filetype `io` 上。这是 docs/adr/0001-snippet-asset-layout.md 里
        -- 明确否掉的方案。
        for _, entry in ipairs({ "cpp", "python" }) do
            local ok, snippets = pcall(require, entry)
            if ok then
                ls.add_snippets(entry, snippets)
            else
                vim.notify(
                    ("LuaSnip: 加载入口模块 %s 失败：%s"):format(entry, tostring(snippets)),
                    vim.log.levels.ERROR
                )
            end
        end
        
        -- Set up keymaps
        vim.keymap.set({ "i" }, "<C-K>", function() ls.expand() end, { silent = true })
        -- vim.keymap.set({ "i" }, "<C-L>", function() ls.jump(1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-J>", function() ls.jump(-1) end, { silent = true })
        vim.keymap.set({ "i" }, "<C-E>", function() if ls.choice_active() then ls.change_choice(1) end end, { silent = true })
    end
}
