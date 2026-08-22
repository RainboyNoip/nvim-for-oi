--[==[
local macos_config = require("plugins.dap.macos")
local linux_config = require("plugins.dap.linux")

if vim.fn.has("macunix") == 1 then
    return macos_config
elseif vim.fn.has("unix") == 1 then
    return linux_config
else
    print("Unsupported operating system")
    return {}
end
]==]

-- DAP 已暂时禁用 (2026-08-22)：改用终端 cgdb/gdbgui。恢复调试时解开上面的块注释即可。
return {}
