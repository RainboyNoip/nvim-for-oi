local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local utils = require("snippets.utils")

-- ===== for 循环的构造器（与 C++ 的 lua_snippets/snippets/for.lua 对齐）=====
-- 触发词、正则捕获方式、循环变量规则都刻意和 C++ 版保持一致。
--
-- 为什么用 f() 拼字符串而不是 fmt()：这里的变量名 / 上下界都来自正则捕获
-- （function_node），而 fmt() 的 "{name}" 占位符只认 insert_node，
-- 塞 function_node 会被当成字面文本。
--
-- Python 与 C++ 的差别：Python 区间是闭区间，所以正序生成 range(a, b + 1)，
-- 倒序生成 range(b, a - 1, -1)。

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
local function for_header(var, first, second, mode)
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
    return trigger
  end
  return {
    trig = trigger,
    regTrig = opts.regTrig or false,
    name = opts.name,
    desc = opts.desc,
  }
end

-- 正序：for {var} in range({start}, {stop} + 1)
local function forward_for(trigger, var, start, stop, opts)
  opts = opts or {}
  -- 注意：s() 的签名是 s(trigger, nodes, opts)，nodes 必须是**一个表**；
  -- 写成 s(opts, n1, n2, n3) 的话只有 n1 生效，后面会被当成 opts 丢掉。
  return s(snippet_opts(trigger, opts), {
    for_header(var, start, stop, "forward"),
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

return {
  s(
    { trig = "main", desc = "Python OJ main skeleton" },
    fmt(
      [[
      import sys

      input = sys.stdin.buffer.readline


      def {name}():
          {body}


      if __name__ == "__main__":
          {name_call}()
      ]],
      {
        name = i(1, "solve"),
        body = i(0, "pass"),
        name_call = rep(1),
      }
    )
  ),

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

  -- ===== for 循环 =====
  -- 与 C++ 版一一对应：
  --   f            正序 i 从 1 到 n
  --   f n          上界来自输入
  --   f l r        指定区间
  --   fabc l r     自定义循环变量 + 区间
  --   fabc n       自定义循环变量 + 上界
  --   fabc         自定义循环变量
  --   lf           单行
  --   rf / rf n / rf l r   倒序版本
  --
  -- 注意：原来这里有 fr / fri（半开 / 闭区间），已删。原因：它们的触发词长度
  -- 和下面的 f([%a_]+) 完全相同，LuaSnip 取最长匹配、平局时先定义的赢，
  -- 于是单打 fr 永远拿不到 for r in ...。C++ 版没有这两个，f l r 已覆盖同功能。

  -- f -> 正序：i 从 1 到 n
  forward_for("f", "i", "1", "n", { desc = "for i in range(1, n + 1)" }),

  -- lf -> 单行版本
  s("lf", fmt("for i in range(1, n + 1): {body}", { body = i(0, "pass") })),

  -- f n -> i 从 1 到 n
  forward_for({
    trig = "f%s+(%S+)",
    regTrig = true,
    name = "for n",
    desc = "指定循环几次",
  }, "i", "1", 1),

  -- f l r -> i 从 l 到 r
  forward_for({
    trig = "f%s+(%S+)%s+(%S+)",
    regTrig = true,
    name = "for range",
    desc = "指定区间",
  }, "i", 1, 2),

  -- fabc l r -> 循环变量名来自 trigger
  forward_for({
    trig = "f([%a_]+)%s+(%S+)%s+(%S+)",
    regTrig = true,
    name = "for var range",
    desc = "指定循环变量名和区间",
  }, 1, 2, 3),

  -- fabc n -> 循环变量名来自 trigger，i 从 1 到 n
  forward_for({
    trig = "f([%a_]+)%s+(%S+)",
    regTrig = true,
    name = "for var n",
    desc = "指定循环变量名，循环 n 次",
  }, 1, "1", 2),

  -- fabc -> 循环变量名来自 trigger
  forward_for({
    trig = "f([%a_]+)",
    regTrig = true,
    name = "for var",
    desc = "指定循环变量名的默认循环",
  }, 1, "1", "n"),

  -- rf -> 倒序：i 从 n 到 1
  reverse_for("rf", "i", "1", "n", { desc = "for i in range(n, 0, -1)" }),

  -- rf n -> i 从 n 到 1
  reverse_for({
    trig = "rf%s+(%S+)",
    regTrig = true,
    name = "reverse for n",
    desc = "倒序循环",
  }, "i", "1", 1),

  -- rf l r -> i 从 r 到 l
  reverse_for({
    trig = "rf%s+(%S+)%s+(%S+)",
    regTrig = true,
    name = "reverse for range",
    desc = "指定区间的倒序循环",
  }, "i", 1, 2),

  s(
    { trig = "enum", desc = "enumerate loop" },
    fmt(
      [[
      for {index}, {value} in enumerate({items}):
          {body}
      ]],
      {
        index = i(1, "index"),
        value = i(2, "value"),
        items = i(3, "items"),
        body = i(0, "pass"),
      }
    )
  ),

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
  -- 与既有 Python snippet 冲突的触发词（f / rf / sc / main / dbg）保留既有版本，不在这里重复定义。
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
