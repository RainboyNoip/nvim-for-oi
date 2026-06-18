local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local utils = require("snippets.utils")

local function join_csv(values)
    return table.concat(values, ",")
end

-- 调试类 snippet。
-- lg 用来快速调用 log 宏，logdef 用来在临时代码里补完整宏定义。
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

    -- logdef -> 插入和主模板一致的 log/fenc 调试宏。
    s(
        { trig = "logdef", desc = "log/fenc 调试宏定义" },
        t({
            "// #define NO_DEBUG // switch debug",
            "#if defined(onlinejudge) || defined(ONLINE_JUDGE) || defined(NO_DEBUG)",
            "#define log(...)",
            "#define fenc",
            "#else",
            [[#define log(args...) { cout << "LINE:" << __LINE__ << " : ";string _s = #args; replace(_s.begin(), _s.end(), ',', ' '); stringstream _ss(_s); istream_iterator<string> _it(_ss); err(_it, args); }]],
            [[#define fenc cout<<"================================";]],
            "void err(istream_iterator<string> it) {}",
            "",
            "template<typename T>",
            "void err(istream_iterator<string> it, T a) {",
            [[cerr << *it << " = " << a << "\n";]],
            "}",
            "",
            "template<typename T, typename... Args>",
            "void err(istream_iterator<string> it, T a, Args... args) {",
            [[cerr << *it << " = " << a << ", ";]],
            "err(++it, args...);",
            "}",
            "#endif",
        })
    ),
}
