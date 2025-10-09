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
	local filename = vim.fn.fnamemodify(snip_path, ":t")

	local function add_fold_markers()
		table.insert(lines, 1, "//oisnip_begin" .. filename)
		table.insert(lines, "/oisnip_begin")
	end


	if filename == "simaple_template.cpp" then
		-- 替换日期
		local date = os.date("%Y-%m-%d %H:%M:%S")
		for i, line in ipairs(lines) do
			lines[i] = line:gsub("2025%-10%-02 10:34:43", date)
		end
	-- snip_path include "template"
	elseif not string.find(snip_path,"template") then
		-- 添加 //oisnip_begin filename 和 //oisnip_end 到文件的开头和结尾
		add_fold_markers()
	end


	-- 获取当前缓冲区和窗口
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local cur_pos = vim.api.nvim_win_get_cursor(0)
	-- 加入到当前行
	vim.api.nvim_buf_set_lines(bufnr, cur_pos[1] - 1, cur_pos[1], false, lines)

	-- after insert, move cursor to the end of the snippet
	-- vim.api.nvim_win_set_cursor(0, {cur_pos[1] + #lines, 0})

	if filename == "simaple_template.cpp" then
		-- fold the snippet
		vim.cmd("normal! zM")
		-- move cur_pos to function main 
		for i, line in ipairs(lines) do
			if line:find("void init") then
				vim.api.nvim_win_set_cursor(0, {i+1, 4})
				vim.cmd("normal! zz")
				-- run <c-y>
				vim.api.nvim_input("<c-y>")
				vim.api.nvim_input("<c-y>")
				break
			end
		end
	end
	
end

function InsertSnippet()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	
	-- 使用 Snacks picker
	-- print(M.snippetPath)
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
	M.snippetPath = opts.snippetPath or M.snippetPath
	-- print("Snippet path: %s", M.snippetPath)
	-- 确保路径存在
	if not vim.fn.isdirectory(M.snippetPath) then
		vim.fn.mkdir(M.snippetPath, "p")
	end
	-- 创建命令 Choose

	vim.api.nvim_create_user_command("OISnipChoose", function()
		InsertSnippet()
	end, {})

	-- 绑定快捷键 F1 所有模式
	-- vim.api.nvim_set_keymap("n", "<leader>oi", ":Choose<CR>", { noremap = true, silent = true })

	vim.keymap.set('n', '<leader>os', ":OISnipChoose<CR>", { buffer = true, silent = true, desc = "oiSnippets" })
	-- -- 绑定快捷键 F1 insert 模式
	-- vim.api.nvim_set_keymap("i", "<F1>", "<C-o>:Choose<CR>", { noremap = true, silent = true })
	-- -- 绑定快捷键 F1 所有模式
	-- vim.api.nvim_set_keymap("n", "<F1>", ":Choose<CR>", { noremap = true, silent = true })
end

return M
