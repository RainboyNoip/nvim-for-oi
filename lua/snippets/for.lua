local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function node(value)
    if type(value) == "string" then
        return t(value)
    end
    return value
end

local function capture(index, default)
    return f(function(_, snip)
        return snip.captures[index] or default
    end, {})
end

local function forward_for(trigger, var, left, right)
    return s(trigger,
        fmt(
        [[
            for(int {var} = {left};{var} <= {right} ;++{var} ) // {var}: {left}->{right}
            {{
                {pos}
            }}
        ]],
        {
            var = node(var),
            left = node(left),
            right = node(right),
            pos = i(0),
        })
    )
end

local function reverse_for(trigger, var, left, right)
    return s(trigger,
        fmt(
        [[
            for(int {var} = {right};{var} >= {left} ;--{var} ) // {var}: {right}->{left}
            {{
                {pos}
            }}
        ]],
        {
            var = node(var),
            left = node(left),
            right = node(right),
            pos = i(0),
        })
    )
end

return {
    forward_for("f", "i", "1", "n"),

    s("lf",
        fmt( [[ for(int i = 1;i <= n ;++i ) {pos} ]],
        { pos = i(0) })
    ),

    forward_for({
        trig = "f%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, "i", "1", capture(1)),

    forward_for({
        trig = "f%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, "i", capture(1), capture(2)),

    forward_for({
        trig = "f(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), "1", "n"),

    forward_for({
        trig = "f(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), "1", capture(2)),

    forward_for({
        trig = "f(%S+)%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), capture(2), capture(3)),

    reverse_for("rf", "i", "1", "n"),

    reverse_for({
        trig = "rf%s+(%S+)",
        regTrig = true,
        name = "reverse for n",
        desc = "倒序循环",
    }, "i", "1", capture(1)),

    reverse_for({
        trig = "rf(%S+)%s+(%S+)",
        regTrig = true,
        name = "reverse for n",
        desc = "指定变量名的倒序循环",
    }, capture(1), "1", capture(2)),

    reverse_for({
        trig = "rf(%S+)%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "reverse for range",
        desc = "指定变量名和区间的倒序循环",
    }, capture(1), capture(2), capture(3)),

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
            pos = i(0),
        })
    )
}
