local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- for 循环类 snippet。
-- 循环变量使用 mirror：展开后可以直接修改第一个 i，后面的 i 会同步变化。

-- LuaSnip 的 fmt() 参数既可以是 text_node / insert_node，也可以是 function_node。
-- 这个函数把普通字符串包装成 text_node，让 helper 同时支持固定文本和动态捕获。
local function as_node(value)
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

-- 捕获组在模板里出现多次时，需要分别创建 function_node，避免复用同一个 node 对象。
local function value_node(value)
    if type(value) == "number" then
        return capture(value)
    end
    return as_node(value)
end

-- 生成形如 for(int i = 1; i <= n; ++i) 的正序循环。
local function forward_for(trigger, left, right)
    return s(trigger,
        fmt(
        [[
            for(int {var} = {left};{var2} <= {right} ;++{var3} ) // {var4}: {left2}->{right2}
            {{
                {pos}
            }}
        ]],
        {
            var = i(1, "i"),
            var2 = rep(1),
            var3 = rep(1),
            var4 = rep(1),
            left = value_node(left),
            left2 = value_node(left),
            right = value_node(right),
            right2 = value_node(right),
            pos = i(0),
        })
    )
end

-- 生成形如 for(int i = n; i >= 1; --i) 的倒序循环。
local function reverse_for(trigger, left, right)
    return s(trigger,
        fmt(
        [[
            for(int {var} = {right};{var2} >= {left} ;--{var3} ) // {var4}: {right2}->{left2}
            {{
                {pos}
            }}
        ]],
        {
            var = i(1, "i"),
            var2 = rep(1),
            var3 = rep(1),
            var4 = rep(1),
            left = value_node(left),
            left2 = value_node(left),
            right = value_node(right),
            right2 = value_node(right),
            pos = i(0),
        })
    )
end

return {
    -- f -> 默认正序循环：i 从 1 到 n。
    forward_for("f", "1", "n"),

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
    }, "1", 1),

    -- f l r -> i 从 l 到 r。
    forward_for({
        trig = "f%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "for n",
        desc = "指定循环几次",
    }, 1, 2),

    -- rf -> 默认倒序循环：i 从 n 到 1。
    reverse_for("rf", "1", "n"),

    -- rf n -> i 从 n 到 1。
    reverse_for({
        trig = "rf%s+(%S+)",
        regTrig = true,
        name = "reverse for n",
        desc = "倒序循环",
    }, "1", 1),

    -- rf l r -> i 从 r 到 l。
    reverse_for({
        trig = "rf%s+(%S+)%s+(%S+)",
        regTrig = true,
        name = "reverse for range",
        desc = "指定区间的倒序循环",
    }, 1, 2),

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
