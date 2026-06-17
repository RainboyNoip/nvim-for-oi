local M = {}

local cheatsheet_path = vim.fn.stdpath("config") .. "/cheatsheet.md"

local function read_cheatsheet_lines()
    if vim.fn.filereadable(cheatsheet_path) == 0 then
        vim.notify("找不到 cheat sheet: " .. cheatsheet_path, vim.log.levels.ERROR)
        return nil
    end

    return vim.fn.readfile(cheatsheet_path)
end

local function get_window_size(line_count)
    local width = math.min(100, math.floor(vim.o.columns * 0.85))
    local height = math.min(36, math.floor(vim.o.lines * 0.75), line_count)

    return width, height
end

function M.show()
    local lines = read_cheatsheet_lines()
    if not lines then
        return
    end

    local width, height = get_window_size(#lines)
    local row = math.floor((vim.o.lines - height) / 2 - 1)
    local col = math.floor((vim.o.columns - width) / 2)

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true
    vim.bo[bufnr].filetype = "markdown"

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
