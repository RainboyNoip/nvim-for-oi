local M = {}
local fzf = require("fzf-lua")

-- default snippet path
M.snippetPath = "$HOME/.config/nvim/snippets/"

function InsertSnippet()
	local bufnr = vim.api.nvim_get_current_buf()
	local winid = vim.api.nvim_get_current_win()
	local fzf = require("fzf-lua")
	fzf.fzf_exec("find " .. M.snippetPath .. " -type f -printf '%P\n'", {
		prompt = "Select snippet> ",
		fzf_opts = {
			["--preview"] = "cat " .. M.snippetPath .. "{1}",
			["--preview-window"] = "right:50%",
		},
		actions = {
			["default"] = {
				-- fn = require'fzf-lua'.actions.file_edit,
				fn = function(selected)
					print("selected", selected[1])
					local fzf_winid = vim.api.nvim_get_current_win()
					if #selected > 0 then
						local path = selected[1]
						path = M.snippetPath .. path
						-- 展开 path 中的环境变量
						path = vim.fn.expand(path)
						-- print("path", path)
						local lines = vim.fn.readfile(path)
						if lines then
							-- 添加 //-- filename {{{ 和 }}} 到文件的开头和结尾
							local filename = vim.fn.fnamemodify(path, ":t")
							table.insert(lines, 1, "//-- ".. filename .." {{{")
							table.insert(lines, "//-- }}}")
							
							-- 切换回原始窗口

							vim.api.nvim_set_current_win(winid)
							-- 检查缓冲区是否可修改
							if vim.api.nvim_buf_get_option(bufnr, "modifiable") then
								local row, col = unpack(vim.api.nvim_win_get_cursor(winid))
								-- == 核心修改在这里 ==
								-- Convert 1-indexed row to 0-indexed row for nvim_buf_set_text
								local start_row = row - 1
								local start_col = col
								local end_row = start_row -- For insertion at a point, end is same as start
								local end_col = start_col -- For insertion at a point, end is same as start
								if lines then
									-- 插入文本到缓冲区
									vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, lines)
									-- 将光标移动到插入的文本最后一行末尾
									local new_row = start_row + #lines
									local last_line = lines[#lines]
									local new_col = vim.str_utfindex(last_line or "")
									vim.api.nvim_win_set_cursor(winid, { new_row, new_col })
									
									-- 对上面插入的行，执行格式化操作
									-- vim.api.nvim_command(start_row .. "," .. new_row .. "normal! =")
									-- 对上面插入的行，执行格式化操作
									local format_range_cmd = string.format("%d,%dnormal! ==", start_row, new_row)
									vim.cmd(format_range_cmd)



									-- 新建一行空行, 并将光标插入到当前空行的最开始
									vim.api.nvim_buf_set_lines(bufnr, new_row, new_row, false, { "" })
									vim.api.nvim_win_set_cursor(winid, { new_row + 1, 0 })
									-- 进入插入模式
									vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>i", true, false, true), "n", true)

								else
									print("Error: No lines to insert")
								end
							else
								print("Error: Buffer is not modifiable")
							end
						end
						-- 关闭 FZF 窗口
						if #vim.api.nvim_list_wins() > 1 then
							vim.api.nvim_win_close(fzf_winid, true)
						end
					end
				end,
				reload = true,
			},
			["ctrl-y"] = {
				fn = function(selected)
					print(selected)
					print("y hello")
				end,
			},
			["ctrl-x"] = {
				fn = function(selected)
					print("x hello")
				end,
				reload = true,
			},
		},
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
	vim.api.nvim_set_keymap("n", "<F1>", ":Choose<CR>", { noremap = true, silent = true })
	-- 绑定快捷键 F1 insert 模式
	vim.api.nvim_set_keymap("i", "<F1>", "<C-o>:Choose<CR>", { noremap = true, silent = true })
	-- 绑定快捷键 F1 所有模式
	vim.api.nvim_set_keymap("n", "<F1>", ":Choose<CR>", { noremap = true, silent = true })
end

return M
