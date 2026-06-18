local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local utils = require("snippets.utils")

local function join_csv(values)
    return table.concat(values, ",")
end

-- 调试类 snippet。
-- 这些 snippet 只调用模板里已有的 log/fenc 宏，不额外生成调试框架。
return {
    -- lg a b c -> log(a,b,c);
    utils.token_transform(
        "lg%s+(.+)",
        "log(a,b,c)",
        "调用 log 宏输出变量",
        function(vars)
            return string.format("log(%s);", join_csv(vars))
        end
    ),

    -- fe -> fenc;
    s({ trig = "fe", desc = "输出调试分隔线" }, t("fenc;")),

    -- clg a b c -> // log(a,b,c);
    utils.token_transform(
        "clg%s+(.+)",
        "// log(a,b,c)",
        "生成注释状态的 log 调试语句",
        function(vars)
            return string.format("// log(%s);", join_csv(vars))
        end
    ),

    -- lgi i a[i] -> log(i,a[i]);
    -- 这个触发只是一个更有语义的别名，方便循环里快速打点。
    utils.token_transform(
        "lgi%s+(.+)",
        "log(i,a[i])",
        "循环内 log 调试",
        function(vars)
            return string.format("log(%s);", join_csv(vars))
        end
    ),
}
