-- 根据补全的snip,来添加头文件
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local events = require("luasnip.util.events")

-- line 行数
-- header_name 头文件名
function add_one_line(line,header_name)
    local name = '#include "' .. header_name .. '"'
    vim.api.nvim_buf_set_lines(0,line,line,true,{name})
end

-- 找到最后一行`#include `的行
function find_last_include_lines(header_name)
    local lines = vim.api.nvim_buf_get_lines(0,0,-1,false)
    -- print(table.concat(lines, ", "))
    local regex = '^%s*#include%s*["<](%S+)[">]'
    local last_include_line = 0
    for i,line in pairs(lines) do
        local match = line:match(regex)
        print(line,match)
        if match == header_name  then
            return nil
        end
        if line:match("^%s*#include")  then
            last_include_line = i
        end
    end
    return last_include_line
end

-- 添加对应的头文件
function add_header_file(header_name)
    local add_line_idx = find_last_include_lines(header_name)
    print("add_line_idx",add_line_idx)
    if add_line_idx ~= nil then 
        add_one_line(add_line_idx,header_name)
    end
end


return {
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
