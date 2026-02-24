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
    s({trig="ln",desc="out.ln()"},t("out.ln();",""));
    -- int a,b,c;
    s(
        -- int a ,b,c;
        {
            trig = "i%s+([%w_ ]+)",
            -- trig="sc((\\S+ )*\\S+)( )?",
            regTrig = true,
            trigEngine="pattern",
            name="int a,b,c",
            desc="int a,b,c"
        },
        f( function (args,snip)
            -- print(snip.captures[1])
            local str1 = ""
            for word in string.gmatch(snip.captures[1],"%S+") do
                str1 = str1 ..  word .. ",";
            end
            return string.format('int %s;',string.sub(str1,1,-2));
        end,{})
    ),
    -- std::cin
    s(
        {
            trig = "ci%s+(%S+)",
            -- trig="sc((\\S+ )*\\S+)( )?",
            regTrig = true,
            trigEngine="pattern",
            name="std::cin >> a >> b >> c",
            desc="std::cin >> a >> b >> c"
        },
        f( function (args,snip)
            -- print(snip.captures[1])
            local str1 = ""
            for word in string.gmatch(snip.captures[1],"%S+") do
                str1 = str1 .. ' >> ' ..  word;
            end
            return string.format('std::cin%s;',str1);
        end,{})
    ),
    -- std::cout
    s(
        {
            trig = "co%s+(%S+)",
            -- trig="sc((\\S+ )*\\S+)( )?",
            regTrig = true,
            trigEngine="pattern",
            name="std::cout << a << b << c",
            desc="std::cout << a << b << c"
        },
        f( function (args,snip)
            -- print(snip.captures[1])
            local str1 = ""
            for word in string.gmatch(snip.captures[1],"%S+") do
                str1 = str1 .. ' << ' ..  word;
            end
            return string.format('std::cout%s;',str1);
        end,{})
    ),
    -- fastIo in
    s(
        {
            trig = "in%s+([%w_ ]+)",
            -- trig="sc((\\S+ )*\\S+)( )?",
            regTrig = true,
            trigEngine="pattern",
            name="in.read(a,b,c)",
            desc="in.read(a,b,c)"
        },
        f( function (args,snip)
            -- print(snip.captures[1])
            local str1 = ""
            for word in string.gmatch(snip.captures[1],"%S+") do
                str1 = str1 ..  word .. ",";
            end
            return string.format('in.read(%s);',string.sub(str1,1,-2));
        end,{})
    ),
    s(
        {
            -- sc([cl]?) : 匹配 sc, scc, scl
            --    sc     -> 捕获组1为空 -> 对应 %d
            --    scc    -> 捕获组1为c  -> 对应 %c
            --    scl    -> 捕获组1为l  -> 对应 %lld
            trig = "sc([cl]?)%s+([%w_%.%[%] ]+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "scanf_smart",
            desc = "sc->%d, scc->%c, scl->%lld"
        },
        f(function(_, snip)
            -- 获取后缀 (空, "c", 或 "l")
            local type_suffix = snip.captures[1]
            -- 获取变量列表字符串
            local input_vars = snip.captures[2]

            -- 定义后缀到格式化符的映射
            local fmt_map = {
                [""]  = "%d",
                ["c"] = "%c",
                ["l"] = "%lld"
            }

            -- 默认为 %d
            local fmt_code = fmt_map[type_suffix] or "%d"

            local fmt_str = ""
            local args_str = ""

            -- 循环拼接
            for word in string.gmatch(input_vars, "%S+") do
                fmt_str = fmt_str .. fmt_code
                args_str = args_str .. ",&" .. word
            end

            return string.format('scanf("%s"%s);', fmt_str, args_str)
        end, {})
    ),
    -- scanf, 使用 select 选择哪种类型 int, long long ,char ,string,scc
    s(
        {
            -- trig = "scc%s+([%w_. ]+)",
            trig = "trig"
            -- regTrig = true,
            -- trigEngine="pattern",
            -- name="scanf with type selection",
            -- desc="scanf with type selection (int, long long, char, string)"
        },
        c(1,{
            t"option 1",
            t"option 2",
            t"option 3",
        })
    )
}
