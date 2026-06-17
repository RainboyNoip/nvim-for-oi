-- 算法模板类 snippet。
-- 当前主要处理：展开某些数据结构 snippet 时，自动补上对应的本地头文件。
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local events = require("luasnip.util.events")

-- 在指定行插入一条 #include "xxx"。
-- line 使用 nvim_buf_set_lines 的 0-based 插入位置。
local function add_one_line(line,header_name)
    local name = '#include "' .. header_name .. '"'
    vim.api.nvim_buf_set_lines(0,line,line,true,{name})
end

-- 找到最后一条 #include 的位置。
-- 如果目标头文件已经存在，返回 nil，避免重复插入。
local function find_last_include_lines(header_name)
    local lines = vim.api.nvim_buf_get_lines(0,0,-1,false)
    local regex = '^%s*#include%s*["<](%S+)[">]'
    local last_include_line = 0
    for i,line in pairs(lines) do
        local match = line:match(regex)
        if match == header_name  then
            return nil
        end
        if line:match("^%s*#include")  then
            last_include_line = i
        end
    end
    return last_include_line
end

-- 把目标头文件插到当前 include 区域末尾。
local function add_header_file(header_name)
    local add_line_idx = find_last_include_lines(header_name)
    if add_line_idx ~= nil then 
        add_one_line(add_line_idx,header_name)
    end
end


return {
    -- linklist -> 生成链式前向星对象，并自动 include 本地 linklist 头文件。
    s("linklist",{t("linklist<maxn> e;")},
        {
            callbacks = {
                [-1] = {
                    [events.enter] = function(node, _event_args) add_header_file("graph/linklist.hpp") end
                }
            }
        }
    )
}
