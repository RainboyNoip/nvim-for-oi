local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

-- 输入输出类 snippet。
-- 这类 trigger 通常把后面的非空 token 当成变量名列表：
--   ci a b c     -> std::cin >> a >> b >> c;
--   ci a[1] a[2] -> std::cin >> a[1] >> a[2];
-- 所以拆词统一使用 %S+，允许数组下标、成员访问等非空表达式。

-- 按非空白字符切分，保留 a[1]、foo.bar 这类整体 token。
local function words(text)
    local result = {}
    for word in string.gmatch(text or "", "%S+") do
        table.insert(result, word)
    end
    return result
end

-- 从指定捕获组中取变量列表。
local function capture_words(snip, index)
    return words(snip.captures[index])
end

-- 给每个变量加同一个前缀并拼接。
-- 用在 cin/cout：prefix 分别是 " >> " 和 " << "。
local function join_prefixed(values, prefix)
    local result = ""
    for _, value in ipairs(values) do
        result = result .. prefix .. value
    end
    return result
end

-- 逗号分隔，主要用于声明列表和 fast IO 的参数列表。
local function join_csv(values)
    return table.concat(values, ",")
end

-- 生成带默认值的声明片段，例如 a=0,b=0,c=0。
local function join_initialized(values, init_value)
    local result = {}
    for _, value in ipairs(values) do
        table.insert(result, string.format("%s=%s", value, init_value))
    end
    return table.concat(result, ",")
end

-- 构造“捕获变量列表 -> 转换成一整段代码”的 snippet。
-- trigger 负责匹配，transform 只关心变量列表如何变成最终文本。
local function token_transform(trigger, name, desc, transform)
    return s(
        {
            trig = trigger,
            regTrig = true,
            trigEngine = "pattern",
            name = name,
            desc = desc
        },
        f(function(_, snip)
            return transform(capture_words(snip, 1), snip)
        end, {})
    )
end

return {
    -- ln -> fast output 的换行。
    s({ trig = "ln", desc = "out.ln()" }, t("out.ln();", "")),

    -- i a b c -> int a,b,c;
    token_transform(
        "i%s+([%w_ ]+)",
        "int a,b,c",
        "int a,b,c",
        function(vars)
            return string.format("int %s;", join_csv(vars))
        end
    ),

    -- i0 a b c -> int a=0,b=0,c=0;
    token_transform(
        "i0%s+([%w_ ]+)",
        "int a=0,b=0,c=0",
        "int a=0,b=0,c=0",
        function(vars)
            return string.format("int %s;", join_initialized(vars, "0"))
        end
    ),

    -- ci a b c -> std::cin >> a >> b >> c;
    token_transform(
        "ci%s+(.+)",
        "std::cin >> a >> b >> c",
        "std::cin >> a >> b >> c",
        function(vars)
            return string.format("std::cin%s;", join_prefixed(vars, " >> "))
        end
    ),

    -- co a b c -> std::cout << a << b << c;
    token_transform(
        "co%s+(.+)",
        "std::cout << a << b << c",
        "std::cout << a << b << c",
        function(vars)
            return string.format("std::cout%s;", join_prefixed(vars, " << "))
        end
    ),

    -- in a b c -> in.read(a,b,c);
    token_transform(
        "in%s+(.+)",
        "in.read(a,b,c)",
        "in.read(a,b,c)",
        function(vars)
            return string.format("in.read(%s);", join_csv(vars))
        end
    ),

    -- scanf 简写：
    --   sc  a b -> scanf("%d%d",&a,&b);
    --   scc c   -> scanf("%c",&c);
    --   scl x   -> scanf("%lld",&x);
    s(
        {
            trig = "sc([cl]?)%s+([%w_%.%[%] ]+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "scanf_smart",
            desc = "sc->%d, scc->%c, scl->%lld"
        },
        f(function(_, snip)
            -- 第一个捕获组是类型后缀：空 / c / l。
            local fmt_map = {
                [""]  = "%d",
                ["c"] = "%c",
                ["l"] = "%lld"
            }
            local fmt_code = fmt_map[snip.captures[1]] or "%d"
            local fmt_str = ""
            local args_str = ""

            -- 第二个捕获组是变量列表，每个变量都要生成一个格式符和一个取地址参数。
            for _, var in ipairs(capture_words(snip, 2)) do
                fmt_str = fmt_str .. fmt_code
                args_str = args_str .. ",&" .. var
            end

            return string.format('scanf("%s"%s);', fmt_str, args_str)
        end, {})
    )
}
