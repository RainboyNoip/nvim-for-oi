local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

-- for 循环类 snippet。
-- 这里把“正序循环”和“倒序循环”的公共模板抽成 helper，
-- 后面的不同 trigger 只负责提供变量名、左边界、右边界。

-- LuaSnip 的 fmt() 参数既可以是 text_node，也可以是 function_node。
-- 这个函数把普通字符串包装成 text_node，让 helper 同时支持固定文本和动态捕获。
local function node(value)
    if type(value) == "string" then
        return t(value)
    end
    return value
end

-- 从正则 trigger 的捕获组里取值。
-- 例如 trigger "f(%S+)%s+(%S+)" 中，capture(1) 是循环变量，capture(2) 是右边界。
local function capture(index, default)
    return f(function(_, snip)
        return snip.captures[index] or default
    end, {})
end

-- 生成形如 for(int i = 1; i <= n; ++i) 的正序循环。
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

-- 生成形如 for(int i = n; i >= 1; --i) 的倒序循环。
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
    -- f -> 默认正序循环：i 从 1 到 n。
    forward_for("f", "i", "1", "n"),

    -- lf -> 单行版本，适合临时写一条简单语句。
    s("lf",
        fmt( [[ for(int i = 1;i <= n ;++i ) {pos} ]],
        { pos = i(0) })
    ),

    -- f n -> i 从 1 到 n。
    forward_for({
        trig = "f%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, "i", "1", capture(1)),

    -- f l r -> i 从 l 到 r。
    forward_for({
        trig = "f%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, "i", capture(1), capture(2)),

    -- fj -> j 从 1 到 n。
    forward_for({
        trig = "f(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), "1", "n"),

    -- fj m -> j 从 1 到 m。
    forward_for({
        trig = "f(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), "1", capture(2)),

    -- fj l r -> j 从 l 到 r。
    forward_for({
        trig = "f(%S+)%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, capture(1), capture(2), capture(3)),

    -- rf -> 默认倒序循环：i 从 n 到 1。
    reverse_for("rf", "i", "1", "n"),

    -- rf n -> i 从 n 到 1。
    reverse_for({
        trig = "rf%s+(%S+)",
        regTrig = true,
        name = "reverse for n",
        desc = "倒序循环",
    }, "i", "1", capture(1)),

    -- rfi n -> i 从 n 到 1；变量名来自 trigger 中 rf 后面的字符。
    reverse_for({
        trig = "rf(%S+)%s+(%S+)",
        regTrig = true,
        name = "reverse for n",
        desc = "指定变量名的倒序循环",
    }, capture(1), "1", capture(2)),

    -- rfi l r -> i 从 r 到 l。
    reverse_for({
        trig = "rf(%S+)%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "reverse for range",
        desc = "指定变量名和区间的倒序循环",
    }, capture(1), capture(2), capture(3)),

    -- 2f -> 二重循环，依赖模板里的 FF 宏。
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
