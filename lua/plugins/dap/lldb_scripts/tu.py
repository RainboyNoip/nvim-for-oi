import lldb

def thread_until_offset(debugger, command, result, internal_dict):
    """
    Implements a 'tu' (thread until offset) command.
    Continues execution N lines forward from the current line.
    Usage: tu <number_of_lines>
    """
    try:
        # 解析传入的参数（行数偏移量）
        offset = int(command)
    except ValueError:
        result.SetError("Invalid argument. Please provide an integer offset.")
        return

    # 获取当前线程和帧
    target = debugger.GetSelectedTarget()
    if not target:
        result.SetError("Invalid target.")
        return

    process = target.GetProcess()
    if not process:
        result.SetError("Invalid process.")
        return

    thread = process.GetSelectedThread()
    if not thread:
        result.SetError("Invalid thread.")
        return

    frame = thread.GetSelectedFrame()
    if not frame or not frame.GetLineEntry().IsValid():
        result.SetError("Cannot determine current line. No debug information?")
        return

    # 计算目标行号
    current_line = frame.GetLineEntry().GetLine()
    target_line = current_line + offset

    # 执行 lldb 命令
    command_to_run = f"thread until {target_line}"
    debugger.HandleCommand(command_to_run)
    result.SetStatus(lldb.eReturnStatusSuccessFinishResult)


# 在 LLDB 中注册这个新命令
def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        'command script add -f tu.thread_until_offset tu'
    )
    print('Custom command "tu <offset>" loaded.')