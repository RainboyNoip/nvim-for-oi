#!/usr/bin/env bash

# ==============================================================================
# lldb-run.sh
#
# A wrapper script to launch LLDB with an interactively selected input file.
# It finds files containing "in" in the current directory, prompts the user
# to choose one using 'gum', and then starts the lldb session.
#
# Dependencies: gum, lldb
# Usage: ./lldb-run.sh <path_to_your_executable>
# ==============================================================================

# --- Dependency Check ---
# 确保 gum 命令存在
if ! command -v gum &> /dev/null; then
    echo "Error: 'gum' is not installed or not in your PATH."
    echo "Please install it to use this script (e.g., 'brew install gum')."
    exit 1
fi

# 确保 lldb 命令存在
if ! command -v lldb &> /dev/null; then
    echo "Error: 'lldb' is not installed or not in your PATH."
    exit 1
fi

# --- Argument Check ---
# 检查用户是否提供了可执行文件作为第一个参数
if [ -z "$1" ]; then
    echo "Error: Please provide an executable file as an argument."
    # $(basename "$0") 会自动显示脚本自己的名字
    echo "Usage: $(basename "$0") ./your_program"
    exit 1
fi

# 将第一个参数存入变量, 方便阅读
executable="$1"

# --- Main Logic ---
# 声明一个变量来存储用户选择的文件
selected_file=""

# 1. find: 查找当前目录下的文件 (最大深度为1, 类型为文件-f)
# 2. grep: 筛选出文件名包含 'in' 的
# 3. sed:  去掉 './' 前缀, 使显示更美观
# 4. gum filter: 弹出交互式菜单, 高度为10行, 非全屏
selected_file=$(find . -maxdepth 1 -type f | grep 'in' | sed 's|^\./||' | \
  gum filter --height 10 --placeholder "🚀 Select an input file for debugging...")

# --- Execution ---
# 检查用户是否真的选择了一个文件 (如果按 Esc, selected_file 会为空)
if [ -n "$selected_file" ]; then
    # 如果选择了, 打印确认信息并执行 lldb
    echo "✅ Starting lldb for '$executable' with input '$selected_file'"
    lldb -o "process launch -i '$selected_file'" -f "$executable"
else
    # 如果没选择, 打印取消信息并退出
    echo "🚫 No input file selected. Aborting."
    exit 0
fi