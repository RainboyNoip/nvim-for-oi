local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local snippets = {
    -- faster HackerRank IO
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

vim.list_extend(snippets,require("snippets.io"))
vim.list_extend(snippets,require("snippets.for"))
vim.list_extend(snippets,require("snippets.algo"))
vim.list_extend(snippets,require("snippets.oth"))

return snippets
