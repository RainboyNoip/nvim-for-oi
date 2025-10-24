import lldb
import shlex

def print_array(debugger, command, result, internal_dict):
    """
    Implements an 'arr' command to print a range of array elements.
    Usage: arr <array_name> <start_index> <end_index>
    """
    args = shlex.split(command)
    if len(args) != 3:
        result.SetError("Usage: arr <array_name> <start_index> <end_index>")
        return

    array_name = args[0]
    try:
        start_index = int(args[1])
        end_index = int(args[2])
    except ValueError:
        result.SetError("Start and end indices must be integers.")
        return
        
    if start_index > end_index:
        result.SetError("Start index cannot be greater than end index.")
        return

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
    if not frame:
        result.SetError("Invalid frame.")
        return

    output = f"Values for {array_name}[{start_index}..{end_index}]:\n"
    for i in range(start_index, end_index + 1):
        expr = f"{array_name}[{i}]"
        value = frame.EvaluateExpression(expr)
        if value.IsValid() and value.GetValue() is not None:
            output += f"  {expr} = {value.GetValue()}\n"
        else:
            error_msg = value.GetError().GetString() if value.GetError().Fail() else "invalid expression"
            output += f"  Could not evaluate '{expr}': {error_msg}\n"
            break 
            
    result.AppendMessage(output)
    result.SetStatus(lldb.eReturnStatusSuccessFinishResult)

def __lldb_init_module(debugger, internal_dict):
    debugger.HandleCommand(
        'command script add -f arr.print_array arr'
    )
    print('Custom command "arr <name> <start> <end>" loaded.')
