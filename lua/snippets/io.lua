local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local function words(text)
    local result = {}
    for word in string.gmatch(text or "", "%S+") do
        table.insert(result, word)
    end
    return result
end

local function capture_words(snip, index)
    return words(snip.captures[index])
end

local function join_prefixed(values, prefix)
    local result = ""
    for _, value in ipairs(values) do
        result = result .. prefix .. value
    end
    return result
end

local function join_csv(values)
    return table.concat(values, ",")
end

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
    s({ trig = "ln", desc = "out.ln()" }, t("out.ln();", "")),

    token_transform(
        "i%s+([%w_ ]+)",
        "int a,b,c",
        "int a,b,c",
        function(vars)
            return string.format("int %s;", join_csv(vars))
        end
    ),

    token_transform(
        "ci%s+(.+)",
        "std::cin >> a >> b >> c",
        "std::cin >> a >> b >> c",
        function(vars)
            return string.format("std::cin%s;", join_prefixed(vars, " >> "))
        end
    ),

    token_transform(
        "co%s+(.+)",
        "std::cout << a << b << c",
        "std::cout << a << b << c",
        function(vars)
            return string.format("std::cout%s;", join_prefixed(vars, " << "))
        end
    ),

    token_transform(
        "in%s+(.+)",
        "in.read(a,b,c)",
        "in.read(a,b,c)",
        function(vars)
            return string.format("in.read(%s);", join_csv(vars))
        end
    ),

    s(
        {
            trig = "sc([cl]?)%s+([%w_%.%[%] ]+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "scanf_smart",
            desc = "sc->%d, scc->%c, scl->%lld"
        },
        f(function(_, snip)
            local fmt_map = {
                [""]  = "%d",
                ["c"] = "%c",
                ["l"] = "%lld"
            }
            local fmt_code = fmt_map[snip.captures[1]] or "%d"
            local fmt_str = ""
            local args_str = ""

            for _, var in ipairs(capture_words(snip, 2)) do
                fmt_str = fmt_str .. fmt_code
                args_str = args_str .. ",&" .. var
            end

            return string.format('scanf("%s"%s);', fmt_str, args_str)
        end, {})
    )
}
