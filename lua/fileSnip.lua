local Snacks = require("snacks")
local assets = require("snippetAssets")
local M = {}

-- file snippet（选一个文件、把内容插入当前 buffer）的默认目录。
-- 可用 fileSnip.setup({ snippetPath = "..." }) 覆盖。
M.snippetPath = assets.fileSnippets .. "/"

-- 读取 snippet 内容
local function read_snippet_content(path)
  local lines = vim.fn.readfile(path)
  return lines
end

-- 判断一个 snippet 文件是「模板」还是「工具」。
--
-- 约定：**直接放在 snippet 根目录下的 = 模板**（整份可直接用的骨架，插入时不加折叠标记）；
-- **放在子目录里的 = 工具**（可复用代码块，插入时加 //oisnip 标记方便折叠）。
--
-- 为什么这样写（review P1）：
--   旧代码用 `string.find(path, "template")`，那是 template/ 目录时代的写法；
--   上一版改成硬编码匹配 `/files/`，一旦用户用
--   fileSnip.setup({ snippetPath = ... }) 指向别的目录（ADR 明确要求保留的覆盖入口），
--   所有文件都不匹配，模板就会被错误加上折叠标记。
--   现在改为相对于**已配置的 snippetPath** 判断，与字面目录名无关，覆盖也照样生效。
--
-- 不用“文件里有没有 main”来判断：utils/random*.cpp 这些工具本身就是完整程序，
-- 也有 int main，按内容判断会把它们误判成模板而丢掉折叠标记。
local function is_template(snip_path)
  local root = vim.fn.fnamemodify(M.snippetPath or "", ":p"):gsub("/+$", "")
  local path = vim.fn.fnamemodify(snip_path or "", ":p"):gsub("/+$", "")
  if root == "" or path == "" then
    return false
  end
  local prefix = root .. "/"
  if path:sub(1, #prefix) ~= prefix then
    return false
  end
  local rel = path:sub(#prefix + 1)
  if rel == "" then
    return false
  end
  return not rel:find("/")
end

-- 插入代码片段
local function insert_code_snippet(snip_path)
	local lines = read_snippet_content(snip_path)
	local filename = vim.fn.fnamemodify(snip_path, ":t")

	local function add_fold_markers()
		table.insert(lines, 1, "//oisnip_begin" .. filename)
		table.insert(lines, "//oisnip_end")
	end

	if filename == "simple_template.cpp" then
		local date = os.date("%Y-%m-%d %H:%M:%S")
		for i, line in ipairs(lines) do
			lines[i] = line:gsub("2025%-10%-02 10:34:43", date)
		end
	elseif not is_template(snip_path) then
		add_fold_markers()
	end

	local bufnr = vim.api.nvim_get_current_buf()
	local cur_pos = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_buf_set_lines(bufnr, cur_pos[1] - 1, cur_pos[1], false, lines)

	if filename == "simple_template.cpp" then
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
		-- Python 的 file snippet 是指向 rbook canonical 模板的 symlink。
		follow = true,
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

	-- 这些键必须全局绑定：setup() 只在启动时执行一次，`buffer = true` 会把它
	-- 绑到当时的 current buffer，导致打开第二个文件后键消失。
	-- 插入目标由 insert_code_snippet() 里的 nvim_get_current_buf() 决定，安全。
	vim.keymap.set('n', '<leader>os', "<cmd>OISnipChoose<cr>", { silent = true, desc = "file snippets" })

	-- rbook.nvim 的代码模板入口。旧的 OICodeSnip 命令已经被 RbookCode/RbookCodeFiles 替代。
	vim.keymap.set('n', '<leader>oe', "<cmd>RbookCodeFiles<cr>", { silent = true, desc = "Rbook 浏览代码文件（按当前语言）" })

	vim.keymap.set('n', '<leader>of', "<cmd>RbookCode<cr>", { silent = true, desc = "Rbook 正式代码模板（按当前语言）" })
end

return M
