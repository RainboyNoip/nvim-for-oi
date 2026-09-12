local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep
local utils = require("snippets.utils")

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

  s(
    { trig = "f", desc = "for i in range(n)" },
    fmt(
      [[
      for {var} in range({stop}):
          {body}
      ]],
      {
        var = i(1, "i"),
        stop = i(2, "n"),
        body = i(0, "pass"),
      }
    )
  ),

  s(
    { trig = "fr", desc = "Half-open range loop" },
    fmt(
      [[
      for {var} in range({start}, {stop}):
          {body}
      ]],
      {
        var = i(1, "i"),
        start = i(2, "left"),
        stop = i(3, "right"),
        body = i(0, "pass"),
      }
    )
  ),

  s(
    { trig = "fri", desc = "Inclusive range loop" },
    fmt(
      [[
      for {var} in range({start}, {stop} + 1):
          {body}
      ]],
      {
        var = i(1, "i"),
        start = i(2, "left"),
        stop = i(3, "right"),
        body = i(0, "pass"),
      }
    )
  ),

  s(
    { trig = "rf", desc = "Reverse range loop" },
    fmt(
      [[
      for {var} in range({stop} - 1, -1, -1):
          {body}
      ]],
      {
        var = i(1, "i"),
        stop = i(2, "n"),
        body = i(0, "pass"),
      }
    )
  ),

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
