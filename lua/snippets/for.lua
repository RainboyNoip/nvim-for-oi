local ls = require("luasnip")
local lse = require("luasnip.extras")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local rep = lse.rep 
local fmt = require("luasnip.extras.fmt").fmt



-- 常用的for循环

return {

    -- Yank to array
    -- 1d array
    -- f
    s("f",
        fmt(
        [[
            for(int i = 1;i <= n ;++i ) // i: 1->n
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
        })
    ),
    -- f n
    s({
        trig = "f%s+(%w+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    },
        fmt(
        [[
            for(int i = 1;i <= {func} ;++i ) // i: 1->{func}
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
            func = f(function(args,snip) return snip.captures[1]; end,{})
        })
    ),
    -- f 1 n
    s({
        trig = "f%s+(%w+)%s+(%w+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    },
        fmt(
        [[
            for(int i = {func1};i <= {func2} ;++i ) // i: {func1}->{func2}
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
            func1 = f(function(args,snip) return snip.captures[1]; end,{}),
            func2 = f(function(args,snip) return snip.captures[2]; end,{})
        })
    ),
    -- fj -> for(int j = 1;j <= n;++j)
    s({
        trig = "f(%w+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    },
        fmt(
        [[
            for(int {func0} = {func1};{func0} <= {func2} ;++{func0} ) // {func0}: {func1}->{func2}
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
            func0 = f(function(args,snip) return snip.captures[1]; end,{}),
            func1 = f(function(args,snip) return "1"; end,{}),
            func2 = f(function(args,snip) return "n"; end,{})
        })
    ),
    -- fi n
    s({
        trig = "f(%w+)%s+(%w+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    },
        fmt(
        [[
            for(int {func0} = {func1};{func0} <= {func2} ;++{func0} ) // {func0}: {func1}->{func2}
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
            func0 = f(function(args,snip) return snip.captures[1]; end,{}),
            func1 = f(function(args,snip) return "1"; end,{}),
            func2 = f(function(args,snip) return snip.captures[2]; end,{})
        })
    ),
    -- fi 1 10
    s({
        trig = "f(%w+)%s+(%w+)%s+(%w+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    },
        fmt(
        [[
            for(int {func0} = {func1};{func0} <= {func2} ;++{func0} ) // {func0}: {func1}->{func2}
            {{
                {pos}
            }}
        ]],
        {
            pos=i(0),
            func0 = f(function(args,snip) return snip.captures[1]; end,{}),
            func1 = f(function(args,snip) return snip.captures[2]; end,{}),
            func2 = f(function(args,snip) return snip.captures[3]; end,{})
        })
    ),
    -- 2d array
    s("2f",
        fmt(
        [[
            FF(i,n){{
                FF(j,m) {{
                    {pos}
                }}
            }}
        ]],
        {
            pos=i(0),
        })
    )
    -- 3d array


    --- 2025-5-31 我创建的动态的节点
    --- 2025-5-31 我创建的函数的节点
    -- s("for", {
    --     t("for("),
    --     t("int "),
    --     i(1, "i"),
    --     t(" = "),
    --     i(2, "0"),
    --     t("; "),
    --     rep(1),
    --     t("<="),
    --     t(""20;++i;){"),
    --     t({"","\t"}),
    --     i(0),
    --     t({"","}"}),
    -- }),
}