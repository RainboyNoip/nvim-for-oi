-- cgdb 风格的 DAP REPL 命令行（nvim-dap custom_commands 扩展点）。
--
-- REPL 的分发顺序是：内置 .命令 → custom_commands → 表达式求值，所以注册后
-- `n`/`s`/`b` 等 gdb 原名优先于变量求值；求值出口是 `p 表达式`（也支持
-- `len(s)`、`a[0]` 这类整行表达式，只要首词不是命令）。
--
-- 只注册步进/断点/只读辅助命令；`d`/`kill`/`q`/`run` 等破坏性词不占，
-- 保留给变量求值——结束会话用 <F4> / <Leader>dt，重启用 <Leader>dn。
local M = {}

local function repl_msg(msg)
  require("dap.repl").append(msg, nil, { newline = true })
end

-- 在 buffer 里找 `def name`（含 async def / PEP 695 泛型），返回函数体首行。
-- 与 pdb 的 find_function 落点一致：装饰器不计入，断在 def 的下一行，
-- 调用时才会命中；单行函数（def f(): return 1）落点不准，属已知限制。
function M.find_function_line(bufnr, name)
  local escaped = vim.pesc(name)
  local patterns = {
    "^%s*def%s+" .. escaped .. "%s*[%[(]",
    "^%s*async%s+def%s+" .. escaped .. "%s*[%[(]",
  }
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    for _, pattern in ipairs(patterns) do
      if line:match(pattern) then
        return lnum + 1
      end
    end
  end
  return nil
end

-- 解析 gdb break 语法，返回 (目标, 条件)：
--   "" | "if cond" | "file:line" | "file:line if cond" | "func" | "func if cond"
local function parse_break(args)
  args = vim.trim(args or "")
  if args == "" then
    return "", nil
  end
  if args:match("^if%s") then
    return "", vim.trim(args:sub(3))
  end
  local target, cond = args:match("^(.-)%s+if%s+(.+)$")
  if target then
    return vim.trim(target), vim.trim(cond)
  end
  return args, nil
end

local function set_breakpoint(args)
  local dap = require("dap")
  local target, cond = parse_break(args)
  if target == "" then
    dap.set_breakpoint(cond or nil)
    return
  end

  local file, lnum = target:match("^(.+):(%d+)$")
  if file then
    local bufnr = vim.fn.bufadd(vim.fn.fnamemodify(file, ":p"))
    require("dap.breakpoints").set({ condition = cond }, bufnr, tonumber(lnum))
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local line = M.find_function_line(bufnr, target)
  if not line then
    repl_msg(("No function `%s` in the current file"):format(target))
    return
  end
  require("dap.breakpoints").set({ condition = cond }, bufnr, line)
end

-- until [N]：无参跑到光标行（= F9 / run_to_cursor）；带行号先把光标放到 N。
local function run_until(args)
  local lnum = tonumber(args:match("(%d+)"))
  if lnum then
    vim.fn.cursor(lnum, 1)
  end
  require("dap").run_to_cursor()
end

-- p <表达式>：绕过命令分发直接求值。REPL 的 evaluate_handler 是 local，
-- 这里按同样逻辑渲染（简单值直接打印，容器用变量树）。
local function evaluate(args)
  if vim.trim(args) == "" then
    repl_msg("usage: p <expression>")
    return
  end
  local session = require("dap").session()
  if not session then
    repl_msg("no active debug session")
    return
  end
  local repl = require("dap.repl")
  session:evaluate({ expression = args, context = "repl" }, function(err, resp)
    if err then
      repl.append(tostring(err), nil, { newline = true })
      return
    end
    local attributes = (resp.presentationHint or {}).attributes or {}
    if resp.variablesReference > 0 or vim.tbl_contains(attributes, "rawString") then
      local ui = require("dap.ui")
      local spec = require("dap.entity").variable.tree_spec
      local tree = ui.new_tree(spec)
      local layer = ui.layer(repl.buf)
      if spec.has_children(resp) then
        spec.fetch_children(resp, function()
          tree.render(layer, resp, nil)
        end)
      else
        tree.render(layer, resp, nil)
      end
    else
      repl.append(resp.result, nil, { newline = true })
    end
  end)
end

-- display/undisplay → disp（Watches）窗口
local function display(args)
  local watches = require("dapui").elements.watches
  if vim.trim(args) == "" then
    local items = watches.get()
    if #items == 0 then
      repl_msg("no displays")
      return
    end
    for i, item in ipairs(items) do
      repl_msg(("%d: %s"):format(i, item.expression))
    end
    return
  end
  watches.add(args)
end

local function undisplay(args)
  local watches = require("dapui").elements.watches
  local index = tonumber(args)
  if not index then
    for i, item in ipairs(watches.get()) do
      if item.expression == vim.trim(args) then
        index = i
        break
      end
    end
  end
  if not index then
    repl_msg(("no display matching `%s`"):format(args))
    return
  end
  watches.remove(index)
end

local function info(args)
  if args == "locals" or args == "args" then
    -- print_scopes 是 REPL 的 local 函数，借内置命令的分发走一遍
    require("dap.repl").execute(".scopes")
  else
    repl_msg("usage: info locals")
  end
end

function M.setup(dap)
  local custom = require("dap.repl").commands.custom_commands

  -- 步进 / 运行
  custom["n"] = function() dap.step_over() end
  custom["next"] = custom["n"]
  custom["s"] = function() dap.step_into() end
  custom["step"] = custom["s"]
  custom["fin"] = function() dap.step_out() end
  custom["finish"] = custom["fin"]
  custom["c"] = function() dap.continue() end
  custom["cont"] = custom["c"]
  custom["continue"] = custom["c"]
  custom["until"] = function(args) run_until(args) end

  -- 断点
  custom["b"] = function(args) set_breakpoint(args) end
  custom["break"] = custom["b"]

  -- 求值
  custom["p"] = function(args) evaluate(args) end
  custom["print"] = custom["p"]

  -- 只读辅助
  custom["bt"] = function() require("dap.repl").print_stackframes() end
  custom["backtrace"] = custom["bt"]
  custom["where"] = custom["bt"]
  custom["locals"] = function() require("dap.repl").execute(".scopes") end
  custom["info"] = function(args) info(args) end
  custom["display"] = function(args) display(args) end
  custom["undisplay"] = function(args) undisplay(args) end
end

return M
