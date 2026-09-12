local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

-- C++ 文件的总入口。
-- 这个文件放最基础的 C++ snippet，然后把 io/for/stl/graph/debug/algo/oth 按模块合并进来。
local snippets = {
    -- magic -> 关闭 iostream 同步，常见 OJ 读写加速模板。
    s(
        "magic",
        fmt(
            [[
            std::ios::sync_with_stdio(false);
            std::cin.tie(nullptr);
            ]],
            {}
        )
    ),

    -- main -> 最小 C++ 主函数骨架。
    s(
        "main",
        fmt(
            [[
            #include <{}>
            int main() {{
                {}

                return 0;
            }}
            ]],
            { i(1,"iostream"),i(0) }
        )
    ),
}

-- 子模块拆开维护，减少单个文件的认知负担。
vim.list_extend(snippets,require("snippets.io"))
vim.list_extend(snippets,require("snippets.for"))
vim.list_extend(snippets,require("snippets.stl"))
vim.list_extend(snippets,require("snippets.graph"))
vim.list_extend(snippets,require("snippets.debug"))
vim.list_extend(snippets,require("snippets.algo"))
vim.list_extend(snippets,require("snippets.oth"))

return snippets
