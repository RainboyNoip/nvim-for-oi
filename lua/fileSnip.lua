local Snacks = require("snacks")
local M = {}

-- default snippet path
-- M.snippetPath = "$HOME/.config/nvim/snippets/"
M.snippetPath = vim.fn.stdpath('config') .. '/oiSnippets/'

-- 获取 snippets 列表
local function get_snippet_list()
  local handle = io.popen("find " .. M.snippetPath .. " -type f -printf '%P\\n'")
  if not handle then return {} end
  
  local snippets = {}
  for line in handle:lines() do
    table.insert(snippets, line)
  end
  handle:close()
  return snippets
end

-- 读取 snippet 内容
local function read_snippet_content(path)
  local lines = vim.fn.readfile(path)
  return lines
end

-- 插入代码片段
local function insert_code_snippet(snip_path)
	local lines = read_snippet_content(snip_path)

	-- 添加 //-- filename {{{ 和 }}} 到文件的开头和结尾
	local filename = vim.fn.fnamemodify(snip_path, ":t")
	table.insert(lines, 1, "//oisnip_begin " .. filename)
	table.insert(lines, "//oisnip_end")

	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local cur_pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(bufnr, cur_pos[1] - 1, cur_pos[1], false, lines)
	
end

function InsertSnippet()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	
	-- 使用 Snacks picker
	print(M.snippetPath)
	Snacks.picker.pick("files",{
		dirs = {M.snippetPath},
		hidden = true,
		cwd = M.snippetPath,
		prompt = "Select Snippet:",
		confirm = function(picker,item)
				picker:norm(function()
					if item then
						picker:close()
						insert_code_snippet(item.file)
						-- print("item.file", item.file)
						-- vim.api.nvim_input(item.file)
					end
				end)
				-- print("item.file", item.file)
				-- local lines = read_snippet_content(item.path)
				-- vim.api.nvim_buf_set_lines(bufnr, vim.api.nvim_win_get_cursor(winid)[1] - 1, vim.api.nvim_win_get_cursor(winid)[1], false, lines)
		end
		-- items = items,
		-- cb = function(item)
		-- 	if item and item.path then
		-- 		local lines = read_snippet_content(item.path)
		-- 		vim.api.nvim_buf_set_lines(bufnr, vim.api.nvim_win_get_cursor(winid)[1] - 1, vim.api.nvim_win_get_cursor(winid)[1], false, lines)
		-- 	end
		-- end
	})
end

function M.setup(opts)
	opts = opts or {}

	-- 设置 snippet 路径
	if opts.snippetPath then
		M.snippetPath = opts.snippetPath
	end
	print("Snippet path: %s", M.snippetPath)
	-- 设置默认的 snippet 路径
	if not M.snippetPath or M.snippetPath == "" then
		M.snippetPath = "$HOME/.config/nvim/snippets/"
	end
	-- 确保路径存在
	M.snippetPath = vim.fn.expand(M.snippetPath)
	if not vim.fn.isdirectory(M.snippetPath) then
		vim.fn.mkdir(M.snippetPath, "p")
	end
	-- 创建命令 Choose

	vim.api.nvim_create_user_command("Choose", function()
		InsertSnippet()
	end, {})

	-- 绑定快捷键 F1 所有模式
	-- vim.api.nvim_set_keymap("n", "<leader>oi", ":Choose<CR>", { noremap = true, silent = true })

	vim.keymap.set('n', '<leader>oi', ":Choose<CR>", { buffer = true, silent = true, desc = "oiSnippets" })
	-- -- 绑定快捷键 F1 insert 模式
	-- vim.api.nvim_set_keymap("i", "<F1>", "<C-o>:Choose<CR>", { noremap = true, silent = true })
	-- -- 绑定快捷键 F1 所有模式
	-- vim.api.nvim_set_keymap("n", "<F1>", ":Choose<CR>", { noremap = true, silent = true })
end

return M
