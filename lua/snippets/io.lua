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
            trig = "ci%s+([%w_ ]+)",
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
                str1 = str1 .. ' >> ' ..  word;
            end
            return string.format('std::cin%s;',str1);
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
    -- scanf
    s(
        {
            trig = "sc%s+([%w_ ]+)",
            -- trig="sc((\\S+ )*\\S+)( )?",
            regTrig = true,
            trigEngine="pattern",
            name="scanf",
            desc="scanf"
        },
        f( function (args,snip)
            -- print(snip.captures[1])
            local str1 = ""
            local str2 = ""
            for word in string.gmatch(snip.captures[1],"%S+") do
                str1 = str1 .. "%d"
                str2 = str2 .. ',&' .. word;
            end
            return string.format('scanf("%s"%s);',str1,str2);

        end,{})
    )
}
