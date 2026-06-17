local Snacks = require("snacks")
local M = {}

M.snippetPath = vim.fn.stdpath('config') .. '/oiSnippets/'

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
		table.insert(lines, "//oisnip_end")
	end

	if filename == "simaple_template.cpp" then
		local date = os.date("%Y-%m-%d %H:%M:%S")
		for i, line in ipairs(lines) do
			lines[i] = line:gsub("2025%-10%-02 10:34:43", date)
		end
	elseif not string.find(snip_path,"template") then
		add_fold_markers()
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local cur_pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(bufnr, cur_pos[1] - 1, cur_pos[1], false, lines)

	if filename == "simaple_template.cpp" then
		vim.cmd("normal! zM")
		for i, line in ipairs(lines) do
			if line:find("void init") then
				vim.api.nvim_win_set_cursor(0, {i+1, 4})
				vim.cmd("normal! zz")
				vim.api.nvim_input("<c-y>")
				vim.api.nvim_input("<c-y>")
				break
			end
		end
	end
	
end

local function insert_snippet()
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
					end
				end)
		end
	})
end

function M.setup(opts)
	opts = opts or {}

	-- 设置 snippet 路径
	M.snippetPath = opts.snippetPath or M.snippetPath
	-- 确保路径存在
	if not vim.fn.isdirectory(M.snippetPath) then
		vim.fn.mkdir(M.snippetPath, "p")
	end

	vim.api.nvim_create_user_command("OISnipChoose", function()
		insert_snippet()
	end, {})

	vim.keymap.set('n', '<leader>os', ":OISnipChoose<CR>", { buffer = true, silent = true, desc = "oiSnippets" })

	-- rbook.nvim 的代码模板入口。旧的 OICodeSnip 命令已经被 RbookCode/RbookCodeFiles 替代。
	vim.keymap.set('n', '<leader>oe', ":RbookCodeFiles<CR>", { buffer = true, silent = true, desc = "Rbook 浏览全部代码文件" })

	vim.keymap.set('n', '<leader>of', ":RbookCode<CR>", { buffer = true, silent = true, desc = "Rbook 正式代码模板" })
end

return M
