local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local d = ls.dynamic_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local utils = require("utils")

-- ===== for 循环的构造器（与 C++ 的 all-snippets/lua-snippets/cpp/for.lua 对齐）=====
-- 触发词、正则捕获方式、循环变量规则都刻意和 C++ 版保持一致。
--
-- 为什么用 f() 拼字符串而不是 fmt()：这里的变量名 / 上下界都来自正则捕获
-- （function_node），而 fmt() 的 "{name}" 占位符只认 insert_node，
-- 塞 function_node 会被当成字面文本。
--
-- Python 与 C++ 的差别：
--   正序：C++ 是闭区间 range(a, b + 1)；但不带显式下界的默认形态（f / lf /
--   f n / fabc）改成 range(stop)——半开、从 0 开始，符合 Python 习惯。
--   带显式下界的（f l r / fabc l r）仍保留闭区间 range(l, r + 1)，
--   因为 “从 l 到 r” 的直觉是含 r，也和 C++ 的 for i = l..r 对齐。
--   倒序：仍是 range(b, a - 1, -1)（含 a），保持与 C++ 的 i >= 1 对齐。

-- 闭区间换算：能算出数值就直接算（range(1, 11)），
-- 是变量（如 n）才保留表达式（range(1, n + 1)）。
local function plus_one(v)
  local n = tonumber(v)
  return n and tostring(n + 1) or (v .. " + 1")
end

local function minus_one(v)
  local n = tonumber(v)
  return n and tostring(n - 1) or (v .. " - 1")
end

-- 把「捕获组序号」或「字面量」解析成实际值。
-- open_start 仅正序生效：true 时省略下界，渲染成 range(stop)（半开、0-based）。
local function for_header(var, first, second, mode, open_start)
  return f(function(_, snip)
    local c = snip.captures or {}
    local function val(v)
      if type(v) == "number" then
        return c[v] or ""
      end
      return v
    end
    local var_s = val(var)
    if mode == "forward" then
      if open_start then
        return string.format("for %s in range(%s):", var_s, val(second))
      end
      return string.format("for %s in range(%s, %s):", var_s, val(first), plus_one(val(second)))
    end
    return string.format("for %s in range(%s, %s, -1):", var_s, val(second), minus_one(val(first)))
  end, {})
end

-- 把「字符串触发词」或「现成的 opts 表」统一成 s() 的第一个参数。
-- 正则触发词必须直接传 {trig=..., regTrig=true, trigEngine="pattern"}，
-- 不能再包一层 trig = ...，否则 trig 变成 table，LuaSnip 会在
-- trig_engines.lua:53 报 "attempt to concatenate a table value"；
-- 而且因为它是按定义顺序逐个试的，一个畻形 snippet 会把它后面所有 snippet 全部带崩。
local function snippet_opts(trigger, opts)
  if type(trigger) == "table" then
    -- open_start 是 forward_for 的渲染选项，不是 LuaSnip 的 snippet context
    -- 字段；透传给 s() 只会多一个未知键，先摘掉。
    local ctx = {}
    for k, v in pairs(trigger) do
      if k ~= "open_start" then
        ctx[k] = v
      end
    end
    return ctx
  end
  return {
    trig = trigger,
    regTrig = opts.regTrig or false,
    name = opts.name,
    desc = opts.desc,
  }
end

-- 正序：opts.open_start = true 时 for {var} in range({stop})（0-based 半开），
-- 否则 for {var} in range({start}, {stop} + 1)（闭区间）。
--
-- 触发词有两种传法，open_start 必须都能读到：
--   forward_for("f", "i", "1", "n", { open_start = true })  -- 字符串触发词，读第 5 参
--   forward_for({ trig = "f%s+(%S+)", ..., open_start = true }, "i", "1", 1)
--                                 -- 正则触发词，表就是 opts（此时第 5 参不存在）
local function forward_for(trigger, var, start, stop, opts)
  -- 正则触发时 opts 是 nil，真正的选项在 trigger 表里；两种情况统一到 opts 上。
  if type(trigger) == "table" then
    opts = vim.tbl_extend("keep", opts or {}, trigger)
  else
    opts = opts or {}
  end
  -- 注意：s() 的签名是 s(trigger, nodes, opts)，nodes 必须是**一个表**；
  -- 写成 s(opts, n1, n2, n3) 的话只有 n1 生效，后面会被当成 opts 丢掉。
  return s(snippet_opts(trigger, opts), {
    for_header(var, start, stop, "forward", opts.open_start),
    t({ "", "    " }),
    i(0, "pass"),
  })
