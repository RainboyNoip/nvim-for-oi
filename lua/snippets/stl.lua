local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

-- STL / OJ 高频短句 snippet。
-- 这里保持短触发风格，只覆盖写题中经常反复输入的小片段。

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

local function token_transform(trigger, name, desc, transform)
    return s(
        {
            trig = trigger,
            regTrig = true,
            trigEngine = "pattern",
            name = name,
            desc = desc,
        },
        f(function(_, snip)
            return transform(capture_words(snip, 1), snip)
        end, {})
    )
end

local function capture_transform(trigger, name, desc, transform)
    return s(
        {
            trig = trigger,
            regTrig = true,
            trigEngine = "pattern",
            name = name,
            desc = desc,
        },
        f(function(_, snip)
            return transform(snip.captures)
        end, {})
    )
end

return {
    token_transform(
        "all%s+(.+)",
        "a.begin(), a.end()",
        "容器 begin/end",
        function(vars)
            return string.format("%s.begin(), %s.end()", vars[1], vars[1])
        end
    ),

    token_transform(
        "so%s+(.+)",
        "sort(a.begin(), a.end());",
        "排序容器",
        function(vars)
            return string.format("sort(%s.begin(), %s.end());", vars[1], vars[1])
        end
    ),

    token_transform(
        "rs%s+(.+)",
        "reverse(a.begin(), a.end());",
        "翻转容器",
        function(vars)
            return string.format("reverse(%s.begin(), %s.end());", vars[1], vars[1])
        end
    ),

    token_transform(
        "uq%s+(.+)",
        "a.erase(unique(a.begin(), a.end()), a.end());",
        "去重容器",
        function(vars)
            return string.format("%s.erase(unique(%s.begin(), %s.end()), %s.end());", vars[1], vars[1], vars[1], vars[1])
        end
    ),

    s("pii", t("pair<int,int>")),

    capture_transform(
        "lb%s+(%S+)%s+(%S+)",
        "lower_bound(a.begin(), a.end(), x) - a.begin()",
        "lower_bound 下标",
        function(captures)
            return string.format("lower_bound(%s.begin(), %s.end(), %s) - %s.begin()", captures[1], captures[1], captures[2], captures[1])
        end
    ),

    capture_transform(
        "ub%s+(%S+)%s+(%S+)",
        "upper_bound(a.begin(), a.end(), x) - a.begin()",
        "upper_bound 下标",
        function(captures)
            return string.format("upper_bound(%s.begin(), %s.end(), %s) - %s.begin()", captures[1], captures[1], captures[2], captures[1])
        end
    ),

    capture_transform(
        "vi%s+(%S+)%s+(%S+)",
        "vector<int> a(n + 1);",
        "int vector",
        function(captures)
            return string.format("vector<int> %s(%s + 1);", captures[1], captures[2])
        end
    ),

    capture_transform(
        "vl%s+(%S+)%s+(%S+)",
        "vector<long long> a(n + 1);",
        "long long vector",
        function(captures)
            return string.format("vector<long long> %s(%s + 1);", captures[1], captures[2])
        end
    ),

    token_transform(
        "pq%s+(.+)",
        "priority_queue<int> q;",
        "大根堆",
        function(vars)
            return string.format("priority_queue<int> %s;", vars[1])
        end
    ),

    token_transform(
        "pqg%s+(.+)",
        "priority_queue<int, vector<int>, greater<int>> q;",
        "小根堆",
        function(vars)
            return string.format("priority_queue<int, vector<int>, greater<int>> %s;", vars[1])
        end
    ),
}
