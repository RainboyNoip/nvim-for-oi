local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

local M = {}

-- 按非空白字符切分，保留 a[1]、foo.bar 这类整体 token。
function M.words(text)
    local result = {}
    for word in string.gmatch(text or "", "%S+") do
        table.insert(result, word)
    end
    return result
end

-- 从 LuaSnip 正则 trigger 的指定捕获组中取变量列表。
function M.capture_words(snip, index)
    return M.words(snip.captures[index])
end

-- 把指定捕获组包装成 function_node，供 fmt() 模板直接使用。
function M.capture_node(index, default)
    return f(function(_, snip)
        return snip.captures[index] or default or ""
    end, {})
end

-- 构造“第一个捕获组的变量列表 -> 转换成代码”的 snippet。
-- 适合 ci/co/all/so 这类后面跟一串 token 的触发方式。
function M.token_transform(trigger, name, desc, transform)
    return s(
        {
            trig = trigger,
            regTrig = true,
            trigEngine = "pattern",
            name = name,
            desc = desc,
        },
        f(function(_, snip)
            return transform(M.capture_words(snip, 1), snip)
        end, {})
    )
end

-- 构造“直接使用全部捕获组 -> 转换成代码”的 snippet。
-- 适合 lb a x、vi a n 这类参数位置固定的触发方式。
function M.capture_transform(trigger, name, desc, transform)
    return s(
        {
            trig = trigger,
            regTrig = true,
            trigEngine = "pattern",
            name = name,
            desc = desc,
        },
        f(function(_, snip)
            return transform(snip.captures, snip)
        end, {})
    )
end

return M
