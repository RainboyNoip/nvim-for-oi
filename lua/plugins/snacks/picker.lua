local M = {}

local function get_buffer_changes_finder()
    local change_list = vim.fn.getchangelist()
    local changes = change_list[1]
    local items = {}

    if not changes or #changes == 0 then
        return {}
    end

    for i = #changes, 1, -1 do
        local change = changes[i]
        local line_num = change.lnum
        local col_num = change.col
        local line_content = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
        local context = 5
        local start_line = math.max(0, line_num - 1 - context)
        local end_line = line_num + context
        local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
        local preview_line_num = line_num - start_line - 1

        table.insert(items, {
            value = string.format("%d, %d: %s", line_num, col_num, line_content or ""),
            lnum = line_num,
            col = col_num,
            text = line_content or "",
            loc = {
                range = {
                    start = { line = preview_line_num, character = 0 },
                    ["end"] = { line = preview_line_num, character = #(line_content or "") }
                }
            },
            preview = {
                ft = "cpp",
                loc = true,
                text = table.concat(lines, "\n"),
            }
        })
    end

    return items
end

function M.changes()
    require("snacks").picker.pick({
        items = get_buffer_changes_finder(),
        prompt = "当前文件更改",
        format = function(item)
            return { { item.text } }
        end,
        preview = "preview",
        confirm = function(picker, item)
            picker:close()
            if item then
                vim.schedule(function()
                    vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                end)
            end
        end,
    })
end

function M.keys()
    return {
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
            "<leader>sb",
            function()
                require("snacks").picker.buffers()
            end,
            desc = "snacks picker show all buffers",
            mode = { "n" },
        },
        {
            "<leader>sd",
            function()
                require("snacks").picker.diagnostics()
            end,
            desc = "Diagnostics",
        },
        {
            "<leader>sD",
            function()
                require("snacks").picker.diagnostics_buffer()
            end,
            desc = "Buffer Diagnostics",
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
                M.changes()
            end,
            desc = "列出当前文件中的更改",
            mode = { "n" },
        },
    }
end

return M
