local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

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
}
