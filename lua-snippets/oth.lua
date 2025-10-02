-- 输入输出相关的 snip
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- return ?
    s(
        {
            trig = "re%s+(%S+)",
            regTrig = true,
            trigEngine="pattern",
            name="return some",
            desc="return som"
        },
        f( function (args,snip)
            return string.format('return %s;',snip.captures[1]);
        end,{})
    )
}