end

-- 倒序：for {var} in range({stop}, {start} - 1, -1)
local function reverse_for(trigger, var, start, stop, opts)
  opts = opts or {}
  return s(snippet_opts(trigger, opts), {
    for_header(var, start, stop, "reverse"),
    t({ "", "    " }),
    i(0, "pass"),
  })
end

-- enum a / enum2 a：遍历对象和起始索引来自触发词捕获、展开后不可改；
-- 索引、值和循环体可逐字段修改。
local function enumerate_loop(trigger, items_capture, start_capture)
  return s(trigger, {
    d(1, function(_, parent)
      local captures = parent.captures or {}
      local nodes = {
        t("for "), i(1, "idx"), t(", "), i(2, "val"),
        t(" in enumerate("), t(captures[items_capture] or "a"),
      }
      if start_capture then
        -- 去掉前导零，避免 enum002 a 生成 Python 不接受的整数字面量 002。
        local start = (captures[start_capture] or "0"):gsub("^0+", "")
        vim.list_extend(nodes, { t(", "), t(start ~= "" and start or "0") })
      end
      -- sn 内的跳转编号必须从 1 连续递增，且在 snippetNode 内部局部编号；
      -- 起始值是静态 t() 文本、不占跳转槽位，所以无论有没有 start，
      -- 可跳转节点都是 idx/val/pass 三个，pass 恒为 i(3)。
      -- （写成 start_capture and 3 or 2 会在无 start 时与 i(2, "val") 撞号，
      -- 后注册的 pass 覆盖跳转表，val 永远跳不到。）最终的 i(0) 由外层片段提供。
      vim.list_extend(nodes, { t({ "):", "    " }), i(3, "pass") })
      return sn(nil, nodes)
    end, {}),
  })
end

