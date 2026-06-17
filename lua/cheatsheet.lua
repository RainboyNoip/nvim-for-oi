local M = {}

local lines = {
    "Rainboy Cheat Sheet",
    "",
    "通用编辑",
    "  <C-s>              保存当前文件",
    "  <C-h/j/k/l>        在窗口间移动",
    "  <C-Up/Down>        调整窗口高度",
    "  <C-Left/Right>     调整窗口宽度",
    "  <A-Up/Down>        上下移动当前行",
    "  < / >              Visual 模式缩进并保持选区",
    "  g; / g,            跳转到上/下一个编辑位置",
    "",
    "OI / 模板入口",
    "  <leader>os         选择 oiSnippets 代码片段",
    "  <leader>of         Rbook 正式代码模板",
    "  <leader>oe         Rbook 浏览全部代码文件",
    "  <leader>op         选择复制命令并复制当前 buffer",
    "",
    "C++ buffer",
    "  <leader>;          当前行末尾补分号",
    "  <C-_>              行注释切换",
    "  <C-\\>             块注释切换",
    "",
    "LuaSnip 操作",
    "  <C-K>              展开 snippet",
    "  <C-L> / <C-J>      跳到下/上一个 snippet 节点",
    "  <C-E>              切换 choice 节点",
    "  <C-n> / <C-p>      下/上一个 choice",
    "",
    "C++ snippets",
    "  main               最小 main 模板",
    "  magic              fast iostream",
    "  f                  for i = 1..n",
    "  f n                for i = 1..n",
    "  f l r              for i = l..r",
    "  fi n               for i = 1..n",
    "  fi l r             for i = l..r",
    "  rf                 reverse for i = n..1",
    "  rf n               reverse for i = n..1",
    "  rfi n              reverse for i = n..1",
    "  rfi l r            reverse for i = r..l",
    "  2f                 双层 FF(i,n) / FF(j,m)",
    "",
    "IO snippets",
    "  i a b c            int a,b,c;",
    "  ci a b c           std::cin >> a >> b >> c;",
    "  co a b c           std::cout << a << b << c;",
    "  in a b c           in.read(a,b,c);",
    "  sc a b             scanf(\"%d%d\",&a,&b);",
    "  scc ch             scanf(\"%c\",&ch);",
    "  scl x y            scanf(\"%lld%lld\",&x,&y);",
    "  re x               return x;",
    "  linklist           linklist<maxn> e; 并自动补 include",
    "",
    "关闭",
    "  q / <Esc>          关闭此窗口",
}

local function get_window_size()
    local width = math.min(90, math.floor(vim.o.columns * 0.8))
    local height = math.min(32, math.floor(vim.o.lines * 0.7), #lines)

    return width, height
end

function M.show()
    local width, height = get_window_size()
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true
    vim.bo[bufnr].filetype = "rainboy-cheatsheet"

    local winid = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        row = math.max(row, 0),
        col = math.max(col, 0),
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " Rainboy Cheat Sheet ",
        title_pos = "center",
    })

    vim.wo[winid].wrap = false
    vim.wo[winid].cursorline = true

    local close = function()
        if vim.api.nvim_win_is_valid(winid) then
            vim.api.nvim_win_close(winid, true)
        end
    end

    vim.keymap.set("n", "q", close, { buffer = bufnr, silent = true, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = bufnr, silent = true, nowait = true })
end

return M
