-- /Users/rainboy/.config/nvim/lua/funcJump.lua

local M = {}

-- 递归函数，用于从LSP返回的符号树中提取所有函数和方法
local function get_functions_from_symbols(symbols)
  local functions = {}
  local function traverse(nodes)
    if not nodes then
      return
    end
    for _, symbol in ipairs(nodes) do
      -- 筛选出函数(Function)和方法(Method)
      if symbol.kind == vim.lsp.protocol.SymbolKind.Function or symbol.kind == vim.lsp.protocol.SymbolKind.Method then
        table.insert(functions, {
          display = symbol.name,
          -- LSP的行号是0-indexed, nvim_win_set_cursor需要1-indexed
          lnum = symbol.selectionRange.start.line + 1,
          -- LSP的列号是0-indexed, nvim_win_set_cursor也需要0-indexed
          col = symbol.selectionRange.start.character,
        })
      end
      -- 递归遍历子符号
      traverse(symbol.children)
    end
  end
  traverse(symbols)
  return functions
end

-- 主函数，用于打开函数选择器并跳转
function M.jump()
  -- 异步请求当前缓冲区(0)的文档符号
  vim.lsp.buf_request(0, 'textDocument/documentSymbol', nil, function(err, result, _, _)
    if err or not result or vim.tbl_isempty(result) then
      vim.notify("LSP: 未能获取到文件符号", vim.log.levels.WARN)
      return
    end

    local functions = get_functions_from_symbols(result)

    if vim.tbl_isempty(functions) then
        vim.notify("当前文件未找到任何函数", vim.log.levels.INFO)
        return
    end

    -- 调用 snacks.picker 来展示函数列表
    require('snacks').picker(functions, {
      title = "跳转到函数",
      on_select = function(item)
        if not item then return end
        -- 跳转到选中函数的位置
        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
        -- 将光标所在行置于屏幕中央，方便查看
        vim.api.nvim_command('normal! zz')
      end
    })
  end)
end

-- 创建一个用户命令 :FuncJump 来调用此功能
vim.api.nvim_create_user_command('FuncJump', M.jump, {
  nargs = 0,
  desc = "列出当前文件所有函数并跳转",
})

return M