return {
  -- main 骨架已迁移到 all-snippets/vscode-snippets/python.json（trigger 仍是 main），
  -- 由 LuaSnip 的 from_vscode 加载器注册到 python filetype，Neovim / VSCode 共用。
  s(
    { trig = "solve", desc = "solve() function" },
    fmt(
      [[
      def solve():
          {}
      ]],
      { i(0, "pass") }
    )
  ),

  s(
    { trig = "fastin", desc = "Buffered stdin" },
    t({ "import sys", "", "input = sys.stdin.buffer.readline" })
  ),

  s(
    { trig = "ii", desc = "Read one integer" },
    fmt("{} = int(input())", { i(1, "n") })
  ),

  s(
    { trig = "ints", desc = "Read multiple integers" },
    fmt("{} = map(int, input().split())", { i(1, "a, b") })
  ),

  s(
    { trig = "listi", desc = "Read an integer list" },
    fmt("{} = list(map(int, input().split()))", { i(1, "a") })
  ),

  s(
    { trig = "strin", desc = "Read and decode a string" },
    fmt("{} = input().strip().decode()", { i(1, "s") })
  ),

  -- next a b c -> a, b, c = next(data), next(data), next(data)
  --
  -- 为什么不用 utils.token_transform：它生成的是 function_node（纯静态文本），
  -- 展开后不能跳转也不能改。这里要把 data 做成可改且三处同步的字段，
  -- 所以用 dynamic_node 手写：names 从正则捕获取（不占跳转槽位），
  -- data 是内层 snippet 的 i(1) 加 rep(1) mirror。
  -- next() 的个数跟名字个数走：`next a b` -> `a, b = next(data), next(data)`。
  s(
    {
      trig = "next%s+(.+)",
      regTrig = true,
      trigEngine = "pattern",
      -- 正则触发片段的 cmp 候选 label 是原始 pattern（如 next%s+(.+)），
      -- 纯噪音；hidden = true 让 cmp_luasnip 不再列出它（展开不受影响）。
      hidden = true,
      name = "a, b, c = next(data), next(data), next(data)",
      desc = "逐个 next() 读入多个变量",
    },
    d(1, function(_, parent_snip)
      local names = utils.words(parent_snip.captures[1])
      local nodes = { t(table.concat(names, ", ") .. " = ") }
      for index in ipairs(names) do
        if index > 1 then
          table.insert(nodes, t(", "))
        end
        table.insert(nodes, t("next("))
        table.insert(nodes, index == 1 and i(1, "data") or rep(1))
        table.insert(nodes, t(")"))
      end
      return sn(nil, nodes)
    end)
  ),

  -- ===== for 循环 =====
  -- 触发词与 C++ 版一一对应，但**展开结果从本轮起不再是 1-based**：
  --   f            range(n)（0-based 半开，Python 习惯）
  --   f n          range(n)（循环 n 次）
  --   f l r        range(l, r + 1)（保留闭区间，仍与 C++ 的 i <= r 一致）
  --   fabc l r     自定义循环变量 + 区间（同上，闭区间）
  --   fabc n       自定义循环变量 + 次数（0-based 半开）
  --   fabc         自定义循环变量（0-based 半开）
  --   lf           单行，与 f 同为 0-based 半开
  --   rf / rf n / rf l r   倒序，仍 1-based（含端点），与 C++ 的 i >= 1 一致
  --
  -- 注意：原来这里有 fr / fri（半开 / 闭区间），已删。原因：它们的触发词长度
  -- 和下面的 f([%a_]+) 完全相同，LuaSnip 取最长匹配、平局时先定义的赢，
  -- 于是单打 fr 永远拿不到 for r in ...。C++ 版没有这两个，f l r 已覆盖同功能。

  -- f -> 正序默认：0-based 半开，range(n) 从 0 数到 n-1
  forward_for("f", "i", "1", "n", { desc = "for i in range(n)", open_start = true }),

  -- lf -> 单行版本（与 f 同为 0-based 半开）
  s("lf", fmt("for i in range(n): {body}", { body = i(0, "pass") })),

  -- f n -> 循环 n 次，0-based：range(10) 就是 0..9
  forward_for({
    trig = "f%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "for n",
    desc = "指定循环几次",
    open_start = true,
  }, "i", "1", 1),

  -- f l r -> i 从 l 到 r：**保留闭区间** range(l, r + 1)
  -- （显式给下界时 “到 r” 是含 r，也和 C++ 的 for i = l..r 一致）
  forward_for({
    trig = "f%s+(%S+)%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "for range",
    desc = "指定区间",
  }, "i", 1, 2),

  -- fabc l r -> 循环变量名来自 trigger：**保留闭区间** range(l, r + 1)
  forward_for({
    trig = "f([%a_]+)%s+(%S+)%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "for var range",
    desc = "指定循环变量名和区间",
  }, 1, 2, 3),

  -- fabc n -> 循环变量名来自 trigger，循环 n 次，0-based 半开
  forward_for({
    trig = "f([%a_]+)%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "for var n",
    desc = "指定循环变量名，循环 n 次",
    open_start = true,
  }, 1, "1", 2),

  -- fabc -> 循环变量名来自 trigger，0-based 半开
  forward_for({
    trig = "f([%a_]+)",
    regTrig = true,
    hidden = true,
    name = "for var",
    desc = "指定循环变量名的默认循环",
    open_start = true,
  }, 1, "1", "n"),

  -- rf -> 倒序：i 从 n 到 1
  reverse_for("rf", "i", "1", "n", { desc = "for i in range(n, 0, -1)" }),

  -- rf n -> i 从 n 到 1
  reverse_for({
    trig = "rf%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "reverse for n",
    desc = "倒序循环",
  }, "i", "1", 1),

  -- rf l r -> i 从 r 到 l
  reverse_for({
    trig = "rf%s+(%S+)%s+(%S+)",
    regTrig = true,
    hidden = true,
    name = "reverse for range",
    desc = "指定区间的倒序循环",
  }, "i", 1, 2),

  enumerate_loop({ trig = "enum", desc = "enumerate loop" }),
  enumerate_loop({
    trig = "enum%s+(%S+)",
    regTrig = true,
    hidden = true,
    desc = "enumerate 指定遍历对象",
  }, 1),
  enumerate_loop({
    trig = "enum(%d+)%s+(%S+)",
    regTrig = true,
    hidden = true,
    desc = "enumerate 指定起始索引和遍历对象",
  }, 2, 1),

  s(
    { trig = "tests", desc = "Multiple test cases" },
    fmt(
      [[
      for _ in range(int(input())):
          {}()
      ]],
      { i(1, "solve") }
    )
  ),

  s(
    { trig = "testsdata", desc = "Multiple test cases from integer iterator" },
    fmt(
      [[
      for _ in range(next(data)):
          {}(data)
      ]],
      { i(1, "solve") }
    )
  ),

  s(
    { trig = "heap", desc = "Min-heap setup" },
    fmt(
      [[
      import heapq

      {} = []
      ]],
      { i(1, "heap") }
    )
  ),

  s(
    { trig = "bisect", desc = "Bisect imports" },
    t("from bisect import bisect_left, bisect_right")
  ),

  s(
    { trig = "deque", desc = "Deque setup" },
    fmt(
      [[
      from collections import deque

      {} = deque()
      ]],
      { i(1, "queue") }
    )
  ),

  s(
    { trig = "dbg", desc = "Print to stderr" },
    fmt("print({}, file=sys.stderr)", { i(1, "value") })
  ),

  -- ===== C++ OJ snippet 的 Python 对应版本 =====
  -- 触发词与 C++ 保持一致，展开结果改成 Python 惯用写法。
  -- 与既有 Python snippet 冲突的触发词（f / rf / sc / dbg，以及已迁到 python.json 的 main）
  -- 保留既有版本，不在这里重复定义。
  -- 没有 Python 对应物的 C++ snippet（scanf / magic / linklist / logdef / pii / all / in / ln / 2f 等）不迁移。

  -- i0 a b c -> a = b = c = 0
  utils.token_transform(
    "i0%s+([%w_ ]+)",
    "a = b = c = 0",
    "多个变量同时初始化为 0",
    function(vars)
      return table.concat(vars, " = ") .. " = 0"
    end
  ),

  -- ci a b c -> a, b, c = map(int, input().split())
  utils.token_transform(
    "ci%s+(.+)",
    "a, b, c = map(int, input().split())",
    "读取一行多个整数",
    function(vars)
      return string.format("%s = map(int, input().split())", table.concat(vars, ", "))
    end
  ),

  -- co a b c -> print(a, b, c)
  utils.token_transform(
    "co%s+(.+)",
    "print(a, b, c)",
    "输出多个值",
    function(vars)
      return string.format("print(%s)", table.concat(vars, ", "))
    end
  ),

  -- lg a b c -> print(a, b, c, file=sys.stderr)
  utils.token_transform(
    "lg%s+(.+)",
    "print(a, b, c, file=sys.stderr)",
    "调试输出到 stderr",
    function(vars)
      return string.format("print(%s, file=sys.stderr)", table.concat(vars, ", "))
    end
  ),

  -- so a -> a.sort()
  utils.token_transform(
    "so%s+(.+)",
    "a.sort()",
    "原地排序列表",
    function(vars)
      return string.format("%s.sort()", vars[1])
    end
  ),

  -- rs a -> a.reverse()
  utils.token_transform(
    "rs%s+(.+)",
    "a.reverse()",
    "原地翻转列表",
    function(vars)
      return string.format("%s.reverse()", vars[1])
    end
  ),

  -- uq a -> a = sorted(set(a))
  utils.token_transform(
    "uq%s+(.+)",
    "a = sorted(set(a))",
    "排序去重",
    function(vars)
      return string.format("%s = sorted(set(%s))", vars[1], vars[1])
    end
  ),

  -- pq q -> q = []
  utils.token_transform(
    "pq%s+(.+)",
    "q = []",
    "堆（配合 heapq，最小堆）",
    function(vars)
      return string.format("%s = []", vars[1])
    end
  ),

  -- pqg q -> q = []
  utils.token_transform(
    "pqg%s+(.+)",
    "q = []",
    "堆（配合 heapq，最小堆）",
    function(vars)
      return string.format("%s = []", vars[1])
    end
  ),

  -- lb a x -> bisect_left(a, x)
  utils.capture_transform(
    "lb%s+(%S+)%s+(%S+)",
    "bisect_left(a, x)",
    "二分下界",
    function(captures)
      return string.format("bisect_left(%s, %s)", captures[1], captures[2])
    end
  ),

  -- ub a x -> bisect_right(a, x)
  utils.capture_transform(
    "ub%s+(%S+)%s+(%S+)",
    "bisect_right(a, x)",
    "二分上界",
    function(captures)
      return string.format("bisect_right(%s, %s)", captures[1], captures[2])
    end
  ),

  -- vi a n -> a = [0] * (n + 1)
  utils.capture_transform(
    "vi%s+(%S+)%s+(%S+)",
    "a = [0] * (n + 1)",
    "一维 int 数组",
    function(captures)
      return string.format("%s = [0] * (%s + 1)", captures[1], captures[2])
    end
  ),

  -- vl a n -> a = [0] * (n + 1)
  utils.capture_transform(
    "vl%s+(%S+)%s+(%S+)",
    "a = [0] * (n + 1)",
    "一维整数数组",
    function(captures)
      return string.format("%s = [0] * (%s + 1)", captures[1], captures[2])
    end
  ),

  -- re x -> return x
  utils.capture_transform(
    "re%s+(%S+)",
    "return x",
    "返回",
    function(captures)
      return string.format("return %s", captures[1])
    end
  ),

  -- ef u -> 遍历邻接表 g[u]，同时取 v/w。
  s(
    {
      trig = "ef%s+(%S+)",
      regTrig = true,
      trigEngine = "pattern",
      hidden = true,
      name = "for adjacency list",
      desc = "遍历邻接表出边",
    },
    fmt(
      [[
      for v, w in g[{u}]:
          {body}
      ]],
      {
        u = utils.capture_node(1),
        body = i(0, "pass"),
      }
    )
  ),

  -- ee m -> 读 m 条有向无权边。
  s(
    {
      trig = "ee%s+(%S+)",
      regTrig = true,
      trigEngine = "pattern",
      hidden = true,
      name = "read directed edges",
      desc = "读取有向无权边",
    },
    fmt(
      [[
      for _ in range({m}):
          u, v = map(int, input().split())
          g[u].append(v)
          {body}
      ]],
      {
        m = utils.capture_node(1),
        body = i(0, "pass"),
      }
    )
  ),

  -- eew m -> 读 m 条有向带权边。
  s(
    {
      trig = "eew%s+(%S+)",
      regTrig = true,
      trigEngine = "pattern",
      hidden = true,
      name = "read weighted directed edges",
      desc = "读取有向带权边",
    },
    fmt(
      [[
      for _ in range({m}):
          u, v, w = map(int, input().split())
          g[u].append((v, w))
          {body}
      ]],
      {
        m = utils.capture_node(1),
        body = i(0, "pass"),
      }
    )
  ),

  -- ee2 m -> 读 m 条无向无权边。
  s(
    {
      trig = "ee2%s+(%S+)",
      regTrig = true,
      trigEngine = "pattern",
      hidden = true,
      name = "read undirected edges",
      desc = "读取无向无权边",
    },
    fmt(
      [[
      for _ in range({m}):
          u, v = map(int, input().split())
          g[u].append(v)
          g[v].append(u)
          {body}
      ]],
      {
        m = utils.capture_node(1),
        body = i(0, "pass"),
      }
    )
  ),

  -- ee2w m -> 读 m 条无向带权边。
  s(
    {
      trig = "ee2w%s+(%S+)",
      regTrig = true,
      trigEngine = "pattern",
      hidden = true,
      name = "read weighted undirected edges",
      desc = "读取无向带权边",
    },
    fmt(
      [[
      for _ in range({m}):
          u, v, w = map(int, input().split())
          g[u].append((v, w))
          g[v].append((u, w))
          {body}
      ]],
      {
        m = utils.capture_node(1),
        body = i(0, "pass"),
      }
    )
  ),
}
