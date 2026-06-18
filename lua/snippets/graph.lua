local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local utils = require("snippets.utils")

-- linklist 图论短句 snippet。
-- 这里贴合 linkList 的真实接口：e.add/e.add2 加边，e.h[u] + e[i].next 手动遍历。

return {
    -- ea u v -> e.add(u,v);
    utils.capture_transform(
        "ea%s+(%S+)%s+(%S+)",
        "e.add(u,v)",
        "linklist 有向无权加边",
        function(captures)
            return string.format("e.add(%s,%s);", captures[1], captures[2])
        end
    ),

    -- eaw u v w -> e.add(u,v,w);
    utils.capture_transform(
        "eaw%s+(%S+)%s+(%S+)%s+(%S+)",
        "e.add(u,v,w)",
        "linklist 有向带权加边",
        function(captures)
            return string.format("e.add(%s,%s,%s);", captures[1], captures[2], captures[3])
        end
    ),

    -- ea2 u v -> e.add2(u,v);
    utils.capture_transform(
        "ea2%s+(%S+)%s+(%S+)",
        "e.add2(u,v)",
        "linklist 无向无权加边",
        function(captures)
            return string.format("e.add2(%s,%s);", captures[1], captures[2])
        end
    ),

    -- ea2w u v w -> e.add2(u,v,w);
    utils.capture_transform(
        "ea2w%s+(%S+)%s+(%S+)%s+(%S+)",
        "e.add2(u,v,w)",
        "linklist 无向带权加边",
        function(captures)
            return string.format("e.add2(%s,%s,%s);", captures[1], captures[2], captures[3])
        end
    ),

    -- ef u -> 遍历 u 的所有出边，同时取 v/w。
    s(
        {
            trig = "ef%s+(%S+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "for linklist edge",
            desc = "遍历 linklist 出边",
        },
        fmt(
            [[
            for(int i = e.h[{u}]; i != -1; i = e[i].next) {{
                int v = e[i].v, w = e[i].w;
                {pos}
            }}
            ]],
            {
                u = utils.capture_node(1),
                pos = i(0),
            }
        )
    ),

    -- ee m -> 读 m 条有向无权边。
    s(
        {
            trig = "ee%s+(%S+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "read directed edges",
            desc = "读取有向无权边",
        },
        fmt(
            [[
            for(int i = 1; i <= {m}; ++i) {{
                int u, v;
                std::cin >> u >> v;
                e.add(u,v);
                {pos}
            }}
            ]],
            {
                m = utils.capture_node(1),
                pos = i(0),
            }
        )
    ),

    -- eew m -> 读 m 条有向带权边。
    s(
        {
            trig = "eew%s+(%S+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "read weighted directed edges",
            desc = "读取有向带权边",
        },
        fmt(
            [[
            for(int i = 1; i <= {m}; ++i) {{
                int u, v, w;
                std::cin >> u >> v >> w;
                e.add(u,v,w);
                {pos}
            }}
            ]],
            {
                m = utils.capture_node(1),
                pos = i(0),
            }
        )
    ),

    -- ee2 m -> 读 m 条无向无权边。
    s(
        {
            trig = "ee2%s+(%S+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "read undirected edges",
            desc = "读取无向无权边",
        },
        fmt(
            [[
            for(int i = 1; i <= {m}; ++i) {{
                int u, v;
                std::cin >> u >> v;
                e.add2(u,v);
                {pos}
            }}
            ]],
            {
                m = utils.capture_node(1),
                pos = i(0),
            }
        )
    ),

    -- ee2w m -> 读 m 条无向带权边。
    s(
        {
            trig = "ee2w%s+(%S+)",
            regTrig = true,
            trigEngine = "pattern",
            name = "read weighted undirected edges",
            desc = "读取无向带权边",
        },
        fmt(
            [[
            for(int i = 1; i <= {m}; ++i) {{
                int u, v, w;
                std::cin >> u >> v >> w;
                e.add2(u,v,w);
                {pos}
            }}
            ]],
            {
                m = utils.capture_node(1),
                pos = i(0),
            }
        )
    ),
}
