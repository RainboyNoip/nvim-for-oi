-- 这是一个自定义的 finder 函数，它会生成 picker 的项目列表
local function get_buffer_changes_finder()
    -- vim.fn.getchangelist() 返回一个包含两个元素的列表：
    -- 1. 一个列表，其中每个元素是一个更改点 {lnum, col, coladd}
    -- 2. 当前列表中的索引位置（类似于 g; 和 g, 的当前位置）
    local change_list = vim.fn.getchangelist()
    local changes = change_list[1]
    local items = {}

    if not changes or #changes == 0 then
        return {}
    end

    -- 从后往前遍历，这样最新的更改会显示在列表的顶部
    for i = #changes, 1, -1 do
        local change = changes[i]
        local line_num = change.lnum
        local col_num = change.col

        -- 获取该行的内容
        local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

        -- line_num
        -- local lnum = item.lnum
        local context = 5 -- 上下文显示的行数

        -- 计算起始和结束行号，确保不越界
        local start_line = math.max(0, line_num - 1 - context)
        local end_line = line_num + context

        -- 从当前缓冲区(0)获取指定范围的行
        local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
        local preview_line_num = line_num - start_line-1 -- 不知道为什要 -1

        table.insert(items, {
            value = string.format("%d, %d: %s", line_num, col_num, line_content or ""),
            lnum = line_num,
            col = col_num,
            text = line_content or "",
            -- 显示高亮的行
            --   loc = { range = { start = { line = line_num - 1, character = 0 }, ["end"] = { line = line_num - 1, character = #line_content } } },
            loc = {
                range = {
                start = { line = preview_line_num, character = 0 },
                -- ["end"] = { line = preview_line_num, character = #line_content-1 }
                ["end"] = { line = preview_line_num, character = #line_content }
            } },
            -- range = { start = { line = line_num - 1, character = 0 }, ["end"] = { line = line_num - 1, character = #line_content } },
            preview = {
                ft = "cpp",
                loc = true, -- 启用定位功能
                text = table.concat(lines, "\n"),
            }

        })
    end

    return items
end

return {
    "folke/snacks.nvim",
    ---@type snacks.Config
    lazy = false,
    priority = 1001,
    opts = {
        dashboard = require("plugins.snacks.dashboard"),
        -- 默认配置 的 explorer
        explorer = {}, 
        zen = {},
        notifier = { timeout = 5000 }, -- 替代 vim.notify
        terminal = {
            win = {
                position = "float", -- 默认浮动
                width = 0.8,        -- 宽度 80%
                height = 0.7,       -- 高度 70%
                border = "rounded", -- 圆角边框
                wo = {
                    winblend = 10,  -- 窗口透明度
                }
            },
            interactive = true,
            auto_insert = true,
            auto_close = false, -- 保持终端打开
        },
        styles = {
            zen = {
                backdrop = {
                    transparent = false,
                    blend = 90,
                }
            }
        }
    },
    keys = {
        -- toggle explorer
        {
            "<leader>e",
            function()
                require("snacks").explorer()
            end,
            desc = "Toggle Snacks Explorer",
        },
        {
            "<leader>t",
            group = "Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tt",
            function()
                require("snacks.terminal").toggle()
            end,
            desc = "Toggle Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tc",
            function()
                require("plugins.snacks.terminal").select_toggle()
            end,
            desc = "Select Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>tf",
            function()
                require("snacks.terminal").get("bash",{auto_close = false})
            end,
            desc = "Open Snacks Terminal",
            mode = { "n", "t" },
        },
        {
            "<leader>ts",
            function()
                print(#require("snacks.terminal").list())
            end,
            desc = "print terminal list size",
            mode = { "n", "t" },
        },
        {
            "<leader>sf",
            function()
                require("snacks").picker.lsp_symbols({
                    filter = {
                        cpp = {
                            "Function",
                            "Method",
                            "Variable",
                            "Struct"
                        }
                    }
                })
            end,
            desc = "snacks picker lsp show all functions",
            mode = { "n" },
        },
        {
            "<leader>sj",
            function()
                require("snacks").picker.jumps()
            end,
            desc = "snacks picker show vim jumps",
            mode = { "n" },
        },
        {
            "<leader>sj",
            function()
                require("snacks").picker.buffers()
            end,
            desc = "snacks picker show all buffers",
            mode = { "n" },
        },
        {
            "<leader>sz",
            function()
                require("snacks").zen.zen()
            end,
            desc = "zen mode",
            mode = { "n" },
        },
        {
            "<leader>sc",
            function()
                local items_to_show = get_buffer_changes_finder()
                require("snacks").picker.pick({
                    items = items_to_show,
                    prompt = "当前文件更改",

                    -- snacks.nvim 内部的 list.lua 文件接收到这个返回值，并将其传递给 Snacks.picker.highlight.resolve 函数（在 list.lua 的第485行）。
                    format = function(item)
                        -- return {{ item.text ,"Comment" }}
                        return { { item.text } }
                    end,
                    preview = "preview", -- 使用内置的预览功能
                    confirm = function(picker, item)
                        -- 当用户选择一个项目时，将光标移动到该位置
                        -- print(vim.inspect(item))
                        picker:close()
                        if item then
                            vim.schedule(function()
                                -- vim.cmd("colorscheme " .. item.text)
                                vim.api.nvim_win_set_cursor(0, { item.lnum, item.col-1 })
                            end)
                        end
                        -- vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
                        -- 或者使用 picker 来执行其他操作
                        -- picker:close()
                        -- 或者执行其他操作
                        -- print("Selected item:", item.value)
                        -- vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
                    end,
                })
            end,
            desc = "列出当前文件中的更改",
            mode = { "n" },
        }
    }
}
